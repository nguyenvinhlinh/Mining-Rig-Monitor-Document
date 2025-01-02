# 4.4 CPU/GPU Related Features

## Feature 1: Login
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

## Feature 2: Add new cpu/gpu mining rig
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

## Feature 3: Edit CPU/GPU mining rig
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

## Feature 4: Remove cpu/gpu mining rig
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

## Feature 5: View overall cpu/gpu mining rigs

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

This is a list of all data indexs displayed on this page.

- Aggregated Data
    - Total hashrate of all available CPU/GPU mining rig at the moment per crypto currency.
      (pick latest data, group by crypto name, sum hashrate).
    - How many cpu/gpu mining rigs running (pick latest data < 2min, count machine)
    - Total power consumption of all available/running CPU/GPU mining rigs
      (pick latest data, group by crypto name, sum hashrate)

- Individual Data
    - Hashrate
    - Crypto Currency
    - Max CPU Temperature
    - All GPU Core Temperature
    - All GPU Memory Temperature
    - Power Consumption (A sum of all gpu power consumption)
    - Uptime (count since Sentry started)

- Chart
    - Historical hashrate by crypto currency.

This is a wireframe for this feature.

![001. CPU/GPU mining rig index](/images/001-cpu-gpu-rig-index.png)

Aggregated indexs should not abuse Database, we can use GenServer as a cache memory to avoid DB READ. At the time `Commander` insert a new mining log, GenServer update its memory.



## Feature 6: View cpu/gpu mining rig detail

This feature allows user view cpu/gpu mining rig details with realtime update data. All the data is updated in readtime.

- mining rig name
- mining rig specs
- mining operational index: power consumption, hashrate, fan speed
- historical hashrate in chart

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

## 12. Feature 11: Add new playbook (TBD)
## 13. Feature 12: View playbook (TBD)
## 14. Feature 13: View all playbook (TBD)
## 15. Feature 14: Edit playbook (TBD)
## 16. Feature 15: Remove playbook (TBD)
