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
