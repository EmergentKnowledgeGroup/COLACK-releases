# Back up and restore

The independent manager is the recovery surface when chat or its local PostgreSQL is stopped. Unlock its numeric-loopback URL with the private machine recovery credential through authorized local access or an authenticated host tunnel. A chat/admin/agent login alone does not authorize these operations. Current engineering evidence includes a complete Windows-host Linux Docker snapshot restored into a fresh separate Ubuntu Docker deployment, plus native Ubuntu recovery subsets. These retain original accounts, messages/files, keys and recovery material. Remaining native-service and full-platform recovery qualification is listed in the [compatibility snapshot](COMPATIBILITY.md).

## Create and check a snapshot

1. Open **Back up this installation** and verify the displayed data folder.
2. Choose a new absolute snapshot folder outside installation data and any configured attachment/key paths. Its parent must exist; the destination must not exist, even empty.
3. Select **Create snapshot** and allow downtime. Local cold snapshots stop chat and the owned cluster cleanly. External-database snapshots use a logical export of the configured application database; the manager does not control the external database server.
4. Read both snapshot and service recovery results, then **Refresh health**. Only previously running services are restarted. A complete copy does not prove the services recovered; use diagnostics if they did not.

Snapshots contain application data, configured attachments, installation keys, original private configuration and machine recovery material. Referenced S3 objects are included through the explicitly configured storage credentials; unrelated bucket objects and unrelated external files are excluded. Package binaries and optional runner-side MNO stores are excluded. Preserve the compatible runtime separately and back up MNO through its own [connection setup controls](CONNECTOR_SETUP.md).

Keep the whole snapshot private. Filesystem permissions do not encrypt it. Preserve partial snapshots after failures; they are not complete backups and cannot be overwritten on retry. Inventory sizes and hashes detect disagreement with the snapshot, not trusted publisher origin.

## Schedule snapshots

In **Backup schedule**, choose an existing destination outside data, a positive interval and the desired completed-snapshot retention. No interval, retention or destination is preselected; scheduling starts off. The manager must remain running. Check the displayed last result, next due time, retention warnings and service health. Retention removes only validated completed snapshots from that schedule, preserving manual snapshots, partial attempts and unrelated folders. Restored managers leave scheduling off until you explicitly configure the new host.

## Restore into new state

1. Preserve the original installation and use a compatible complete runtime plus a fresh independent manager and recovery credential. Leave chat/database unconfigured; do not create an empty installation first.
2. Unlock the fresh manager. In **Restore into a fresh data folder**, select the complete snapshot and an absent destination outside it, under an existing parent. Restore never merges into or replaces existing state.
3. Choose distinct available chat/database ports, also distinct from the manager port. Cold snapshots require matching OS, architecture and PostgreSQL major. Logical export recovery may support the same or newer major, but cross-platform recovery remains unqualified.
4. For S3, explicitly choose the destination bucket/region/endpoint and private storage credentials. Use a destination without objects at the backed-up keys. Conditional creation refuses to overwrite existing keys; a failed attempt can leave a partial local folder and some new destination objects. Preserve them and use fresh destinations on retry.
5. Restore, refresh health and open the reported chat URL. Verify original account login, representative messages and uploaded files. Original accounts/keys survive; a replacement owner claim is not required. **services_ready: false** means service recovery is still needed.

Restore verifies inventory before copying and rechecks copied bytes. It selects fresh local ports/configuration and preserves original host recovery material privately; it does not replace the new manager credential. This restore path starts owned local processes and does not itself register Windows or systemd services. Partial folders remain for host recovery. Do not delete the only copy of user data or claim success from a copy result alone. For a failed update, use [compatible update recovery](UPDATES.md).
