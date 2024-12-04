# 4a. Pubsub channel summary
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
