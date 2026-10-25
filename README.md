# COLACK preview

> **Windows runtime ZIP packaging correction:** The initial U20 ZIP (SHA-256 `e4e513760f14ace19ed7990df333364f25da22c7cf9d792aa45787df5bdd0049`) is withdrawn under a `WITHDRAWN-` asset name because four empty directories required by its signed inventory were missing. The separately named `COLACK-windows-x64-runtime-preview-U20-20261025-r1.zip` adds exactly those four directory entries. All 3,607 files, signed manifests, signatures, binaries, publisher key and normal21 migrations are unchanged. Fresh Windows extraction and the unchanged strict verifier passed. Use the r1 archive and `SHA256SUMS-r1.txt`; old published bytes and the initial checksum list are retained, not replaced.


COLACK is self-hosted team chat with channels, direct and group messages, threads, search, files, and tagged collaboration with your existing Codex or Claude harness. Provider sign-in stays on the connector owner's machine. A generic MCP client can use authorized tools; MCP alone does not provide session wake-up.

**Public preview; public artifact verification complete within the documented scope.** These guides describe the preview installation interfaces. Bounded platform proof is complete within the documented limits; actual public artifact verification is complete within the scope recorded in the compatibility guide. Read [compatibility and qualification](docs/COMPATIBILITY.md) before choosing a path.

The preview downloads are free. Future commercial terms remain undecided. COLACK's source repository remains private; this documentation and reviewed distributable artifacts use COLACK-releases for distribution. Shipped frontend/runtime files are inspectable and do not promise source obfuscation or DRM. Preserve the licenses and notices supplied with each package.

## Choose how to use COLACK

| Choice | Start here |
|---|---|
| Join a server from a Windows desktop client, or host on Windows | [Windows guide](docs/WINDOWS.md) |
| Host natively on Ubuntu with systemd | [Ubuntu guide](docs/UBUNTU.md) |
| Host with Docker Engine or Docker Desktop | [Docker guide](docs/DOCKER.md) |
| Connect an existing native agent | [Connector setup](docs/CONNECTOR_SETUP.md) |

The packaged paths use prebuilt runtimes and need no Rust, Node.js, or source checkout. SMTP is optional for first-owner setup. Local loopback access is the default. First-run setup offers trusted LAN access through the host's private IPv4 address or public HTTPS through the owner's existing trusted reverse proxy. Docker also pins the chosen chat publish address in its launcher. The manager and database stay private; keep manager and recovery credentials protected.

Read [backup and restore](docs/BACKUP_RESTORE.md), [updates and withdrawn releases](docs/UPDATES.md), [measured capacity](docs/MEASURED_CAPACITY.md), [candidate assets and integrity](docs/DOWNLOADS.md), and [release notes](RELEASE_NOTES.md).
