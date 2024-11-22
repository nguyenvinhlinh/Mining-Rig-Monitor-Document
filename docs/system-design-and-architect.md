# System Design and Architecture
## 1. Data payload processing

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

## 2. Realtime update
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

## 3. Setup a sentry for asic miners
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

## 5. Can asic sentry update mining pool/mining address?
No, the asic API is **private**, asic sentry can collect log from `asic miner`and send it to the `commander` only.

## 6. How does user update mining software/pool/address on cpu/gpu miner?
Given that user did setup cpu/gpu sentry on machine!

### 6.1 User create mining pool address & mining address in Templates
```mermaid
sequenceDiagram
    User ->> Commander: Go to template config
    User ->> Commander: Create a new pool adress & mining address
    Commander -->> User: OK
```

### 6.2 User configure playbooks for miner.
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
