# Verification record — 8 September 2026

A 5-episode execution of the real notebook, before committing a night to a long run.

## What was run

The unmodified notebook, with four changes for the test only:
`EPISODES = 5`, `DEMO_EVERY = 2`, `SHOW_POPUPS = False`, and the package-install cell skipped
because the packages were already present. Executed through the same Python 3.13 kernel
that will run the real experiment.

## Result: passed

Every artifact the assignment requires was produced:

```
baseline.json      comparison.json    config.json        demo_scores.json
training.csv       training_summary.json                 training_dashboard.png
untrained.pt       episode_0002.pt    episode_0004.pt    trained.pt
demos/episode_0000.gif  episode_0002.gif  episode_0004.gif  final_best.gif
run folder + ZIP archive
```

Device selected: **MPS**, with `Using MPS; training-batch check passed.`
Nine actions confirmed: NOOP, UP, RIGHT, LEFT, DOWN, and the four diagonals.
Software: Python 3.13.15, torch 2.14.0, gymnasium 1.3.0, ale-py 0.11.2, numpy 2.5.3,
matplotlib 3.11.1, Pillow 12.3.0, macOS 26.4.1 arm64.

## The untrained baseline is fixed at 492

| Seed | 101 | 202 | 303 | 404 | 505 | Mean |
|---|---|---|---|---|---|---|
| Untrained network | 350 | 500 | 320 | 800 | 490 | **492** |

The notebook calls `torch.manual_seed(42)` immediately before it builds the network, so the
untrained weights are identical on every run. The evaluation seeds are fixed too. This baseline
should therefore reproduce exactly, for us and for every classmate running the notebook unmodified.

Do not confuse this with a random-action agent, which scores about **237**, measured separately
over 30 games. The assignment's baseline is the untrained network, so **492 is the number to beat**.

## Five episodes made the agent worse

| | Before | After 5 episodes | Change |
|---|---|---|---|
| Mean score | 492 | 274 | **-218** |
| Per seed | 350, 500, 320, 800, 490 | 270, 350, 210, 210, 330 | worse on all five |

Completed episodes 5, total decisions 2,996, learning updates 500, elapsed 38 seconds.

500 updates is far too few to learn anything, and early training disrupts a network before it
improves it. This is the evidence for a long run: a short run is not merely useless, it is harmful.
The notebook's default of 100 episodes gives about 15,000 updates, which is still in this region.

## Throughput is uncertain between 62 and 169 decisions per second

| Measurement | Rate |
|---|---|
| Clean process, MPS, steady state, proposed settings | **169 dec/s** |
| Clean process, CPU, same | 67 dec/s |
| Inside the notebook, MPS, episode 4 (no demonstration in the window) | **62 dec/s** |

The notebook ran nearly three times slower than the same loop in a clean process, and
`config.json` confirms it was on MPS, so the device is not the explanation. The likely causes are
Jupyter kernel overhead and thermal throttling: the notebook test ran immediately after two
GPU benchmarks, and the clean measurement ran after a pause.

This is unresolved, and it does not need resolving. Both figures are recorded, the plan uses a
high episode ceiling that neither rate will reach, and the run is ended by interrupting it in the
morning rather than by exhausting a predicted episode count.

Expect sustained overnight throughput nearer the lower figure than the higher one.
Over ten hours that is roughly 2.2 to 6.1 million decisions, against the DQN paper's 50 million.

## Measured file sizes

| Item | Size |
|---|---|
| Model checkpoint (`.pt`) | 6.76 MB |
| Gameplay GIF | ~30 KB |
| Complete 5-episode run folder | 26 MB |

Checkpoints dominate the disk cost, which is why the demonstration interval is raised to 250
for the long run. See `RUN_PLAN.md` section A2.
