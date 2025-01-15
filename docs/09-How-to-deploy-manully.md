# How to deploy manually?

## [1] Copy from release directory `prod/rel/mining_rig_monitor` to `/opt/mining_rig_monitor`.

```
$ cp ./mining_rig_monitor/_build/prod/rel/mining_rig_monitor /opt/ -rfv
```

## [2] Directory structure of`/opt/mining_rig_monitor`:
```shell
➜ mining_rig_monitor (milestone-1-cleanup) ✗ tree -L 1 /opt/mining_rig_monitor
/opt/mining_rig_monitor
├── bin
├── erts-15.0
├── lib
└── releases
```

## [3] Create a postgresql database with (**Docker/Compose/Dbeaver...**)

## [4] Test run with script before working with **systemd service**.

```
export SECRET_KEY_BASE=Mc5oIum6N8aeNdjghwfJQYVE2OQncnqBkCCyaXdA1X/puugR99VvcSuvAqOoGYdW
export DATABASE_URL=ecto://USER:PASS@HOST/database
export PORT=4000
export PHX_HOST=127.0.0.1

# To migrate db
/opt/mining_rig_monitor/bin/migrate

# To start server
/opt/mining_rig_monitor/bin/server
...
00:07:32.076 [notice]     :alarm_handler: {:set, {:system_memory_high_watermark, []}}
00:07:32.090 [info] [AsicMinerOperationalIndex] started.
00:07:32.090 [info] [AsicMinerOperationalIndex][broadcast_operational_data] after 5 seconds
00:07:32.090 [info] [AsicMinerOperationalIndex][nillify_offline_miner] after 5 seconds
00:07:32.100 [info] Running MiningRigMonitorWeb.Endpoint with Bandit 1.5.5 at :::4000 (http)
00:07:32.101 [info] Access MiningRigMonitorWeb.Endpoint at https://127.0.0.1
00:07:35.656 [info] CONNECTED TO Phoenix.LiveView.Socket in 73µs
...


# To stop server
/opt/mining_rig_monitor/bin/mining_rig_monitor stop
```

## [5] Create systemd service `/etc/systemd/system/mining_rig_monitor.service`
```
[Unit]
Description=Mining Rig Monitor
After=network.target

[Service]
WorkingDirectory=/opt/mining_rig_monitor
EnvironmentFile=/opt/mining_rig_monitor/.mining_rig_monitor.env
ExecStart=/opt/mining_rig_monitor/bin/server
ExecStop=/opt/mining_rig_monitor/bin/mining_rig_monitor stop
User=nguyenvinhlinh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## [6] Create environment file `/opt/alephium/.mining_rig_monitor.env`
```text
SECRET_KEY_BASE=
DATABASE_URL=ecto://USER:PASS@HOST/database
PORT=4000
PHX_HOST=127.0.0.1
```

and Run `systemctl daemon-reload`

## [7] Start systemd service named `mining_rig_monitor`
```shell
systemctl enable --now mining_rig_monitor
```

## [8] To view log
```shell
➜ ~ journalctl -f -u mining_rig_monitor.service
server[1361153]: 00:31:18.061 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:19.063 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:20.065 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:21.067 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:22.069 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:23.071 [info] [AsicMinerOperationalIndex][broadcast_operational_data] Starting.
server[1361153]: 00:31:23.754 [info] [AsicMinerOperationalIndex][nillify_offline_miner] Starting.
```
