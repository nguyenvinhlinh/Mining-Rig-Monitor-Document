# Index

## I. Introduction
At first, I am inspired of many mining rig monitor software such as Minerstats, HiveOS, BrainOS. They do good jobs, They really help the community so much, the crypto industry
really appriciate their contribution. In particular, I am a minerstats user, and I love their software! Really cool! This software is an opensource version of Minerstat which
do monitor mining rigs.

For a mining farm, they can selfhost this software and play with it!

If someone could create such a great thing and opensource it (Bitcoin, Monero, Xmrig, Linux kernel, and many many thing ....), yes, this piece of software can be opensource too!

I will try my best to deliver it, and I really hope so! Or it's just another time, I would fail! but it's worth a try!

---
There are two three tiers regarding monitoring mining rigs.

- Commander
- Sentry
- Mining rig:
    - GPU miner
    - CPU miner
    - ASIC miner

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



## II. Features
- Remote control mining rigs cpu/gpu including assign mining software (such as bzminer, lolminer, xmrig...), mining pool, mining address.
- Allow multiple mining software running (cpu miner, gpu miner).
- Monitor cpu/gpu miner.
- Monitor asic miner.

```mermaid
flowchart LR
    User
    cpu-gpu-mining-rig[CPU/GPU Mining Rig]
    asic-mining-rig[ASIC Mining Rig]
    cpu-gpu-playbook[CPU/GPU Playbook]
    cpu-gpu-log[CPU/GPU Log]
    asic-log[ASIC Log]

    User --> f1[1. Login]

    User --> f2[2. Add new cpu/gpu mining rig]
    f2 --> cpu-gpu-mining-rig

    User --> f3[3. Remove cpu/gpu mining rig]
    f3 --> cpu-gpu-mining-rig

    User --> f4[4. Add new ASIC mining rig]
    f4 --> asic-mining-rig

    User --> f5[5. Remove ASIC mining rig]
    f5 --> asic-mining-rig

    User --> f6[6. View overall cpu/gpu mining rig with index page]
    f6 --> cpu-gpu-mining-rig

    User --> f7[7. View overall ASIC mining rig with index page]
    f7 --> asic-mining-rig

    User --> f8[8. View cpu/gpu mining rig detail]
    f8 --> cpu-gpu-mining-rig

    User --> f9[9. View ASIC mining rig detail]
    f9 --> asic-mining-rig


    cpu-gpu-mining-rig --> f10[10. Add new playbook]
    f10 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f11[11. View  playbook]
    f11 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f12[12. View  all playbooks]
    f12 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f13[13. Edit playbook]
    f13 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f14[14. Remove playbook]
    f14 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f15[15. View log]
    f15 --> cpu-gpu-log

    asic-mining-rig --> f16[16. View log]
    f16 --> asic-log
```

## III. System Design and Architecture
### 1. Data payload processing

The `commander` will be a web server program. Enduser using `commander` will need to open it with web browser such as google chrome, firefox. `cpu/gpu sentry` will be deploy on `cpu/gpu miner`.
On the other hand, `asic sentry` which monitor many `asic miner` will be deployed on an different machine, but in the same network as `asic miner` to make sure that it can collect data from `asic miner`.

```mermaid
flowchart TB
    relational-database[(Relational DB)]
    mq-database[(Message Queue)]
    commander[Commander - Web Server]
    sentry-cpu-gpu[CPU/GPU Sentry]
    sentry-asic[ASIC Sentry]

    relational-database --> commander
    mq-database --> commander
    commander --> sentry-cpu-gpu
    commander --> sentry-asic
```

Sentry collect logging data from miner, then send to the commander, and it's huge. Due to this amount of data, there is a message queue play as
an intermediate storage before storing in relational database. There are two different data flows:

- Receive logging data and insert into message queue
- Ingest data from message queue and update/insert into relational database.

Regarding communication between `commander` and `sentry`. it's important to secure network via HTTPS. Miners' logging data is sensitive.


```mermaid
---
title: Receive logging data and write to message queue
---
sequenceDiagram
    Sentry ->> Miner: collect logging data
    Sentry ->> Commander: send logging data
    Commander ->> Message Queue: write data
    Message Queue -->> Commander: OK
    Commander -->> Sentry: OK
```

```mermaid
---
title: Ingest data from the message queue
---
sequenceDiagram
    Commander ->> Message Queue: take new message
    Message Queue -->> Commander: new message
    Commander ->> Relational DB: Insert/Update data
    Relational DB -->> Commander: OK
```

### 2. Realtime update
In addition, for each user viewing `commander` dashboard, there is socket connection alive. This technique supports realtime update.

```mermaid
---
title: Realtime update data
---
sequenceDiagram
    Web Browser ->> Commander: monitor a miner via web browser.
    Commander -->> Web Browser: setup a websocket connection, OK

    Commander ->> Relational DB: update new data
    Relational DB -->> Commander: OK
    Commander ->> Web Browser: new data
    Web Browser ->> Web Browser: Update DOM
```

### 3. Setup a sentry for asic miners
User need to install `ASIC Sentry` on a computer first! In addition, make sure that this computer can ping other `asic miners`
```mermaid
sequenceDiagram
    User ->> Commander: Create a new sentry type `asic` on commander dashboard
    Commander ->> Database: Save new asic mining rig
    Database -->> Commander: OK
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

### 4. Setup sentry for cpu/gpu miners

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

### 5. Can asic sentry update mining pool/mining address?
No, the asic API is **private**, asic sentry can collect log from `asic miner`and send it to the `commander` only.

### 6. How does user update mining software/pool/address on cpu/gpu miner?
Given that user did setup cpu/gpu sentry on machine!

#### 6.1 User create mining pool address & mining address in Templates
```mermaid
sequenceDiagram
    User ->> Commander: Go to template config
    User ->> Commander: Create a new pool adress & mining address
    Commander -->> User: OK
```

#### 6.2 User configure playbooks for miner.
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


## IV. Implementation Details
### 1. Entity Relationship Diagram
```mermaid
erDiagram
    ASIC-Mining-Rig ||--o{ ASIC-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ CPU-GPU-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ Playbook : "has many"
    Playbook
    Address
    Mining-Software

```

### 2. Database diagram

```mermaid
erDiagram
    ASIC-Mining-Rig ||--o{ ASIC-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ CPU-GPU-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ Playbook : "has many"


    Address {
        string type "ex: pool/crypto"
        string address
    }

    Playbook {
        string miner_software
        string template
    }

    Mining-Software {
        string name
        string version
        string download_url
        string executable_template
    }

    ASIC-Mining-Rig {
        string firmware_version
        string software_version
        string model
        string model_variant
    }

```


## V. Testing and Validation
