#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$Directory,
    [string]$Image,
    [string]$ChatAddress,
    [switch]$PrepareOnly
)
$ErrorActionPreference = 'Stop'
function Prompt-Value([string]$Label, [string]$Default) {
    $answer = Read-Host "$Label [$Default]"
    if ([string]::IsNullOrEmpty($answer)) { return $Default }
    return $answer
}
function Assert-Line([string]$Value) {
    if ($Value.Contains("`n") -or $Value.Contains("`r")) { throw 'Paths and image values must be a single line.' }
}
function Assert-Image([string]$Value) {
    if ($Value -notmatch '^[a-zA-Z0-9][a-zA-Z0-9._/:@-]*$') { throw 'Use a valid versioned image reference.' }
    if ($Value.Contains('@')) {
        if ($Value -notmatch '@sha256:[a-fA-F0-9]{64}$') { throw 'Image digest must be sha256 followed by 64 hex characters.' }
    } else {
        $tail = ($Value -split '/')[-1]
        if ($tail -notmatch ':[^:]+$' -or ($tail -split ':')[-1] -ceq 'latest') {
            throw 'An explicit version tag or sha256 digest is required; latest is not allowed.'
        }
    }
}
function Assert-Port([string]$Value) {
    if ($Value -notmatch '^[0-9]{1,5}$') { throw 'Ports must be decimal numbers from 1 to 65535.' }
    $number = [int]$Value
    if ($number -lt 1 -or $number -gt 65535 -or $number -eq 13211 -or $number -eq 13000) {
        throw 'Choose ports from 1 to 65535; 13211 and 13000 are reserved inside the container.'
    }
}
function Assert-ChatAddress([string]$Value) {
    if ($Value -notmatch '^(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})$') {
        throw 'Chat address must be 127.0.0.1 or this host''s numeric private LAN IPv4 address (10.x.x.x, 172.16-31.x.x, or 192.168.x.x).'
    }
    $octets = @($Value.Split('.') | ForEach-Object { [int]$_ })
    if (@($octets | Where-Object { $_ -gt 255 }).Count -ne 0 -or
        -not ($Value -ceq '127.0.0.1' -or $octets[0] -eq 10 -or
            ($octets[0] -eq 172 -and $octets[1] -ge 16 -and $octets[1] -le 31) -or
            ($octets[0] -eq 192 -and $octets[1] -eq 168))) {
        throw 'Chat address must be 127.0.0.1 or this host''s numeric private LAN IPv4 address (10.x.x.x, 172.16-31.x.x, or 192.168.x.x).'
    }
}
function Assert-RealDirectory([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'Install and state directories must be real directories, not links.'
    }
}
function Protect-NewDirectory([string]$Path) {
    # Only called for directories this invocation has just created.
    $acl = New-Object Security.AccessControl.DirectorySecurity
    $acl.SetAccessRuleProtection($true, $false)
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User
    $inheritance = [Security.AccessControl.InheritanceFlags]'ContainerInherit, ObjectInherit'
    $propagation = [Security.AccessControl.PropagationFlags]::None
    $allow = [Security.AccessControl.AccessControlType]::Allow
    $acl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($sid, 'FullControl', $inheritance, $propagation, $allow)))
    $systemSid = New-Object Security.Principal.SecurityIdentifier('S-1-5-18')
    $acl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($systemSid, 'FullControl', $inheritance, $propagation, $allow)))
    Set-Acl -LiteralPath $Path -AclObject $acl
}
function Invoke-Compose([string[]]$ComposeArguments) {
    & docker compose @ComposeArguments
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose failed (exit $LASTEXITCODE)." }
}
function Yaml-Value([string]$Value) { return $Value.Replace("'", "''").Replace('$', '$$') }
function PowerShell-Literal([string]$Value) { return "'" + $Value.Replace("'", "''") + "'" }
Get-Command docker -ErrorAction Stop | Out-Null
Invoke-Compose @('version')
$chatAddressProvided = $PSBoundParameters.ContainsKey('ChatAddress')
if ($chatAddressProvided) { Assert-ChatAddress $ChatAddress }
if (-not $Directory) { $Directory = Prompt-Value 'Install/data directory' (Join-Path (Get-Location).Path 'colack-preview') }
Assert-Line $Directory
$Directory = [IO.Path]::GetFullPath($Directory)
if (-not (Test-Path -LiteralPath $Directory)) {
    [IO.Directory]::CreateDirectory($Directory) | Out-Null
    Protect-NewDirectory $Directory
}
Assert-RealDirectory $Directory
$Directory = (Get-Item -LiteralPath $Directory -Force).FullName.TrimEnd('\', '/')
$metadataPath = Join-Path $Directory '.colack-deployment'
$composePath = Join-Path $Directory 'compose.yml'
$statePath = Join-Path $Directory 'state'
if (Test-Path -LiteralPath $metadataPath) {
    $metaItem = Get-Item -LiteralPath $metadataPath -Force
    if ($metaItem.PSIsContainer -or ($metaItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Unexpected deployment metadata path.' }
    $lines = [IO.File]::ReadAllLines($metadataPath)
    $version1 = $lines.Length -eq 7 -and $lines[0] -ceq 'version=1'
    $version2 = $lines.Length -eq 8 -and $lines[0] -ceq 'version=2' -and $lines[7] -clike 'chat_address=*'
    if (-not ($version1 -or $version2) -or $lines[1] -cnotlike 'image=*' -or $lines[2] -cnotlike 'manager_port=*' -or $lines[3] -cnotlike 'chat_port=*' -or $lines[4] -cnotlike 'user=*' -or $lines[5] -cnotlike 'project=*' -or $lines[6] -cnotlike 'directory=*') { throw 'Unrecognized or incomplete deployment metadata; preserve it for recovery.' }
    $savedChatAddress = '127.0.0.1'
    if ($version2) { $savedChatAddress = $lines[7].Substring(13) }
    Assert-ChatAddress $savedChatAddress
    if ($chatAddressProvided -and $ChatAddress -cne $savedChatAddress) { throw 'This deployment already pins another chat address. Resume with its saved address; this launcher does not change exposure.' }
    $ChatAddress = $savedChatAddress
    $savedImage = $lines[1].Substring(6)
    if ($Image -and $Image -cne $savedImage) { throw 'This deployment already pins another image. Use the signed owner update/recovery flow; this launcher does not apply updates.' }
    $Image = $savedImage
    $managerPort = $lines[2].Substring(13)
    $chatPort = $lines[3].Substring(10)
    $runUser = $lines[4].Substring(5)
    $project = $lines[5].Substring(8)
    if ($lines[6].Substring(10) -cne $Directory) { throw 'Deployment was relocated. Recover the original path before resuming.' }
    if (-not (Test-Path -LiteralPath $composePath -PathType Leaf)) { throw 'Saved Compose file is missing; preserve the installation for recovery.' }
    if ((Get-Item -LiteralPath $composePath -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Saved Compose file must not be a link.' }
    Assert-RealDirectory $statePath
    Write-Host 'Reusing saved deployment settings. No image update will be applied.'
} else {
    if (@(Get-ChildItem -LiteralPath $Directory -Force).Count -ne 0) { throw 'Choose a new or empty install directory. Existing arbitrary data is never overwritten or reassigned.' }
    $descriptor = Join-Path $PSScriptRoot 'preview-image.txt'
    if (-not $Image -and (Test-Path -LiteralPath $descriptor -PathType Leaf)) { $Image = [IO.File]::ReadAllText($descriptor).TrimEnd("`r", "`n") }
    if (-not $Image) { $Image = Prompt-Value 'Release-provided versioned image (no default)' '' }
    Assert-Image $Image
    if (-not $chatAddressProvided) {
        $ChatAddress = Prompt-Value 'Chat publish address (127.0.0.1 for local/owner HTTPS proxy; this host''s numeric private IPv4 for trusted LAN)' '127.0.0.1'
    }
    Assert-ChatAddress $ChatAddress
    $managerPort = Prompt-Value 'Manager browser port' '3211'
    $chatPort = Prompt-Value 'Chat browser port' '3000'
    Assert-Port $managerPort
    Assert-Port $chatPort
    $managerPort = [string][int]$managerPort
    $chatPort = [string][int]$chatPort
    if ($managerPort -eq $chatPort) { throw 'Manager and chat ports must differ.' }
    $runUser = '10001:10001'
    $project = 'colack-preview-' + [Guid]::NewGuid().ToString('N')
    [IO.Directory]::CreateDirectory($statePath) | Out-Null
    Protect-NewDirectory $statePath
    # Public container identities only; never copy host account data.
    $utf8 = New-Object Text.UTF8Encoding($false)
    $passwdPath = Join-Path $Directory '.colack-passwd'
    $groupPath = Join-Path $Directory '.colack-group'
    [IO.File]::WriteAllText($passwdPath, "root:x:0:0:root:/root:/bin/sh`ncolack:x:10001:10001:COLACK:/state:/usr/sbin/nologin`n", $utf8)
    [IO.File]::WriteAllText($groupPath, "root:x:0:`ncolack:x:10001:`n", $utf8)
    $template = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'compose.preview.yml'))
    $template = $template.Replace('@IMAGE@', (Yaml-Value $Image)).Replace('@USER@', $runUser).Replace('@MANAGER_PORT@', $managerPort).Replace('@CHAT_PORT@', $chatPort).Replace('@CHAT_ADDRESS@', (Yaml-Value $ChatAddress)).Replace('@STATE@', (Yaml-Value ($statePath.Replace('\', '/'))))
    $template = $template.Replace('@PASSWD@', (Yaml-Value ($passwdPath.Replace('\', '/')))).Replace('@GROUP@', (Yaml-Value ($groupPath.Replace('\', '/'))))
    [IO.File]::WriteAllText($composePath, $template, $utf8)
    $metadata = @('version=2', "image=$Image", "manager_port=$managerPort", "chat_port=$chatPort", "user=$runUser", "project=$project", "directory=$Directory", "chat_address=$ChatAddress") -join "`n"
    [IO.File]::WriteAllText($metadataPath, $metadata + "`n", $utf8)
}
Assert-Image $Image
Assert-Port $managerPort
Assert-Port $chatPort
if ($managerPort -eq $chatPort -or $runUser -notmatch '^[1-9][0-9]*:[1-9][0-9]*$' -or $project -notmatch '^colack-preview-[a-z0-9-]+$') { throw 'Invalid saved deployment settings.' }
$baseArguments = @('--project-name', $project, '--file', $composePath)
Invoke-Compose ($baseArguments + @('config', '--quiet'))
Write-Host "`nManager: http://127.0.0.1:$managerPort"
Write-Host "Chat: http://${ChatAddress}:$chatPort"
Write-Host "In manager first-run setup, use this same chat address ($ChatAddress) for local or LAN access. Owner-managed public HTTPS requires a loopback chat publish address and your configured reverse proxy."
Write-Host "Private manager recovery file after first start: $statePath\manager.json.recovery.txt (never share its contents)."
$displayBase = 'docker compose --project-name ' + (PowerShell-Literal $project) + ' --file ' + (PowerShell-Literal $composePath)
Write-Host "Start/resume: $displayBase up --detach --no-build --pull missing"
Write-Host "Stop: $displayBase stop"
if (-not $PrepareOnly) {
    & docker info | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop first and wait for its engine to become available.' }
    Invoke-Compose ($baseArguments + @('up', '--detach', '--no-build', '--pull', 'missing'))
    Write-Host 'Open the manager URL above to create the first installation owner. SMTP is optional.'
} else {
    Write-Host 'Prepared only; no containers were started.'
}
