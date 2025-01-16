# 4.3 GenServer summary
This is a list of GenServer process support aggregate data.

- ASIC Mining Rig Index:


- ASIC Mining Rig Historical Index: the same as `ASIC Mining Rig Index` but store in array.


- CPU/GPU Mining Rig Index:
    - store latest stats of all mining rig including: hashrate, algo., power consumption, temperature.
    - store aggregated indexs of all mining rig including: total hashrate by algo, total power consumption.


!!!Note "Why do we need extra layer of data, DB is enough?"

    Due to remove/update stats  feature (asic/cpu/gpu) & aggregate indexs, there will be many READ operation from database.
    Plus, there are many many operational logs sending to the Commander. Even though, we have message queue, but
    the pressure is real for one single database.

    This is a scenerio that we use extra layer, we want to render asic mining rig index  page with aggregated number such as total hashrate.
    (1) We need to query the db for all available asic. ( condition less than 30-second-ping alive)
    (2) Sum all the hashrate
    If we have new operational data inserted into database, to calculate the total hashrate, we then need to start over from step (1).



## 1. ASIC Miner Operational Index
- ASIC Mining Rig Index, the GenServer should be named `AsicMinerOperationalIndex`, it stores data in a map.
The key is `asic_miner_id`, and value is `AsicMinerLog`.
- Found source code here: [github link](https://github.com/nguyenvinhlinh/Mining-Rig-Monitor/blob/dev/lib/mining_rig_monitor/gen_server/asic_miner_operational_index.ex)


Beside storing latest state, `AsicMiningRigIndex` GenServer also can do:

- remove old operational data. An asic with latest record is older than current timestamp by 1 minutes should be remove. The asic is consider offline/dead.
- when the `AsicMinerOperationalIndex`  get update, `AsicMiningRigIndex` GenServer will do broadcast **(NOT IMMEDIATELY)** to pubsub channel named:
    - `asic_miner_index`
    - `asic_miner_aggregated_index`
    - The main reason that `AsicMinerOperationalIndex` does not broadcast instantly, it will spam the socket channel from `commander` to `web browser`.


`GenServer-AsicMinerOperationalIndex`'s state example:

```elixir
%{
    asic_miner_id => %AsicMinerLog{}
}
```

In addition, **each one second**, this `GenServer-AsicMinerOperationalIndex`  will broadcast operational data. This is an example:
```elixir
%{
      asic_miner_map: %{asic_miner_id => %AsicMiner{} },
      asic_miner_operational_map: %{asic_miner_id => %AsicMinerLog{} },
      asic_miner_aggregated_index: %{
          coin_hashrate_map: %{"Bitcoin" => {120, "TH/s"},
                               "Kaspa" => {20, "TH/s"}
                              },
          total_power: 7000,
          asic_miner_alive: "2/3"
      }
}
```




## 2. ASIC Mining Rig Historical Index
GenServer should be named `AsicMiningRigHistoricalIndex`, the data structure look similar to `AsicMiningRigIndex` but store in `List`.



```elixir
%{
  asic_id: [%{
             hashrate: 0,
             hashrate_uom: "gh/s",
             coin: "kaspa",
             power_consumption: 1234,
             temperature_list: [sensor1, sensor2, sensor3]
             timestamp: %NaiveDatetime{}
            }]
}
```

!!!Note "Adding new element to list - performance issue"

    it's a linked list, as a consequence, add element to the index 0 is the fastest way!
    For example, we have t1, t2, t3, t4! the greater, the latest!

    We gonna store like: [t4, t3, t2, t1]

    --> list = [t3, t2, t1]

    --> [t4 | list]

## 3. CPU/GPU Mining Rig Index
## 4. CPU/GPU Mining Rig Historical Index
