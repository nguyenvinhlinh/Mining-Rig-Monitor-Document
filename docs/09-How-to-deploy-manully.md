# How to deploy manually?

[1] Copy from release directory `prod/rel/mining_rig_monitor` to `/opt/mining_rig_monitor`.

```
$ cp ./mining_rig_monitor/_build/prod/rel/mining_rig_monitor /opt/ -rfv
```

[2] Directory structure of`/opt/mining_rig_monitor`:
```shell
➜ mining_rig_monitor (milestone-1-cleanup) ✗ tree -L 1 /opt/mining_rig_monitor
/opt/mining_rig_monitor
├── bin
├── erts-15.0
├── lib
└── releases
```

[3] Create a postgresql database with (**Docker/Compose/Dbeaver...**)

[3] Test run with script before working with **systemd service**.

```
export SECRET_KEY_BASE=Mc5oIum6N8aeNdjghwfJQYVE2OQncnqBkCCyaXdA1X/puugR99VvcSuvAqOoGYdW
export DATABASE_URL=ecto://USER:PASS@HOST/database
export PHX_HOST=127.0.0.1

# To migrate db
/opt/mining_rig_monitor/bin/migrate

# To start server
/opt/mining_rig_monitor/bin/server

# To stop server
/opt/mining_rig_monitor/bin/mining_rig_monitor stop
```
