# 4.2 Pubsub channel summary
This software support rich UI/UI realtime update & interaction shared between all active login session. As a consequence, this is a list of pubsub channel.


- `flash_index`: for broadcast flash messages

## CPU/GPU miner pubsub channels

- `cpu_gpu_miner_index`
- `cpu_gpu_miner_index_operation_stats`
- `cpu_gpu_miner:id`
- `cpu_gpu_miner_operation_stats:id`


## ASIC miner pubsub channels

- `asic_miner_index_channel`
- `asic_miner_index_operational_channel`

- `asic_miner_id:id`
- `asic_miner_operation_stats_id:id`

```mermaid
flowchart LR
    flash_index[pubsub: flash_index]

    cpu_gpu_miner_index[pubsub: cpu_gpu_miner_index]
    cpu_gpu_miner_index_operation_stats[pubsub:cpu_gpu_miner_index_operation_stats]
    cpu_gpu_miner_id[pubsub: cpu_gpu_miner:id]
    cpu_gpu_miner_operation_stats_id[pubsub: cpu_gpu_miner_operation_stats:id]

    asic_miner_index[pubsub: asic_miner_index]
    asic_miner_aggregated_index[pubsub: asic_miner_index_operation_stats]
    asic_miner_id[pubsub: asic_miner_id:id]
    asic_miner_operation_stats_id[pubsub: asic_miner_operation_stats_id:id]

    cpu_gpu_index_page[CPU/GPU index page]
    cpu_gpu_show_page[CPU/GPU show page]

    asic_index_page[ASIC index page]
    asic_show_page[ASIC show page]


    cpu_gpu_miner_index --> cpu_gpu_index_page
    cpu_gpu_miner_index_operation_stats --> cpu_gpu_index_page
    cpu_gpu_miner_id --> cpu_gpu_show_page
    cpu_gpu_miner_operation_stats_id --> cpu_gpu_show_page

    asic_miner_index --> asic_index_page
    asic_miner_index_operation_stats --> asic_index_page
    asic_miner_id --> asic_show_page
    asic_miner_operation_stats_id --> asic_show_page
```
