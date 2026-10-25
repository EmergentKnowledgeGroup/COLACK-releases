#!/usr/bin/env bash
# End-user install/resume: Bash and Docker Compose v2 only. Never source metadata.
set -euo pipefail
umask 077
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
install_dir=''
image=''
chat_address=''
chat_address_provided=false
prepare_only=false
while (($#)); do
  case "$1" in
    --directory|--image|--chat-address)
      (($# >= 2)) || { printf 'Missing value for %s\n' "$1" >&2; exit 1; }
      if [[ $1 == --directory ]]; then install_dir=$2
      elif [[ $1 == --image ]]; then image=$2
      else chat_address=$2; chat_address_provided=true; fi
      shift 2 ;;
    --prepare-only) prepare_only=true; shift ;;
    --help) printf 'Usage: bash install-preview.sh [--directory PATH] [--image VERSIONED_IMAGE] [--chat-address PRIVATE_IPV4_OR_127.0.0.1] [--prepare-only]\n'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
  esac
done
fail() { printf '%s\n' "$*" >&2; exit 1; }
line_value() { [[ $1 != *$'\n'* && $1 != *$'\r'* ]] || fail 'Paths and image values must be a single line.'; }
valid_image() {
  [[ $1 =~ ^[a-zA-Z0-9][a-zA-Z0-9._/:@-]*$ ]] || fail 'Use a valid versioned image reference.'
  if [[ $1 == *@* ]]; then
    [[ $1 =~ @sha256:[a-fA-F0-9]{64}$ ]] || fail 'Image digest must be sha256 followed by 64 hex characters.'
  else
    local tail=${1##*/}
    [[ $tail == *:* && -n ${tail##*:} && ${tail##*:} != latest ]] || fail 'An explicit version tag or sha256 digest is required; latest is not allowed.'
  fi
}
valid_port() {
  [[ $1 =~ ^[0-9]+$ && ${#1} -le 5 ]] || fail 'Ports must be decimal numbers from 1 to 65535.'
  local n=$((10#$1))
  ((n >= 1 && n <= 65535 && n != 13211 && n != 13000)) || fail 'Choose ports from 1 to 65535; 13211 and 13000 are reserved inside the container.'
}
valid_chat_address() {
  local a b c d
  [[ $1 =~ ^(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})\.(0|[1-9][0-9]{0,2})$ ]] || fail 'Chat address must be 127.0.0.1 or a numeric private LAN IPv4 address on this host (10.x.x.x, 172.16-31.x.x, or 192.168.x.x).'
  a=${BASH_REMATCH[1]}; b=${BASH_REMATCH[2]}; c=${BASH_REMATCH[3]}; d=${BASH_REMATCH[4]}
  ((a <= 255 && b <= 255 && c <= 255 && d <= 255)) &&
    [[ $1 == 127.0.0.1 || $a == 10 || ($a == 172 && $b -ge 16 && $b -le 31) || ($a == 192 && $b == 168) ]] || fail 'Chat address must be 127.0.0.1 or a numeric private LAN IPv4 address on this host (10.x.x.x, 172.16-31.x.x, or 192.168.x.x).'
}
prompt() { local answer; read -r -p "$1 [$2]: " answer; printf '%s' "${answer:-$2}"; }
command -v docker >/dev/null || fail 'Install Docker Engine and the Docker Compose v2 plugin first.'
docker compose version >/dev/null || fail 'Docker Compose v2 is required.'
[[ $chat_address_provided == false ]] || valid_chat_address "$chat_address"
[[ -n $install_dir ]] || install_dir=$(prompt 'Install/data directory' "$HOME/colack-preview")
line_value "$install_dir"
[[ $install_dir == /* ]] || install_dir="$PWD/$install_dir"
if [[ ! -e $install_dir && ! -L $install_dir ]]; then
  mkdir -m 700 -- "$install_dir"
fi
[[ -d $install_dir && ! -L $install_dir ]] || fail 'Install directory must be a real directory, not a symbolic link.'
install_dir=$(cd -- "$install_dir" && pwd -P)
metadata="$install_dir/.colack-deployment"
compose="$install_dir/compose.yml"
if [[ -f $metadata && ! -L $metadata ]]; then
  mapfile -t lines < "$metadata"
  if ((${#lines[@]} == 7)) && [[ ${lines[0]} == version=1 ]]; then
    saved_chat_address=127.0.0.1
  elif ((${#lines[@]} == 8)) && [[ ${lines[0]} == version=2 && ${lines[7]} == chat_address=* ]]; then
    saved_chat_address=${lines[7]#chat_address=}
  else
    fail 'Unrecognized or incomplete deployment metadata; preserve the directory and recover its original metadata.'
  fi
  [[ ${lines[1]} == image=* && ${lines[2]} == manager_port=* && ${lines[3]} == chat_port=* && ${lines[4]} == user=* && ${lines[5]} == project=* && ${lines[6]} == directory=* ]] || fail 'Unrecognized deployment metadata.'
  valid_chat_address "$saved_chat_address"
  [[ $chat_address_provided == false || $chat_address == "$saved_chat_address" ]] || fail 'This deployment already pins another chat address. Resume with its saved address; this launcher does not change exposure.'
  chat_address=$saved_chat_address
  saved_image=${lines[1]#image=}
  [[ -z $image || $image == "$saved_image" ]] || fail 'This deployment already pins another image. Use the signed owner update/recovery flow; this launcher does not apply updates.'
  image=$saved_image
  manager_port=${lines[2]#manager_port=}
  chat_port=${lines[3]#chat_port=}
  run_user=${lines[4]#user=}
  project=${lines[5]#project=}
  [[ ${lines[6]#directory=} == "$install_dir" ]] || fail 'Deployment was relocated. Recover the original path before resuming.'
  [[ -f $compose && ! -L $compose && -d $install_dir/state && ! -L $install_dir/state ]] || fail 'Saved deployment files/state are missing or linked; preserve them for recovery.'
  printf 'Reusing saved deployment settings. No image update will be applied.\n'
else
  [[ ! -e $metadata && ! -L $metadata ]] || fail 'Unexpected metadata path; preserve the directory for recovery.'
  [[ -z $(find "$install_dir" -mindepth 1 -maxdepth 1 -print -quit) ]] || fail 'Choose a new or empty install directory. Existing arbitrary data is never overwritten or reassigned.'
  if [[ -z $image && -f $script_dir/preview-image.txt ]]; then
    image=$(cat -- "$script_dir/preview-image.txt")
  fi
  [[ -n $image ]] || image=$(prompt 'Release-provided versioned image (no default)' '')
  valid_image "$image"
  [[ $chat_address_provided == true ]] || chat_address=$(prompt "Chat publish address (127.0.0.1 for local/owner HTTPS proxy; this host's numeric private IPv4 for trusted LAN)" 127.0.0.1)
  valid_chat_address "$chat_address"
  manager_port=$(prompt 'Manager browser port' 3211)
  chat_port=$(prompt 'Chat browser port' 3000)
  valid_port "$manager_port"; valid_port "$chat_port"
  manager_port=$((10#$manager_port)); chat_port=$((10#$chat_port))
  [[ $manager_port != "$chat_port" ]] || fail 'Manager and chat ports must differ.'
  run_user="$(id -u):$(id -g)"
  [[ $(id -u) != 0 ]] || run_user=10001:10001
  project="colack-preview-$(date +%s)-$$"
  mkdir -m 700 -- "$install_dir/state"
  if [[ $(id -u) == 0 ]]; then chown 10001:10001 -- "$install_dir/state"; fi
  # chmod/chown applies only to the state directory created immediately above.
  # initdb requires the numeric container UID to resolve to a passwd entry.
  # These contain only public container identities, never host account data.
  printf 'root:x:0:0:root:/root:/bin/sh\ncolack:x:%s:%s:COLACK:/state:/usr/sbin/nologin\n' "${run_user%:*}" "${run_user#*:}" > "$install_dir/.colack-passwd"
  printf 'root:x:0:\ncolack:x:%s:\n' "${run_user#*:}" > "$install_dir/.colack-group"
  chmod 644 -- "$install_dir/.colack-passwd" "$install_dir/.colack-group"
  yaml_value() { local value=${1//\'/\'\'}; printf '%s' "${value//\$/\$\$}"; }
  template=$(cat -- "$script_dir/compose.preview.yml")
  replace_token() { local before=$1 token=$2 replacement=$3 result='' ; while [[ $before == *"$token"* ]]; do result+="${before%%"$token"*}$replacement"; before=${before#*"$token"}; done; printf '%s' "$result$before"; }
template=$(replace_token "$template" '@IMAGE@' "$(yaml_value "$image")")
  template=$(replace_token "$template" '@USER@' "$run_user")
  template=$(replace_token "$template" '@MANAGER_PORT@' "$manager_port")
  template=$(replace_token "$template" '@CHAT_PORT@' "$chat_port")
  template=$(replace_token "$template" '@CHAT_ADDRESS@' "$(yaml_value "$chat_address")")
  template=$(replace_token "$template" '@STATE@' "$(yaml_value "$install_dir/state")")
  template=$(replace_token "$template" '@PASSWD@' "$(yaml_value "$install_dir/.colack-passwd")")
  template=$(replace_token "$template" '@GROUP@' "$(yaml_value "$install_dir/.colack-group")")
  printf '%s\n' "$template" > "$compose"
  printf 'version=2\nimage=%s\nmanager_port=%s\nchat_port=%s\nuser=%s\nproject=%s\ndirectory=%s\nchat_address=%s\n' "$image" "$manager_port" "$chat_port" "$run_user" "$project" "$install_dir" "$chat_address" > "$metadata"
fi
valid_image "$image"; valid_port "$manager_port"; valid_port "$chat_port"
[[ $manager_port != "$chat_port" && $run_user =~ ^[0-9]+:[0-9]+$ && $run_user != 0:* && $run_user != *:0 && $project =~ ^colack-preview-[a-z0-9-]+$ ]] || fail 'Invalid saved deployment settings.'
docker compose --project-name "$project" --file "$compose" config --quiet
printf '\nManager: http://127.0.0.1:%s\nChat: http://%s:%s\n' "$manager_port" "$chat_address" "$chat_port"
printf 'In manager first-run setup, use this same chat address (%s) for local or LAN access. Owner-managed public HTTPS requires a loopback chat publish address and your configured reverse proxy.\n' "$chat_address"
printf 'Private manager recovery file after first start: %s/state/manager.json.recovery.txt (never share its contents).\n' "$install_dir"
printf 'Start/resume: docker compose --project-name %q --file %q up --detach --no-build --pull missing\n' "$project" "$compose"
printf 'Stop: docker compose --project-name %q --file %q stop\n' "$project" "$compose"
if [[ $prepare_only == false ]]; then
  docker info >/dev/null || fail 'Start Docker first. Windows requires Docker Desktop to become available.'
  docker compose --project-name "$project" --file "$compose" up --detach --no-build --pull missing
  printf 'Open the manager URL above to create the first installation owner. SMTP is optional.\n'
else
  printf 'Prepared only; no containers were started.\n'
fi
