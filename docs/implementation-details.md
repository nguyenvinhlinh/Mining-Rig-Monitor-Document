# Implementation Details

## 1. Entity Relationship Diagram
```mermaid
erDiagram
    ASIC-Mining-Rig ||--o{ ASIC-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ CPU-GPU-Mining-Log : "has many"
    CPU-GPU-Mining-Rig ||--o{ Playbook : "has many"
    Playbook
    Address
    Mining-Software

```

## 2. Database diagram

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

## 3. Pubsub channel summary
This software support rich UI/UI realtime update & interaction shared between all active login session. As a consequence, this is a list of pubsub channel.

- `cpu-gpu-mining-rig-index`
- `cpu-gpu-mining-rig-index-operation-stats`
- `cpu-gpu-mining-rig:id`
- `cpu-gpu-mining-rig-operation-stats:id`

- `asic-mining-rig-index`
- `asic-mining-rig-index-operation-stats`
- `asic-mining-rig-id:id`
- `asic-mining-rig-operation-stats-id:id`

```mermaid
flowchart LR

    cpu-gpu-mining-rig-index[pubsub: cpu-gpu-mining-rig-index]
    cpu-gpu-mining-rig-index-operation-stats[pubsub:cpu-gpu-mining-rig-index-operation-stats]
    cpu-gpu-mining-rig-id[pubsub: cpu-gpu-mining-rig:id]
    cpu-gpu-mining-rig-operation-stats-id[pubsub: cpu-gpu-mining-rig-operation-stats:id]

    asic-mining-rig-index[pubsub: asic-mining-rig-index]
    asic-mining-rig-index-operation-stats[pubsub: asic-mining-rig-index-operation-stats]
    asic-mining-rig-id[pubsuc: asic-mining-rig:id]
    asic-mining-rig-operation-stats-id[pubsub: asic-mining-rig-operation-stats:id]

    cpu-gpu-index-page[CPU/GPU index page]
    cpu-gpu-show-page[CPU/GPU show page]

    asic-index-page[ASIC index page]
    asic-show-page[ASIC show page]


    cpu-gpu-mining-rig-index --> cpu-gpu-index-page
    cpu-gpu-mining-rig-index-operation-stats --> cpu-gpu-index-page
    cpu-gpu-mining-rig-id --> cpu-gpu-show-page
    cpu-gpu-mining-rig-operation-stats-id --> cpu-gpu-show-page

    asic-mining-rig-index --> asic-index-page
    asic-mining-rig-index-operation-stats --> asic-index-page
    asic-mining-rig-id --> asic-show-page
    asic-mining-rig-operation-stats-id --> asic-show-page
```

## 3. Feature 1: Login
The software is selfhost and  does not have user credentials system. At the time sysadmin deploy the `commander`, there is a configuration for **password**.



!!! note "There is no **limit** number of active login session."

```mermaid
sequenceDiagram
    User ->> Web Browser: open
    User ->> Commander: visit commander url
    alt is login before
        Commander -->> Web Browser: redirect to the main dashboard
    else is not log in
        Commander -->> Web Browser: return to login page
        User ->> Web Browser: Enter password & click submit
        Web Browser ->> Commander: submit password

        loop till login success
            alt is password correct
                Commander -->> Web Browser: redirect to the main dashboard
            else is not correct
                Commander -->> Web Browser: return to login page
                User ->> Web Browser: Enter password & submit
                Web Browser ->> Commander: submit password
            end
        end
    end
```

## 4. Feature 2: Add new cpu/gpu mining rig
Login user are capable create a new cpu/gpu mining rig to monitor, There are two required attributes that users need to provide:

- `mining rig name`: should be distinct
- `mining rig type` (cpu/gpu or asic)

On the other hand, server will return `token`. This token will be used when setup sentry after installing `sentry` on the `cpu/gpu mining rig`.

In addition, given that there are many active login session, here are usecase:

- A new asic mining rig created, people who are viewing `asic mining rig index page`, they will see a new entry on their
`asic mining rig index page` without refresh the page.
- For those who are not viewing `asic mining rig index`, they will not see different nor receive that data payload from
commander about the `new asic mining rig` created


