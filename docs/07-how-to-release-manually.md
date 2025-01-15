# How to make release?

Go to source code directory
```shell
cd /home/nguyenvinhlinh/Projects/mining_rig_monitor;
```

Set the environment variables:

```shell
mix phx.gen.secret
REALLY_LONG_SECRET

export SECRET_KEY_BASE=REALLY_LONG_SECRET
export DATABASE_URL=ecto://USER:PASS@HOST/database
```

Then load dependencies to compile code and assets:

```shell
# Fetch and compile
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
MIX_ENV=prod mix assets.deploy
```

And now run `mix phx.gen.release` **(RUN 1 TIME ONLY, IT WILL MODIFY EXISTING FILES release.ex...)**:

```shell
➜ mining_rig_monitor (milestone-1-cleanup) ✗ mix phx.gen.release
* creating rel/overlays/bin/server
* creating rel/overlays/bin/server.bat
* creating rel/overlays/bin/migrate
* creating rel/overlays/bin/migrate.bat
* creating lib/mining_rig_monitor/release.ex

Your application is ready to be deployed in a release!

See https://hexdocs.pm/mix/Mix.Tasks.Release.html for more information about Elixir releases.

Here are some useful release commands you can run in any release environment:

    # To build a release
    mix release

    # To start your system with the Phoenix server running
    _build/dev/rel/mining_rig_monitor/bin/server

    # To run migrations
    _build/dev/rel/mining_rig_monitor/bin/migrate

Once the release is running you can connect to it remotely:

    _build/dev/rel/mining_rig_monitor/bin/mining_rig_monitor remote

To list all commands:

    _build/dev/rel/mining_rig_monitor/bin/mining_rig_monitor

```

Finally, run `MIX_ENV=prod mix release`

```shell
➜ mining_rig_monitor (milestone-1-cleanup) ✗ mix phx.gen.release
Generated mining_rig_monitor app
* assembling mining_rig_monitor-0.1.0 on MIX_ENV=prod
* using config/runtime.exs to configure the release at runtime

Release created at _build/prod/rel/mining_rig_monitor

    # To start your system
    _build/prod/rel/mining_rig_monitor/bin/mining_rig_monitor start

Once the release is running:

    # To connect to it remotely
    _build/prod/rel/mining_rig_monitor/bin/mining_rig_monitor remote

    # To stop it gracefully (you may also send SIGINT/SIGTERM)
    _build/prod/rel/mining_rig_monitor/bin/mining_rig_monitor stop

To list all commands:

    _build/prod/rel/mining_rig_monitor/bin/mining_rig_monitor

```


Now, this is the release directory, `_build/prod/rel/mining_rig_monitor`
```shell
➜ mining_rig_monitor ✗ tree -L 1 _build/prod/rel/mining_rig_monitor
_build/prod/rel/mining_rig_monitor
├── bin
├── erts-15.0
├── lib
└── releases
```

You can visit this [page](../09-How-to-deploy-manully/) to deploy manually!


Reference:

- [https://hexdocs.pm/phoenix/releases.html](https://hexdocs.pm/phoenix/releases.html)
