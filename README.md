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


                                tracking dev                                     tracking master
           feature/*                 |         hotfix/*             rc/*               |
                                     |                                                 |
                                     |                                                 |
                                     o                                                 |
                                    /|                                                 |
                                   / |                                                 |
                                  /  |                                                 | 
                                 /   o                                                 |
                                /   /|                                                 |
                               /   / |                                                 |
                              o   o  o                                                 |
                              |   |  |\                                                |
                              |   |  | \                                               |
                              |   |  |  \                                              |
                              |   o  |   \                                             |
                              |    \ |    \                                            |
                              |     \|     \                                           |
                              |      o      \                                          |
                              |      |       \                                         |
                              |      |        \                                        |
                              |      o         \                                       |
                              |     /|          \                                      |
                              |    / |           \                                     |
                              |   o  |            o  hotfix/bug/*                      |
                              |   |  |            |                                    |
                              |   |  |            |                                    |
                  feature/*   |   |  |            |                                    |
                              |   |  |            |                                    |
                              |   o  |            |                                    |
                              |    \ |            o                                    |
                              o     \|            |                                    |
                               \     o            |                                    |
                                \    |            o                                    |
                                 \   |            |                                    |
                                  \  |            |                                    |
                                   \ |            |                                    |
                                    \|            o                                    |
                                     o           / \                                   |
                                     |          /   \                                  |
                                     |         /     \                                 o
                                     o        /       \                               /|
                                    /|       /         \                             / |
                                   / |      /           \                           /  |
                                  /  |     /             \                         /   |
                                 o   |    /               \                       /    |
                                 |   |   /                 \                     /     |
                                 |   |  /                   \                   /      |
                                 |   | /                     \                 /       |
                                 o   |/                       \               /        |
                                  \  o                         \             /         |
                                   \ |                          \           /          |
                                    \|                           \         /           |
                                     o                            \       /            |
                                     |                             \     /             |
                                     |                              \   /              |
                                     |                               \ /               |
                                     |       merge bugfix to rc/*     O                |
                                     |                                |                |
                                     |                                |                |
                                     |                                o                |
                                     |                               /|                |
                                     |                              / |                |
                                     |                             /  |                |
                                     |                            /   |                |
                                     |                           /    |                |
                                     |                          /     |                |
                                     |                         /      |                |
                                     |                        /       |                |
                                     |                       /        |                |
                                     |                      /         |                |
                                     |                     /          |                |
                                     |                    /           |                |
                                     |                   /            |                |
                                     |                  /             |                |
                                     |                 /              |                |
                                     |                /               |                |
                                     |               /                |                |
                                     |              /                 |                |
                                     |             /                  |                |
                                     |            O                   |                |
                                     |            |                   |                |
                                     |            |  fix bugs on rc/* |                |
                                     |            O                   |                |
                                     |            |                   |                |
                                     |            O                   |                |
                                     |            |                   |                |
                                     |            |                   |                |
                                     |            |                   |                |
                                     |            o                   |                |
                                     |           /|                   |                |
                                     |          / O                   |                |
                                     |         / /|                   |                |
                                     |        / / o merge fix to dev  |                |
                                     |       / / /|                   |                |
                                     |      / / / |                   |                |
                                     |     / / /  o                   |                |
                                     |    / / /  / \                  |                |
                                     |   / / /  /   \                 |                |
                                     |  / / /  /     \                |                |
                                     | / / /  /       \               |                |
                                     |/ / /  /         \              |                |
                                     o / /  /           \             |                |
                                     |/ /  /             \            |                |
                                     o /  /               \           |                |
                                     |/  /                 \          |                |
                                     o  /                   \         |                |
                                     | /                     \        |                |
                                     |/                       \       |                |
                                     o                         \      |                |
                                     |                          \     |                |
                                     |                           \    |                |
                                     |                            \   |                |
                                     |                             \  |                |
                                     |                              \ |                |
                                     |                               \|                |
                                     |       merge fix back to rc/*   o                |
                                     |                                |                |
                                     |                                |                |
                                     |                                O                |
                                     |                                |                |
                                     |                   tag rc/*     O                |
                                     |                               / \               |
                                     |                              /   \              |
                                     |                             /     \             |
                                     |                            /       \            |
                                     |                           /         \           |
                                     |                          /           \          |
                                     |                         /             \         |
                                     |                        /               \        |
                                     |                       /                 \       |
                                     |                      /                   \      |
                                     |                     /                     \     |
                                     |                    /                       \    |
                                     |                   /                         \   |
                                     |                  /                           \  |
                                     |                 /                             \ |
                                     |                /                               \|
                                     |               /          tag release version    o
                                     |              /                                 /|
                                     |             /                                 / |
                                     |            /                                 /  |
                                     |           /                                 /   |
                                     |          /                                 /    |
                                     |         /                                 /     |
                                     |        /                                 /      |
                                     |       /                                 /       |
                                     |      /                                 /        |
                                     |     /                                 /         |
                                     |    /                                 /          |
                                     |   /                                 /           |
                                     |  /                                 /            |
                                     | /                                 /             |
                                     |/                                 /              |
                                     o    merge rc/* to dev            /               |
                                     |                                /                |
                                     |                               /                 |
                                     |                              /                  |
                                     |                             /                   |
                                     |                            /                    |
                                     |                           /                     |
                                     |                          /                      |
                                     |                         /                       |
                                     |                        /                        |
                                     |                       /                         |
                                     |                      /                          |
                                     |                     /                           |
                                     |                    /                            |
                                     |                   /                             |
                                     |                  /                              |
                                     |                 /                               |
                                     |                /                                |
                                     |               /                                 |
                                     |              /                                  |
                                     |             /                                   |
                                     |            o                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            o   fix bugs on master               |
                                     |            |                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            o                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            |                                    |
                                     |            o                                    |
                                     |           / \                                   |
                                     |          /   \                                  |
                                     |         /     \                                 |
                                     |        /       \                                |
                                     |       /         \                               |
                                     |      /           \                              |
                                     |     /             \                             |
                                     |    /               \                            |
                                     |   /                 \                           |
                                     |  /                   \                          |
                                     | /                     \                         |
                                     |/                       \                        |
                                     o   merge fix to dev      \                       |
                                     |                          \                      |
                                     |                           \                     |
                                     |                            \                    |
                                     |                             \                   |
                                     |                              \                  |
                                     o                               \                 |
                                     |\                               \                |
                                     | \                               \               |
                                     |  \                               \              |
                                     |   \                               \             |
                                     |    \                               \            |
                                     |     \                               \           |
                                     |      \                               \          |
                                     |       \                               \         |
                                     |        \                               \        |
                                     |         \                               \       |
                                     |          \                               \      |
                                     |           \                               \     |
                                     |            \                               \    |
                                     |             \                               \   |
                                     |              \                               \  |
                                     |               \                               \ |
                                     |                \                               \|
                                     |                 \        merge fix to master    o
                                     |                  \                             /|
                                     |                   \                           / |
                                     |                    \                         /  |
                                     |                     \                       /   |
                                     |                      \                     /    |
                                     |                       \                   /     |
                                     |                        \                 /      |
                                     |                         \               /       |
                                     |                          \             /        |
                                     |                           \           /         |
                                     |                            \         /          |
                                     |                             \       /           |
                                     |                              \     /            |
                                     |                               \   /             |
                                     |                                \ /              |
                                     |          merge dev to rc/*      o               |
                                     |                                 |               |
                                     |                                 |               |
                                     |                                 o               |
                                     |                                /|               |
                                     |                               / |               |
                                     |                              /  o bug fix       |
                                     |                             /  /|               |
                                     |                            /  / o               |
                                     |                           /  / /|               |
                                     |                          /  / / o tag rc/*      |
                                     |                         /  / /   \              |
                                     |                        /  / /     \             |
                                     |                       /  / /       \            |
                                     |                      /  / /         \           |
                                     |                     /  / /           \          |
                                     |                    /  / /             \         |
                                     |                   /  / /               \        |
                                     |                  /  / /                 \       |
                                     |                 /  / /                   \      |
                                     |                /  / /                     \     |
                                     |               /  / /                       \    |
                                     |              /  / /                         \   |
                                     |             /  / /                           \  |
                                     |            /  / /                             \ |
                                     |           /  / /                               \|
                                     |          /  / /        tag release version      O
                                     |         /  / /                                  |
                                     |        /  / /                                   |
                                     |       /  / /                                    |
                                     |      /  / /                                     |
                                     |     /  / /                                      |
                                     |    /  / /                                       |
                                     |   /  / /                                        |
                                     |  /  / /                                         |
                                     | /  / /                                          |
                                     |/  / /                                           |
                                     o  / /                                            |
                                     | / /                                             |
                                     |/ /                                              |
                                     o /                                               |
                                     |/                                                |
                                     o merge fix to dev                                |
                                     |                                                 |
                                     |                                                 |
                                     |                                                 |
                                     |                                                 |
                                     V                                                 V