```mermaid
sequenceDiagram
    Login-User-1 ->> Commander: viewing cpu/gpu mining rig index (a socket connection)
    Login-User-1 ->> Commander: subscribe to pubsub channel cpu-gpu-mining-rig-index
    Login-User-2 ->> Commander: viewing other page (a socket connection)

    Login-User-3 ->> Commander: request create new mining rig page
    Commander -->> Login-User-3: OK
    Login-User-3 ->> Commander: Submit mining rig name & type
    Commander ->> Database: Add new asic mining rig record
    Database -->> Commander: OK
    Commander -->> Login-User-3: OK

    Commander -->> Commander: boardcast message to pubsub channel asic-mining-rig-index

    Commander ->> Login-User-1: send a message that new asic mining rig created
    Commander ->> Login-User-3: send a message that new asic mining rig created
```

!!! Note "Login-User-2 does not receive message that new asic mining rig created."

The broadcast channel named: `cpu-gpu-mining-rig-index`

Data payload schema: `{:asic_mining_rig_index, :created, mining_rig}`

## 5. Feature 3: Edit CPU/GPU mining rig
This feature allows user edit `mining rig name` only. Similar UI realtime update logic as creating new `cpu/gpu mining rig`. Other active login users get
update if they are viewing `asic-mining-rig-index`.

In the sequence diagram below, we consider Login-User-3 is an entity which include his/her web browser.
```mermaid
sequenceDiagram
    Login-User-1 ->> Commander: request to view cpu/gpu mining index (a socket connection)
    Commander -->> Login-User-1: OK
    Login-User-1 ->> Commander: subscribe to pubsub channel cpu_gpu_mining_rig_index
    Commander -->> Login-User-1: OK

    Login-User-2 ->> Commander: request to view cpu/gpu mining show page (a socket connection)
    Commander -->> Login-User-2: OK
    Login-User-2 ->> Commander: subscribe to pubsub channel cpu_gpu_mining_rig:id
    Commander -->> Login-User-2: OK


    rect rgb(191, 223, 255)
        Login-User-3 ->> Commander: request to view asic mining rig index page
        Commander -->> Login-User-3: return asic mining rig index page
        Login-User-3 ->> Commander: subscribe to pubsub channel cpu_gpu_mining_rig_index
        Login-User-3 ->> Login-User-3: choose a asic mining rig and click Edit
        Login-User-3 ->> Login-User-3: pop-up a form to edit mining rig name
        Login-User-3 ->> Login-User-3: Fill a form
        Login-User-3 ->> Commander: Submit

        loop Loop "form valid"
            alt is form valid
                Commander -->> Login-User-3: OK
            else is form not valid
                Commander --> Login-User-3: return error
                Login-User-3 ->> Login-User-3: fill the form again
                Login-User-3 ->> Commander: submit the form
                Commander ->> Database: update database
                Database -->> Commander: OK
                Commander ->> Commander: broadcast message to pubsub channel cpu_gpu_mining_rig_index
                Commander ->> Commander: broadcast message to pubsub channel cpu_gpu_mining_rig:id

                Commander ->> Login-User-1: send a message that an asic mining rig update
                Login-User-1 -->> Login-User-1: update cpu/gpu mining index

                Commander ->> Login-User-2: send a message that an asic mining rig update
                Login-User-2 -->> Login-User-2: update cpu/gpu mining show page

                Commander ->> Login-User-3: send a message that an asic mining rig update
                Login-User-3 -->> Login-User-3: update cpu/gpu mining mining index
            end
        end
    end
```

There are two pubsub channels involved:

- `cpu_gpu_mining_rig_index`
    - data payload schema for subscriber: `{:cpu-gpu_mining_rig_index, :updated, mining_rig}`
- `cpu_gpu_mining_rig:mining_rig_id`, mining-rig-id is the primary key of cpu/gpu mining rig.
    - data payload schema for subscriber: `{:cpu_gpu_mining_rig:id, :updated, mining_rig}`.

## 6. Feature 4: Remove cpu/gpu mining rig
This feature involves `Commander` and `Sentry`. When user remove `cpu/gpu mining rig` on commander, and `sentry` is setup on mining rig,
`sentry` will do the following actions

- stop all running playbooks
- remove all playbook and mining software such as xmrig, phoenix miner, bzminer ...
- stop sending log to `commander`
- open an UI asking for `token`

