# 2. Feature List
- Remote control mining rigs cpu/gpu including assign mining software (such as bzminer, lolminer, xmrig...), mining pool, mining address.
- Allow multiple mining software running (cpu miner, gpu miner).
- Monitor cpu/gpu miner.
- Monitor asic miner.
- The UI is heavily interactive between many active login session.

```mermaid
flowchart LR
    User
    cpu-gpu-mining-rig[CPU/GPU Mining Rig]
    asic-mining-rig[ASIC Mining Rig]
    cpu-gpu-playbook[CPU/GPU Playbook]



    User --> f1[1. Login]

    User --> f2[2. Add new cpu/gpu mining rig]
    f2 --> cpu-gpu-mining-rig

    User --> f3[3. Edit cpu/gpu mining rig]
    f3 --> cpu-gpu-mining-rig

    User --> f4[4. Remove cpu/gpu mining rig]
    f4 --> cpu-gpu-mining-rig

    User --> f5[5. View overall cpu/gpu mining rigs]
    f5 --> cpu-gpu-mining-rig

    User --> f6[6. View cpu/gpu mining rig detail]
    f6 --> cpu-gpu-mining-rig


    User --> f5x[7. Add new ASIC mining rig]
    f5x --> asic-mining-rig

    User --> f6x[8. Remove ASIC mining rig]
    f6x --> asic-mining-rig

    User --> f8[9. View overall ASIC mining rig with index page]
    f8 --> asic-mining-rig


    User --> f10[10. View ASIC mining rig detail]
    f10 --> asic-mining-rig


    cpu-gpu-mining-rig --> f11[11. Add new playbook]
    f11 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f12[12. View  playbook]
    f12 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f13[13. View  all playbooks]
    f13 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f14[14. Edit playbook]
    f14 --> cpu-gpu-playbook

    cpu-gpu-mining-rig --> f15[15. Remove playbook]
    f15 --> cpu-gpu-playbook
```
