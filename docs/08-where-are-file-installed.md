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

## Systemd service
## Firewall service
