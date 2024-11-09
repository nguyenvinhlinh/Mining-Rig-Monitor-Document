# Index

## Abstract
At first, I am inspired of many mining rig monitor software such as Minerstats, HiveOS, BrainOS. They do good jobs, They really help the community so much, the crypto industry
really appriciate their contribution. In particular, I am a minerstats user, and I love their software! Really cool! This software is an opensource version of Minerstat which
do monitor mining rigs.

For a mining farm, they can selfhost this software and play with it!

If someone could create such a great thing and opensource it (Bitcoin, Monero, Xmrig, Linux kernel, and many many thing ....), yes, this piece of software can be opensource too!

I will try my best to deliver it, and I really hope so! Or it's just another time, I would fail! but it's worth a try!

---
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

## Features
- Remote control mining rigs cpu/gpu including assign mining software (such as bzminer, lolminer, xmrig...), mining pool, mining address.
- Allow multiple mining software running (cpu miner, gpu miner).
- Monitor asic miner.
- Integration with solar inverter. (Questionable)
- Scheduling mining software (cpu/gpu) to support mining with solar energy.
- Scheduling  asic miner to support mining with solar energy.

## How to setup a sentry for asic miners?

```mermaid
sequenceDiagram
    User ->> Commander: Create a new sentry type `asic` on commander dashboard
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

## How to setup sentry for cpu/gpu miners?

```mermaid
sequenceDiagram
    User ->> Commander: Create a new sentry type `cpu/gpu` on commander dashboard
    Commander -->> User: Commander URL & Sentry Token

    User ->> Miner: Install sentry software on miner
    User ->> Miner: Open Sentry software

    User ->> Sentry: Input Commander URL & Sentry Token
    Sentry->>Commander: Check Commander URL & Sentry Token
    Commander-->>Sentry: OK
    Sentry-->>User: OK
```

## Can asic sentry update mining pool/mining address?
No, the asic API is **private**, asic sentry can collect log from `asic miner`and send it to the `commander` only.

## How does user update mining software/pool/address on cpu/gpu miner?
Given that user did setup cpu/gpu sentry on machine!

### User create mining pool address & mining address in Templates
```mermaid
sequenceDiagram
    User ->> Commander: Go to template config
    User ->> Commander: Create a new pool adress & mining address
    Commander -->> User: OK
```

### User configure playbooks for miner.
The term `playbooks` I borrow from ansible.
```mermaid
sequenceDiagram
    User ->>Commander: Go to cpu/gpu miner section
    User ->>Commander: Create a new playbooks
    Commander -->> User: return mining software list
    User ->>Commander: User choose mining software
    Commander -->> User: return script template with placeholder for pool address, mining address.
    User ->> Commander: modify script, choose pool address, mining address variable and Submit
    Commander -->> User: OK

    loop every minute
        Sentry ->> Commander: regularly check for new playbook
        alt is new playbook avaiable
            Commander -->> Sentry: Yes, there is new playbook
            Sentry ->> Commander: Get the latest playbooks
            Commander -->> Sentry: new playbooks
            Sentry ->> Miner: stop all playbooks
            Miner -->> Sentry: OK
            Sentry ->> Miner: remove all playbooks
            Miner -->> Sentry: OK
            loop for each new playbook
                Sentry ->> Miner: install mining software if not available
                Sentry ->> Miner: Write bat/shell script to execute
            end
            loop for each playbook
                Sentry ->> Miner: execute playbook
                Miner -->> Sentry: OK
            end
        else is no new playerbook
            Commander -->> Sentry: No
        end
    end
```
