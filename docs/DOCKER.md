# Guided Docker hosting

This path uses a prebuilt Linux runtime. Intended targets are Ubuntu 24.04/26.04 LTS x64 with Docker Engine and Compose v2, or Windows 10/11 x64 with Docker Desktop in Linux-container mode. For the qualified preview targets and exact observed limits, see [compatibility](COMPATIBILITY.md).

Download the three matching helper files and image selector together: [install-preview.sh](../docker/install-preview.sh), [install-preview.ps1](../docker/install-preview.ps1), [compose.preview.yml](../docker/compose.preview.yml) and [preview-image.txt](../docker/preview-image.txt). Keep all four in the same folder. The three helpers are unchanged; the selector pins the matching immutable registry image. Public artifact verification now passes within the documented scope. See [downloads and checksums](DOWNLOADS.md).

Start Docker first. From the downloaded launcher folder, use the command for your host. The adjacent selector supplies the release image:

```sh
bash ./install-preview.sh
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-preview.ps1
```

The selector contains `ghcr.io/emergentknowledgegroup/colack-preview@sha256:ab56df209736e60c92379f461db3080aea3da27c9cb772a8e3ad60a0eadb7f09`. You can explicitly supply another reviewed version/digest through the existing `--image` or `-Image` option. An explicit version or SHA-256 digest is required; unversioned references and `:latest` are refused. Use the process-scoped PowerShell invocation above only for the verified release helper where no configured or enforced organization/user policy prohibits execution. Do not change persistent execution policy or use this command to override a configured policy.

Follow the prompts for a new or empty installation directory and distinct manager/chat ports (defaults 3211 and 3000). Existing arbitrary directories are not overwritten. The launcher prints the exact manager/chat URLs and deployment-specific start/stop commands. Choose the chat publish address: `127.0.0.1` is the default for local access or an owner HTTPS proxy; choose this host's numeric private IPv4 address for trusted LAN HTTP. You can also supply `--chat-address` in Bash or `-ChatAddress` in PowerShell. The manager stays on `127.0.0.1`; the database has no published port. In the manager's first-run form, use the same selected chat address and port. Public HTTPS requires a loopback chat publish address and your existing trusted HTTPS reverse proxy; the manager checks TLS reachability before state preparation and application health after startup. Create the first owner through the manager; SMTP is optional.

Keep `compose.yml`, `.colack-deployment`, `.colack-passwd`, `.colack-group` and `state/` together. `state/` contains private configuration, recovery material, database and files. The identity files contain only the selected container identity, not host account data. Runtime processes run without container root. Do not loosen state permissions to work around errors.

Use the launcher's printed `docker compose` commands to stop or resume this deployment. Stopping preserves data. Rerunning against the same installation reuses its saved image, ports, chat address and project; a different image is refused. Rerunning does not apply updates. Moving state, editing deployment metadata or replacing the image is not a routine update. Use [signed updates and recovery](UPDATES.md).

Ubuntu unattended restart requires Docker Engine to run at boot and target-host qualification. Windows startup depends on Docker Desktop becoming available; unattended boot before Windows login is not promised. Preserve partial preparations for recovery. Do not delete `state/` or use destructive Docker cleanup to repair an installation.

The saved chat address is fixed for a deployment. Older local deployments retain their existing loopback mapping. The launcher does not change exposure when resumed. An owner-supplied public HTTPS origin must contain only scheme/host/optional port; setup does not create DNS, certificates, proxy configuration or firewall rules. LAN behavior has been tested through the host's private IP; second-device firewall access and real public hosting remain target-host qualification.
