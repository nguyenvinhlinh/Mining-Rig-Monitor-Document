# 4d. ASIC Related Features

## Feature 7: Add new ASIC mining rig
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


## Feature 8: Remove ASIC mining rig
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

## Feature 9: View overall ASIC mining rig with index page
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

This is a wireframe for asic mining rig index.
![002. ASIC mining rig index](/images/002-asic-rig-index.png)

## Feature 10: View ASIC mining rig detail
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

This is a wireframe when sentry finished sending data to `Commander`.
![3. ASIC Rig Index](/images/003-asic-rig-index.png)