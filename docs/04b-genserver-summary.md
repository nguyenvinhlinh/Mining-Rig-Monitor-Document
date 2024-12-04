# 4b. GenServer summary
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



## 1. ASIC Mining Rig Index
- ASIC Mining Rig Index, the GenServer should be named `AsicMiningRigIndex`, it stores latest stats of all mining rig including:
    - hashrate
    - hashrate unit of measurement
    - coin
    - power consumption in walt
    - temperature in celcius

the data structure look like this:

```elixir
%{
  asic_id: %{
             hashrate: 0,
             hashrate_uom: "gh/s",
             coin: "kaspa",
             power_consumption: 1234,
             temperature_list: [sensor1, sensor2, sensor3]
             timestamp: %NaiveDatetime{}
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
