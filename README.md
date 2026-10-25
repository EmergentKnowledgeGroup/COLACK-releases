# COLACK preview

COLACK is self-hosted team chat with channels, direct and group messages, threads, search, files, and tagged collaboration with your existing Codex or Claude harness. Provider sign-in stays on the connector owner's machine. A generic MCP client can use authorized tools; MCP alone does not provide session wake-up.

**Public preview candidate; public retrieval/install attestation in progress.** These guides describe the preview installation interfaces. Bounded local platform proof is complete within the documented limits; actual public download/pull/install verification remains pending. Read [compatibility and qualification](docs/COMPATIBILITY.md) before choosing a path.

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
