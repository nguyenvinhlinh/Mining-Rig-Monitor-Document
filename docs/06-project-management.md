---
hide:
  - navigation
  - toc
---

# 6. Project management

``` mermaid
gantt
    title Mining Rig Monitor
    dateFormat YYYY-MM-DD

    section Document
        draft specification  docs      :done, wsd, 2024-12-26, 20d
        draft infrastructure docs      :done, wid, after wsd, 5d
    section DEV Infrastructure
        setup woodpecker as CI,        :done, swci, after wid, 2d
        setup vsftp server             :done, svsftp, after swci, 2d
        setup spec. docs server        :done, ssds, after svsftp, 2d
        setup infra. docs server       :done, sids, after ssds, 2d


        setup Commander server using yum :done, scs, 2025-01-24, 2025-02-04
        setup Sentry server using yum    :done, sss, 2025-01-31, 2025-02-05
        setup rpm repo server,           :srps, after sss, 1w
        setup CD for Commander Server    :scdcs, after srps, 1w
        setup CD for Sentry Server       :scdss, after scdcs, 1w
    section Commander Features
        feature  1. Login              :done, f01, 2025-01-01, 3d

        feature  7. Add new asic       :done, f07, after f01, 1w
        feature  8. Remove asic        :done, f08, after f07, 1w
        feature  9. View asic index    :done, f09, 2025-01-11, 2025-01-13
        feature 10. view asic detail   :done, f10, 2025-01-13, 2025-01-15
        unit test for milestone 1      :done, ut1, 2025-01-15, 2025-01-23

        Milestone 1.0 ASIC:            milestone, m1, 2025-01-23, 4m

        feature 2. add new cpu/gpu rig    :f02, after scs, 1w
        feature 3. edit cpu/gpu rig       :f03, after f02, 1w
        feature 4. remove cpu/gpu rig     :f04, after f03, 1w
        feature 5. view cpu/gpu rig index :f05, after f04, 1w

        Milestone 2.0 CPU/GPU: milestone, m2, after f05, 2m

        feature 11. add new playbook for cpu/gpu rig  :f11, after f05, 1w
        feature 12. view playbook                     :f12, after f11, 1w
        feature 13. view all playbook                 :f13, after f12, 1w
        feature 14. edit playbook                     :f14, after f13, 1w
        feature 15. remove playbook                   :f15, after f14, 1w

    section Sentry(ASIC) Features
        feature 1. Assign ASICs to Sentry    :done, aats, 2025-01-15, 2025-01-21
        feature 2. Collect log from ASICs    :done, clfa, 2025-01-20, 2025-01-21
        feature 3. Send log to Commander     :done, sltc, 2025-01-21, 2025-01-22

    section Sentry(CPU/GPU) Features
        feature Y. Assign rig to sentry    :fy, after f05, 1w
        feature Y+1. Collect log from rig  :fy1, after fy, 1w
        feature Y+2. Send log to Commander :fy2, after fy1, 1w

```