```mermaid
sequenceDiagram
Login-User ->> Commander: request to view cpu/gpu mining rig index
Commander -->> Login-User: OK
Login-User ->> Commander: subscribe to cpu_gpu_mining_rig_index
Login-User ->> Login-User: find cpu/gpu mining rig on the UI
Login-User ->> Commander: delete cpu/gpu mining rig
Commander ->> Database: Remove record and its related.
Database -->> Commander: OK
Commander -->> Login-User: OK

Commander ->> Commander: update data  in GenServer cpu-gpu-mining-rig-operational-stats
Commander ->> Commander: broadcast message to pubsub channel cpu_gpu_mining_rig_index
Commander ->> Commander: broadcast message to pubsub channel cpu_gpu_mining_rig:id
Commander ->> Commander: remove pubsub channel cpu_gpu_mining_rig:id

Commander ->> Login-User: send message that remove a cpu/gpu mining rig
Login-User ->> Login-User: update UI

Commander ->> Login-User: send message that update cpu_gpu_mining_rig_operational_stats
Login-User ->> Login-User: update UI
```

!!! Note "GenServer cpu-gpu-mining-rig-index-operational-stats"
    This genserver store aggregate stats of many cpu/gpu mining rigs such as: total hashrate by coin, total power consumption.
    When a mining rig removed, this stats need to be updated.

!!! Note "For active loging user viewing cpu-gpu mining rig detail/show page"
    Cause they are viewing a mining rig which is deleted, they will be redirect to cpu-gpu-mining-rig-index page

## 7. Feature 5: View overall cpu/gpu mining rigs

This feature allows user view overall all cpu/gpu mining rigs (cpu/gpu mining rig index page). This page has realtime update data.
When user visit this page, a socket connection established. on the web framework Phoenix, this socket connection process subscribe to a pubsub
channel

- `cpu-gpu-mining-rig-index`: only for cpu/gpu mining rig
- `cpu-gpu-mining-rig-operational-stats`: only for cpu/gpu mining rig operational stats, such as hashrate, total hashrate by coin,
aggregated stats for all rigs.

```mermaid
sequenceDiagram
    Login-User ->> Commander: Visit cpu/gpu mining rig index
    Commander -->> Login-User: return index page
    Login-User ->> Commander: Setup socket connection
    Commander -->> Login-User: OK
    Commander ->> Commander: process subscribe to pubsub cpu-gpu-mining-rig-index
    Commander ->> Commander: process subscribe to pubsub cpu-gpu-mining-rig-operation-stats
```

## 8. Feature 6: View cpu/gpu mining rig detail

This feature allows user view cpu/gpu mining rig details with realtime update data. All the data is updated in readtime.

- mining rig name
- mining rig specs
- mining operational log: power consumption, hashrate, fan speed

When user visit this page, a socket connection established. On the web framework Phoenix, this socket connection process subscribe to a pubsub
channel
- `cpu-gpu-mining-rig:id`: for mining rig data such as spec, name
- `cpu-gpu-mining-rig-operation-stats:id`: for operational data.

```mermaid
sequenceDiagram
    Login-User ->> Commander: Visit cpu/gpu mining rig
    Commander -->> Login-User: return cpu/gpu mining rig detail page
    Login-User ->> Commander: Setup socket connection
    Commander -->> Login-User: OK
    Commander ->> Commander: process subscribe to pubsub cpu-gpu-mining-rig:id
    Commander ->> Commander: process subscribe to pubsub cpu-gpu-mining-rig-operational-stats:id
```

On this page, if mining rig update (such as rig name), a message will broadcasted to channel `cpu-gpu-mining-rig:id`.

As a subcriber, the listener need to handle these schema in `handle_info/3`
- `{cpu-gpu-mining-rig, :updated, mining_rig}`
- `{cpu-gpu-mining-rig, :deleted, mining_rig}`, if this message received, redirect user to the cpu/gpu mining rig index page.

In addition, if mining rig operational data get updated, a message will be broadcasted to channel `cpu-gpu-mining-rig-operational-stats:id`

- `{cpu-gpu-mining-rig-operational-stats, :created, new_log`

## 8. Feature 7: Add new ASIC mining rig
This feature requried users to do two phrases:

- setup in commander
- setup in sentry

Unlike cpu/gpu mining rig, we cannot install sentry on each asic. There is a machine installed sentry,
and this sentry will fetch logs from many asics.

