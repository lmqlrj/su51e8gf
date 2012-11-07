su51e8gf
========

log # definition:

    9      00      0       00

  type  project module#  log#
verilog su51e8gf 0:top
                 1:localbus
                 2:i2c
                 3:intterupt
                 4:clock
                 5:sfp
                 6:led

branches and name convention:

[master]  release code, tag at release version, e.g. 1.0.
[dev]     daily development on this branch.
[feature] branch temporarily from and back to dev, named after function, e.g. feature/print.
[rc]      release candidate, branch from dev temporarily, back to dev and master, named by rc number, e. g. rc/1.0
[hotfix]  branch from dev or master as needed, back to dev and master. named after bug number, e. g. hotfix/r1021

branch digram

             0.1         0.2                                     0.5                                            0.6
master========0===========0=======================================0=====================0========================0
              |\         /                                       /                     /                        /
              | \       /                                       /                     /                        /
              |  \     /                                       /                     /                        /
hotfix        |   0---0 hotfix/r1021                          /                0----0  hotfix/r1030          /
              |        \                                     /                /      \                      /
              |         \                                   /                /        \                    /
              |          \                   rc/0.5        /                /          \           rc/0.6 /
rc            |           \                  0--0---0--0--0                /            \          0--0--0
              |            \                / bug fix only \              /              \        /       \
              |             \              /                \            /                \      /         \
              |              \            /                  \          /                  \    /           \
dev           0===0===0===0===0====0=====0==0===0====0====0===0====0===0==0====0====0==0====0==0==0====0=0===0====>
                  |\              /                   \                       /               /
                  | \            /                     \                     /               /
                  |  \          /                       \                   /               /
feature           |   0--0--0--0 feature/print           0---0-----0----0--0 feature/swap  /
                  |                                                                       /
feature           0--0---0----0--0----0-----0--0---0--------0---0---------0----0---------0
                        feature/display

time---------------------------------------------------------------------------------------------------------------->

