# Measured Ubuntu capacity

On 2026-10-23, the private D2 preview candidate completed eight native/Docker workload stages on the same Ubuntu reference VM with **35,454 durable messages, 3,585 verified attachment round trips, and zero recorded HTTP, WebSocket, or worker errors**. These measurements describe this configuration and workload; they do not establish a supported number of users or a product latency promise. Public release qualification remains separate.

## Reference configuration

- Ubuntu 24.04.5 x64, kernel 6.8.0-146-generic, hardware-accelerated Hyper-V VM with two virtual CPUs, 3 GiB fixed RAM and no swap.
- Intel Core i9-12900K host with 24 logical processors; CPU and storage were shared and unpinned. The VM used one virtual disk. The existing installation stayed active and idle during both series.
- Native and Docker ran sequentially in separate fresh installations. Both used the identical signed runtime, PostgreSQL 16.15, migrations 1–21 and matching effective application/database settings. Docker Engine 29.9.2 was installed for both series; no container ran during the native measurement.
- Observed database settings included 100 maximum connections, 128 MiB shared buffers, 4 MiB work memory, and enabled fsync, full-page writes and synchronous commit. Docker had no additional CPU, memory or PID limit.
- Candidate: `preview-docker-D2-20261023`. API SHA256: `fb3ce24c5283bd87d5fa5d93b3f4a1062bc82fadbbc680931b46e1898469d4ae`. Native and Docker signatures, signed inventories and measured component hashes were verified.

## Workload

Each mode ran 1, 4, 12 and 24 concurrent authenticated sessions of **one synthetic owner**, in that order, for 30 seconds per stage with no think time. Each session read conversation history, posted a roughly 350–380-byte message, and consumed its matching `message.created` WebSocket event in one shared channel. Every tenth cycle uploaded a 64 KiB attachment and downloaded it with hash verification.

The load generator ran in the same guest and shared its CPU budget. Rates include the final operation's completion time and exclude the resource sampler's tail. Successful POST counts were reconciled with durable database rows. Latency percentiles describe successful requests; own-event latency runs from POST start through consumption of the matching event, including response time and queued broadcast frames.

## Results

| Concurrent sessions | Native posts/s | Docker posts/s | Native POST p95 ms | Docker POST p95 ms | Native own-event p95 ms | Docker own-event p95 ms |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 129.75 | 79.74 | 3.96 | 4.17 | 4.63 | 4.79 |
| 4 | 224.18 | 163.45 | 12.44 | 46.87 | 13.93 | 48.00 |
| 12 | 170.61 | 170.16 | 30.21 | 61.15 | 58.72 | 74.77 |
| 24 | 127.74 | 114.30 | 29.37 | 57.55 | 206.10 | 222.20 |

Native persisted 19,588 messages and 1,978 attachments; Docker persisted 15,866 messages and 1,607 attachments. All 78,078 HTTP operations succeeded, every successful post had a matching observed event, and every attachment download matched its upload. Both databases recorded zero transaction rollbacks, deadlocks and conflicts during these runs.

| Resource observation | Native | Docker |
|---|---:|---:|
| Mean guest CPU at 12 / 24 sessions | 98.5% / 98.9% | 98.2% / 98.4% |
| Mean server CPU cores at 24 sessions | 1.83 | 1.72 |
| Mean generator CPU cores at 24 sessions | 0.14 | 0.13 |
| Maximum server proportional memory (PSS) | 183.5 MiB | 193.9 MiB |
| Minimum available guest memory | 2,299.0 MiB | 2,259.6 MiB |

Docker's maximum observed cgroup memory was 539.9 MiB, including charged cache; it is not directly comparable to process PSS. At 24 sessions, mean guest I/O wait was 0.17% native and 0.21% Docker. No swap was configured. Accessible host-process CPU deltas averaged approximately 18–29% of the host's logical CPU capacity during the stages, with at least 15.96 GiB available host memory; these samples do not prove an exclusive or contention-free host.

## What the measurements support

This two-core, 3 GiB configuration completed the tested local chat/file workload without recorded errors. The highest observed message rates were 224.18/s native and 170.16/s Docker. At 12 and 24 sessions, guest CPU was near saturation; adding sessions increased contention and event latency rather than producing proportional throughput. Available memory stayed above 2.2 GiB, so this run did not establish a memory or storage ceiling.

There was one ascending-concurrency run per mode, with growing conversation history, fixed native-then-Docker order and a local generator. There is no repeat-run variance estimate or statistical native-versus-Docker overhead claim. The sessions are not distinct users. Browser rendering, internet latency, login/setup throughput, agent inference, harnesses, SMTP and long-duration operation were outside this workload.

An earlier candidate produced concurrent-message failures. That result is retained separately; D2 includes the observed read-marker race correction and was measured afresh. These successful inputs do not prove arbitrary workloads. Deployment sizing should use representative traffic and the intended host rather than converting these session counts into a user-count promise.
