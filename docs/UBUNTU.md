# Ubuntu native hosting

Ubuntu 24.04 and 26.04 LTS x64 with systemd are intended targets. Retained native installation, update/recovery and unattended-reboot journeys are described below; public retrieval/install attestation remains in progress. The measured Ubuntu 24.04 workload is [bounded capacity evidence](MEASURED_CAPACITY.md), not full release qualification.

A fresh private D3 installation on Ubuntu 24.04 completed the packaged terminal bootstrap, local owner/message/file journey, three distinct nonroot services and an unattended reboot with retained state. D4 preserves those server binaries and corrects native registration for the explicitly selected LAN address. A fresh D4 installation on Ubuntu 26.04 also completed the packaged terminal bootstrap, actual guest-interface LAN owner/message/file journey, distinct nonroot services and unattended reboot:28 checks before and29 after, with retained network settings and seven configuration/key hashes. The guest was gracefully powered off; no second physical client or browser UI is claimed by that test. These observations do not establish public download or full target-matrix readiness.

The native preview download is `COLACK-ubuntu-x64-preview-D4-20261024.tar.gz`. Its complete signed contents, native installer and execution modes are verified; public retrieval/install attestation remains in progress. Use the reviewed release and verify its checksum and publisher-key fingerprint in [candidate assets](DOWNLOADS.md). No Rust, Node.js or SMTP setup is required.

From an interactive terminal as a normal local operator, extract into a new directory and launch its packaged bootstrap:

```sh
mkdir COLACK-ubuntu-x64-preview-D4-20261024
tar -xzf COLACK-ubuntu-x64-preview-D4-20261024.tar.gz \
  -C COLACK-ubuntu-x64-preview-D4-20261024
sudo sh "$PWD/COLACK-ubuntu-x64-preview-D4-20261024/native/install-ubuntu.sh" \
  --publisher-key-sha256 96c0598f1f5296f675bdda65649f6a31051149fbd228a90b93843a8f8e030c92
```

The archive contains package files directly, with no enclosing directory. The bootstrap installs runtime dependencies and checks Ed25519 signatures using OpenSSL before executing package code. It copies the signed runtime into a fresh `/opt/colack/runtime`. Existing installation paths, identities and service units are refused.

Keep the terminal open. The browser and database preparation run without root. Read the private recovery file at the location printed by the launcher as your normal user, then paste its credential into **Unlock manager**. The credential is never printed or placed in a URL. In **Set up COLACK**, select a new data directory under `/var/lib/colack`, review ports and choose chat access. Local HTTP is the default. Trusted LAN mode requires this host's numeric private IPv4 origin and matching chat port. Public HTTPS requires your existing DNS domain, trusted certificate and HTTPS proxy to the loopback chat port. Run the network check, then prepare the installation; preparation repeats the check before writing state. Use the private single-use claim to create the first owner account. Return to the terminal and press Enter to complete service registration.

The registrar uses separate database, chat and manager identities and enables services at boot. The manager remains independent and loopback-only. Verify actual service health and reboot behavior on the target host before relying on unattended operation. LAN mode binds chat to the selected private address; Ubuntu firewall/router access remains the owner's responsibility. Public mode keeps chat loopback-only behind the owner's proxy. Setup validates TLS reachability, then application health after startup; it does not provision DNS, certificates, proxy or firewall rules.

For a host without a desktop, the packaged bootstrap accepts `--no-browser`; use an operator-controlled SSH tunnel to the printed loopback manager port. Keep recovery-file contents out of URLs and logs. Advanced install/state directory options require new absolute directories under existing root-owned, service-traversable parents.

If interrupted, preserve the runtime, state, private recovery files and setup log. Do not rerun into existing directories or remove an initialized database. This is fresh installation, not adoption. See [backup/restore](BACKUP_RESTORE.md) and [updates](UPDATES.md).
