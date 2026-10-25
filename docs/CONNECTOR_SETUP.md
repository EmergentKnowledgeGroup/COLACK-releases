# Connect your existing agent

The packaged connector runs on the machine with your existing supported native harness. Provider sign-in stays in the owner-selected private native profile; setup does not locate/copy provider tokens or perform provider login. The package includes its Python runtime, so host Python and manual JSON editing are unnecessary.

Current bounded Windows evidence covers standalone Codex CLI **0.147.0** and Claude Code CLI **2.1.283** with the bundled Claude SDK **0.2.163**. These are the observed versions, not a claim that every installed version or platform is compatible. Codex desktop-bundled 0.153.4 encountered a provider tool-namespace rejection and is unqualified. Positive continuation of an explicitly selected compatible existing Claude session now passes on Claude Code CLI **2.1.293** with SDK **0.2.163**, including original native history/session correlation; all 27 bounded collaboration/harness/memory checks are supported. See [qualification](COMPATIBILITY.md).

## Set up one connection

1. Sign into your native harness using its normal login flow. Use an owner-restricted private profile and exact supported executable. Do not place profiles or keys in shared source folders.
2. In COLACK **Agents**, create the agent and connection. Configure permitted people, conversations, approved project mappings and delegated approvers. Issue separate **runner** and **tools** credentials.
3. Extract the matching connector archive from the release set. Open `connector-setup-ui.cmd` on Windows or `./connector-setup-ui` on Ubuntu. Choose an empty private connection data folder, or reopen that connection's existing managed folder.
4. In the local form, enter the server origin and select Codex or Claude, the exact executable and its signed-in private profile. Remote servers require HTTPS; plain HTTP is accepted only on loopback. Setup refuses a profile with overly broad filesystem access instead of changing it.
5. Leave session ID blank for a labeled dedicated worker, or deliberately select an exact supported native session whose original project already matches the approved mapping. Unsupported attach does not silently attach another terminal. Model selection is optional. Claude MCP trust is an explicit checkbox, off by default; it grants no native file approval and does not bypass COLACK policy.
6. Paste the two issued keys and save. Leave key fields blank on reopening to retain them. Start the worker, then send an ordinary permitted tagged request from COLACK. **Running** describes a local process; confirm the actual reply before assuming a completed job.

Restart reuses the saved configuration, profile, journal and selected session. After a journal exists, server/profile/harness/session identity cannot be rebound in place; use a new empty connection folder. Executable/model updates and key replacement are available while stopped.

Keep the controller running with the worker. Closing its browser tab leaves it running. **Close setup** requests stop and waits for owned cleanup. A stop is not server completion or cancellation; uncertain in-flight work can require reconciliation. Do not start another worker on the same journal to force progress. Native approvals and current COLACK permissions still apply. Directed agent chains require explicit permission and remain subject to loop controls; tagged participation does not grant general access.

## Optional scoped MNO memory

Ordinary collaboration works without MNO. The memory section accepts the pinned original MNO **0.2.4** Windows ZIP or Ubuntu archive, checks its pinned checksum and bundled inventory, and installs it into a fresh private connection-owned folder. It does not adopt an arbitrary extracted runtime/store or download an unpinned version. See [asset hashes](DOWNLOADS.md).

Run one ordinary tagged request, stop the worker and refresh setup. Select the exact agent/workspace/conversation/project scope offered from this connection's journal. Create its private scope and optionally choose an explicit input file. **Start human review** prepares or resumes the real local MNO curation workflow. Review, publish, verify Safe status and activate there, then return and choose **Use reviewed memory**. Artifact presence alone does not establish readiness.

Each scope has a separate private store and integration credential with health/capabilities, context retrieval/explanation and provisional observation powers. Completed permitted turns may become provisional observations; there are no silent reviewed-memory writes or Secret Drop values. An optional identity/preferences profile has its own store. Local review does not authorize sharing: the connection owner must explicitly activate the exact publication in COLACK's memory profile panel. Delegated harness approval does not confer memory-curation authority.

Stop the worker before changing memory. Unavailable or unreviewed MNO permits ordinary work. Disable removes the managed binding and retains private data. Setup's backup control stops the owned scope and writes a new private archive/checksum outside it. Restore requires the same exact scope and an absent destination; it stays offline and disabled until existing review/binding checks succeed. Server snapshots do not include these runner stores. Keep these backups private and separate; see [recovery](BACKUP_RESTORE.md).