In this sequence diagram, the `Login-User` does also mean the web browser.
```mermaid
sequenceDiagram
    Login-User ->> Commander: go the asic mining rig index
    Commander -->> Login-User: return page
    Login-User ->> Commander: setup socket connection
    Commander -->> Commander: subscribe to pubsub asic-mining-rig-index

    Login-User ->> Login-User: click on Create, a dialog open
    Login-User ->> Login-User: enter asic mining rig name
    Login-User ->> Commander: submit
    Commander -->> Login-User: OK
    Commander ->> Commander: broadcast message that new mining rig created
    Commander ->> Login-User: send new created mining rig + token
    Login-User ->> Login-User: Receive
    Login-User ->> Login-User: update UI
```

On the sentry side, user needs to know asic IP first. After that, in the sentry UI, add

- ASIC IP
- ASIC Model (required to determine fetching log solution)
- ASIC Token: provide in the first phrase.


## 9. Feature 8: Remove ASIC mining rig
This feature remove mining rig from dashboard to monitor. On the senry side, the mining rig still exist, but dislay an invalid token.

```mermaid
sequenceDiagram
    Login-User ->> Commander: Go to asic mining rig index
    Commander -->> Login-User: return page
    Login-User ->> Commander:  Setup socket connection
    Commander -->> Login-User: OK
    Commander ->> Commander: subscribe to pubsub asic-mining-rig-index
    Commander ->> Commander: subscribe to pubsub asic-mining-rig-operaional-stats

    rect  rgb(191, 223, 255)
        Login-User ->> Login-User: choose an asic mining rig
        Login-User ->> Commander: send delete request a mining rig
        Commander ->> Database: Delete involve records
        Database -->> Commander: OK
        Commander ->> Login-User: OK, deleted
        Commander ->> Commander: broadcast to asic-mining-rig-index
        Commander ->> Login-User: send message a asic mining rig deleted
        Login-User ->> Login-User: Update UI
    end

    rect  rgb(191, 223, 255)
        Commander ->> Commander: broadcast to asic-mining-rig:id , that delete a rig
        Commander ->> Another-Login-User: send message current watching rig is deleted
        Another-Login-User ->> Another-Login-User: redirect to asic index page.
    end

    Commander ->> Commander: GenServer asic-mining-rig-operational-stats recalculate

    rect rgb(191, 223, 255)
        Commander ->> Commander: broadcast to asic-mining-rig-operation-stats for the update
        Commander ->> Login-User: send stats update
        Login-User -->> Login-User: update UI
    end
```

## 10. Feature 9: View overall ASIC mining rig with index page
This feature allows users to view asic mining rig overview, and view aggregate figures such as total hashrate by coin, power consumption.

```mermaid
sequenceDiagram
    Login-User ->> Commander: request to view asic-mining rig index
    Commander -->> Login-User: return html asic-mining-rig-index page
    Login-User ->> Commander: setup web socket connection
    Commander ->> Commander: subscribe to the pubsub asic-mining-rig-index
    Commander ->> Commander: subscribe to the pubsub asic-mining-rig-operation-stats
    Commander -->> Login-User: OK
```

There are two pubsub channel that we use here:
- `asic-mining-rig-index`: to receive message incase of create/update/delete asic mining rig
- `asic-mining-rig-operation-stats`: to receive message about minining operation such as total hashrate, power consumption, temperature.



!!! Note "The pubsub channel does not store data. The real data is store in `GenServer` process, these process be update as sentry send data to `Commander`."

## 11. Feature 10: View ASIC mining rig detail
```mermaid
sequenceDiagram
    Login-User ->> Commander: request to view asic-mining rig detail page, /asics/:id
    Commander -->> Login-User: return asic-mining-rig detail page
    Login-User ->> Commander: setup web socket connection
    Commander ->> Commander: subscribe to the pubsub asic-mining-rig:id
    Commander ->> Commander: subscribe to the pubsub asic-mining-rig-operation-stats:id
    Commander -->> Login-User: OK
```

There are two pubsub channel using here:
- `asic-mining-rig:id`: for mining rig data update, such as name
- `asic-mining-rig-operation-stats:id`: for mininig operational stats

## 12. Feature 11: Add new playbook (TBD)
## 13. Feature 12: View playbook (TBD)
## 14. Feature 13: View all playbook (TBD)
## 15. Feature 14: Edit playbook (TBD)
## 16. Feature 15: Remove playbook (TBD)
