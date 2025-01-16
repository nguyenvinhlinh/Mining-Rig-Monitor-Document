# Where are files installed?
Manual installation should follow this guide. This is applied for `yum install` also.

After build release `MIX_ENV=prod mix release`, copy `./mining_rig_monitor/_build/prod/rel/mining_rig_monitor` to `/opt/mining_rig_monitor`.

```shell
➜ rel (milestone-1-cleanup) ✗ tree -L 1 mining_rig_monitor
mining_rig_monitor
├── bin
├── erts-15.0
├── lib
└── releases
```

## Systemd `/etc/systemd/system/mining_rig_monitor.service`
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

## Systemd environment file `/opt/mining_rig_monitor/.mining_rig_monitor.env`
```text
SECRET_KEY_BASE=
DATABASE_URL=ecto://USER:PASS@HOST/database
PORT=4000
PHX_HOST=127.0.0.1
```

## Firewall service (TBD)
Under nginx reverse proxy!
