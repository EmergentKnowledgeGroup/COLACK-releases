# Candidate assets and integrity

**Public preview candidate; public retrieval/install attestation in progress.** The links below select the exact reviewed artifact bytes for `preview-2026.10.25-u20-d4`. Verify checksums, signed runtime inventories, compatibility notes and retained package notices before use. Do not combine files from different candidates.

| Asset filename | SHA-256 |
|---|---|
| `COLACK_0.1.0_x64-hosting-setup-U20-20261025.exe` | `96120950b121e79362e50bdb4438027eef6bcd205b622f3c858bf6f6bad07bb7` |
| `COLACK-windows-x64-runtime-preview-U20-20261025.zip` | `e4e513760f14ace19ed7990df333364f25da22c7cf9d792aa45787df5bdd0049` |
| `colack-connector-windows-x64.zip` | `2dfa0a566cf7774c2702131bfc50ea44112efd02367f49cfe0a1d986bff13659` |
| `colack-connector-ubuntu-x64.tar.gz` | `9fadd0d0afd6ce5b49bf60ab6f8ef2b7d8f9a9a882309c4220977d9dab87699f` |
| `mno-0.2.4-windows-x64.zip` | `013fbce677309433060d99b68a83438a6fb267741d5ca4a9d66018ea4aa1b3dc` |
| `mno-0.2.4-ubuntu-x64.tar.gz` | `8eca52b0e367b58d8dff9e0f4dd75e2476dc90befdce902b3d026d19d6130ab3` |
| `COLACK-ubuntu-x64-preview-D4-20261024.tar.gz` | `3d2b4af81d2c8daf90c90a9b4b35f4706e64e8a95841f921022c055199938591` |
| `colack-preview-docker-d4-20261024.tar` | `8366db927e0becafc2065a404f0ccf629c457af93cbec624931371bc01c5efbb` |

## Download this preview

| Download | Bytes |
|---|---:|
| [COLACK_0.1.0_x64-hosting-setup-U20-20261025.exe](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/COLACK_0.1.0_x64-hosting-setup-U20-20261025.exe) | 47,206,337 |
| [COLACK-windows-x64-runtime-preview-U20-20261025.zip](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/COLACK-windows-x64-runtime-preview-U20-20261025.zip) | 75,406,786 |
| [colack-connector-windows-x64.zip](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/colack-connector-windows-x64.zip) | 27,191,180 |
| [colack-connector-ubuntu-x64.tar.gz](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/colack-connector-ubuntu-x64.tar.gz) | 182,279,398 |
| [mno-0.2.4-windows-x64.zip](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/mno-0.2.4-windows-x64.zip) | 12,543,273 |
| [mno-0.2.4-ubuntu-x64.tar.gz](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/mno-0.2.4-ubuntu-x64.tar.gz) | 66,684,530 |
| [COLACK-ubuntu-x64-preview-D4-20261024.tar.gz](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/COLACK-ubuntu-x64-preview-D4-20261024.tar.gz) | 42,241,492 |
| [colack-preview-docker-d4-20261024.tar](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/colack-preview-docker-d4-20261024.tar) | 97,122,304 |

[SHA256SUMS.txt](https://github.com/EmergentKnowledgeGroup/COLACK-releases/releases/download/preview-2026.10.25-u20-d4/SHA256SUMS.txt) lists exactly these eight assets. This top-level checksum list is unsigned; it is not an Ed25519-signed inventory. The runtime archives retain their existing signed inventories and publisher public key.

The Windows installer is U20 (47,206,337 bytes) and contains the desktop client plus hosting runtime. Its matching U20 runtime ZIP is 75,406,786 bytes. The two `colack-connector-*` archives are standalone connector packages. The `mno-0.2.4-*` archives are optional inputs selected in connector setup, not application servers. `COLACK-ubuntu-x64-preview-D4-20261024.tar.gz` is the complete signed Linux native package, including its guided installer, systemd registrar and native updater. Its package contents and entrypoints are verified; public download/install qualification remains pending. `colack-preview-docker-d4-20261024.tar` is a Docker image export, not a registry reference or a native installer.

The matching immutable registry reference is `ghcr.io/emergentknowledgegroup/colack-preview@sha256:ab56df209736e60c92379f461db3080aea3da27c9cb772a8e3ad60a0eadb7f09`. It is also supplied in [preview-image.txt](../docker/preview-image.txt). This is the registry manifest digest; the image export checksum above identifies different bytes. Anonymous registry retrieval/install attestation remains in progress.

The [three Docker helper files](DOCKER.md) in this documentation set are exact copies of the current end-user launchers/template. Keep them together beside the matching [preview-image.txt](../docker/preview-image.txt). The launcher reads an explicitly supplied version/digest or this adjacent image-selection file; no image-reference editing is needed for the default guided path. Native bootstrap/service/update helpers stay inside their original signed runtime packages and are not detached here.

The publisher public key file `update-publisher-key.bin` has SHA-256:

```text
96c0598f1f5296f675bdda65649f6a31051149fbd228a90b93843a8f8e030c92
```

Match this fingerprint through the trusted release channel before first installation. It is a fingerprint of the raw public-key bytes, not the private key, an artifact signature or an Authenticode certificate. Retain exact `update-manifest.json`, `update-manifest.sig`, package inventory and public-key bytes in the runtime download. Never edit signed runtime contents to insert these docs. The installed key selects the update verifier; the candidate does not replace it. See [update checks](UPDATES.md).

Windows installer Authenticode status is **NotSigned**. A matching checksum identifies bytes but does not by itself establish publisher trust. All listed binary assets remain outside this documentation payload. Dependency, CPython, PostgreSQL, connector wheel and MNO/MIT notices stay with their original artifacts; preserve them when redistributing. This preview makes no new license grant or commercial decision.

For Windows native updates, `COLACK-windows-x64-runtime-preview-U20-20261025.zip` contains the complete signed runtime at the archive root, including notices and updater helpers. Extract the entire archive into a new candidate folder; select that folder in the installed manager or installed native update launcher. Do not merge it into the running installation. This archive is byte-verified against the current normal U20 runtime. Its three server binaries match the guided network/recovery qualification. Earlier normal U18 installed update and real failed-migration compatible recovery on Windows 10 remain retained evidence; normal U20 Windows 10 GUI Host/UAC installation and rendered owner/login/chat/message/file now pass with all installed bytes/directories matched; current U20 Windows 10 unattended reboot retained owner/message/file and restored three healthy automatic native services without a logged-in user, Explorer or client. Native Connections controls were confirmed by the human operator. Windows 11 normal U20 Join/client qualification now passes, including rendered login/message/75-byte file, reload/exact browser download, native notification bridge, owner controls, visual/AX/keyboard and human Connections. A separate clean U20 Windows 11 normal GUI Host/UAC installation now passes with all 3,607 files and 528 directories matched, including four empty directories, plus rendered owner/login/chat/message and a 68-byte file round trip. One actual unattended reboot retained the same owner/message/file, seven protected files/ACLs and critical candidate/client bytes, and restored three healthy automatic native services on loopback without a logged-in user, Explorer or client. These are bounded local fresh-install/reboot journeys. Public download/pull/install attestation remains in progress. Diagnostic migration variants used for additive/repeat/reboot tests are excluded from this archive.
