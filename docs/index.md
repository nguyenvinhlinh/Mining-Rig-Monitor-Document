# Index

## Abstract
There are two three tiers regarding monitoring mining rigs.

- commander
- sentry
- mining rig:
    - gpu miner
    - cpu miner
    - asic miner

The source code is focusing on the `commander` and `sentry`.  There is one `commander` for mining farm, and many `sentry`. A sentry is installed on each `gpu miner`/ `cpu miner`. On the other hand, one sentry can monitor many `asic miner`.

```mermaid
flowchart TB
    Commander[Commander]
    Commander --> AsicSentry[ASIC Sentry]
    AsicSentry --> AM1[ASIC Miner 1]
    AsicSentry --> AM2[ASIC Miner 2]

    Commander --> CPUGPUSentry1[CPU/GPU Sentry 1]
    CPUGPUSentry1 -->|installed on| CPUMiner1[CPU Miner 1]

    Commander --> CPUGPUSentry2[CPU/GPU Sentry 2]
    CPUGPUSentry2 -->|installed on| CPUMiner2[CPU Miner 2]

    Commander --> CPUGPUSentry3[CPU/GPU Sentry 3]
    CPUGPUSentry3 -->|installed on| GPUMiner1[GPU Miner 1]

    Commander --> CPUGPUSentry4[CPU/GPU Sentry 4]
    CPUGPUSentry4 -->|installed on| GPUMiner2[GPU Miner 2]


```

Regarding sentry, **sentry source code** for `asic miners` should be diffirent from **sentry** for `cpu/gpu miners`.

One `asic sentry` can monitor many `asic miners`.

One `cpu / gpu sentry` can monitor one `cpu/gpu miner`. **Beware that a machine can mine with CPU and GPU at the sametime.**

When `sentry` get operational data from `miners`, they will report/forward data to the `commander`.

In addition, the diagram above does not represent how we do deploy cause it does not have backup machine for `commander`.


## How to setup a sentry for asic miners?

```mermaid
sequenceDiagram
    User ->> Commander: Create a new sentry on commander dashboard
    Commander -->> User: Commander URL & Sentry Token

    User ->> Sentry: Input Commander URL & Sentry Token
    Sentry->>Commander: Check Commander URL & Sentry Token
    Commander-->>Sentry: OK
    Sentry-->>User: OK

    User->>Sentry: ASIC TYPE & ASIC IP
    Sentry->>ASIC: Check ASIC
    ASIC-->>Sentry: OK
    Sentry-->User: OK

```
