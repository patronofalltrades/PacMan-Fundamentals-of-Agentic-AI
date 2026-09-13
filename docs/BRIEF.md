# Class 3 brief — train a Ms. Pac-Man DQN agent

Working brief for the assignment. Source repo: `pepealonso95/pacman-dqn`.
Everything below is checked against the notebook code, not against the repo README.

---

## 1. What you must deliver

One public GitHub repository URL, submitted at the course portal.
The README is the grading entry point. A grader must understand and reproduce the run from the README alone.

The repository must contain:

| Item | Comes from |
|---|---|
| Executed `pacman_dqn.ipynb`, outputs saved, final run | your final run, do not clear outputs |
| Untrained gameplay GIF | `demos/episode_0000.gif` (baseline sample) |
| Best trained gameplay GIF | `demos/final_best.gif` |
| Intermediate GIFs and checkpoints | `demos/episode_0250.gif`, `0500.gif`, ... at the demo interval |
| Training plot | `training_dashboard.png` |
| All five before scores and all five after scores, plus both means | `comparison.json` |
| `config.json`, `training.csv`, `training_summary.json` | run folder |
| Written explanation: observations, actions, rewards, one limitation, one next experiment | you write it |

Grading has four parts: gameplay score on a class leaderboard, the explanation of learning,
the reasons for the hyperparameter choices, and the completeness of the evidence.
Three of the four parts do not depend on the score. Do those parts well.

## 2. What the machine actually does

Read this before you write the README. These facts come from the notebook cells.

**Observation.** The game screen is converted to grayscale and resized to 84 x 84 pixels.
The agent sees the last four such screens stacked together, as one array of shape `(4, 84, 84)`.
Four screens are needed because one screen does not show direction or speed.
One agent decision covers four emulator frames, so the four stacked screens span 16 frames.

**Action.** The agent picks one of nine joystick moves: no-op, up, right, left, down,
and the four diagonals. The environment uses sticky actions with probability 0.25.
That means one move in four repeats the previous move instead of the chosen one.

**Reward.** The game score supplies the reward. Pellets, power pellets, ghosts, and fruit all award points.
**During training, every reward is clipped to the range [-1, 1].** All reported scores are raw game points.

**The learning rule.** A convolutional network maps the four screens to one value per move.
The agent stores each transition in a replay memory of 5,000 items. Every four decisions, it samples
32 transitions and moves its prediction toward `reward + 0.99 x (best value of the next state)`.
A separate target network supplies that next-state value and is copied from the main network
every 1,000 decisions. The loss is Huber loss. The optimiser is Adam. Gradients are clipped at norm 10.
Game over removes the future term. The 3,000-decision time limit does not.

**Fixed settings you must not touch for the leaderboard.** Evaluation uses the same five seeds
(101, 202, 303, 404, 505), 5% exploration, and the same 3,000-decision cap, before and after training.
The baseline is an untrained network, not a random-action agent.

## 3. The three choices

### Exploration

A single number, held constant for the whole run after 1,000 random warm-up decisions.
There is no decay schedule. Whatever you pick, the agent makes that fraction of random moves
on the last episode as well as the first.

- Too high, above roughly 0.30: the agent rarely follows its own policy for long. It dies early,
  and it collects little data about the later parts of a level.
- Too low, below roughly 0.05: with a 5,000-item replay memory, the data becomes narrow and repetitive.
  The agent can lock onto one move and stay in a corner.
- Sticky actions already add 25% noise on top of your choice. That argues for a lower number than
  you would pick in a deterministic game.

**Recommended: 0.10.** It is close to the 5% used at evaluation, so training conditions resemble
scoring conditions, and it still leaves room to discover new states.

### Episodes

The training budget, and the setting that matters most. More episodes means more learning updates.
Updates are about `(total decisions - 1000) / 4`.

**Measured on this machine** (M5, MPS). See `SMOKE_TEST.md` for the full record.

- A random agent plays **464 decisions per game**, over 30 games, spread 287 to 592.
  That is about 31 seconds of game time. Games lengthen as the agent improves.
- Throughput is **between 62 and 169 decisions per second**. A clean process reaches 169;
  the same loop inside the notebook ran at 62. The device is not the explanation, since
  `config.json` confirms MPS in both cases. Assume the lower figure for planning.

| Budget | Decisions | Learning updates | vs. the DQN paper |
|---|---|---|---|
| 100 episodes (default) | ~61,000 | ~15,000 | 0.1% |
| 1 hour | 0.2-0.6 M | 0.06-0.15 M | ~1% |
| 10 hours, overnight | 2.2-6.1 M | 0.6-1.5 M | 4-12% |

The DQN paper trained for about 50 million agent decisions, which is roughly 200 million emulator
frames, or the 38 days of game experience it reports. The percentages above compare decisions to
decisions. This is the single reason to run overnight: **an hour is still within the noise, and a
night is not.**

The 5-episode verification run made the agent measurably **worse**, 492 down to 274 on all five
seeds. Early training disrupts a network before it improves it. A short run is not merely
useless, it is harmful, and the notebook default of 100 episodes sits in that region.

**Recommended: set `EPISODES` to a ceiling you will not reach, such as 8,000, and end the run by
interrupting it in the morning.** Games lengthen as the agent improves, so the episode count is
not predictable in advance. A ceiling removes the need to predict it, and stops the run ending
at 3am. The notebook catches the interrupt, saves everything, and continues to evaluation.

### Learning rate

The size of each update. Adam is the optimiser.

- 0.0001 is the notebook default and the standard Adam value for DQN. It is the right choice
  for a long run, where stability over many updates matters more than early speed.
- 0.00025 is the classic value for **RMSProp**, the optimiser in the original paper. This notebook
  uses **Adam**, and learning rates do not transfer between optimisers. Adam DQN implementations
  normally sit at 0.0001 or lower. Treat 0.00025 as a faster, riskier Adam setting, not as "the
  paper's value".
- Above about 0.001 the run is likely to become unstable. The notebook raises an error and stops
  if the loss becomes non-finite.

**Recommended: 0.0001** for an overnight run.
Use 0.00025 only for a short run of a few hundred episodes.

### Recommended set

```
EXPLORATION     = 0.10
EPISODES        = 8000     # a ceiling, not a target; interrupt in the morning
LEARNING_RATE   = 0.0001
REPLAY_CAPACITY = 50000    # section 4
DEMO_EVERY      = 250      # section 4
SHOW_POPUPS     = False    # section 4
```

The full night-of checklist is in `RUN_PLAN.md`.

## 4. Optional extra tuning

The assignment allows changes to the other settings if you explain them.
The evaluation settings must stay unchanged. These are the changes worth considering,
in order of expected value:

1. **`REPLAY_CAPACITY` from 5,000 to 50,000.** This is the single highest-value change available.
   5,000 transitions is about eight recent games. Every batch is drawn from a narrow, correlated
   window, and the agent forgets early experience within minutes. A 1,000-episode run collects
   600,000 transitions, so a 5,000-item memory keeps less than 1% of the run.
   Measured cost: 1.7 GB of pixel data, which fits in 16 GB of RAM, and under 3% of throughput.
   The upstream README states the small memory is a classroom simplification for laptops,
   so raising it is a change the notebook author anticipated.
2. **`TRAIN_EVERY` from 4 to 2.** This doubles the number of updates for the same number of games,
   and roughly doubles the training time per episode. Consider it only if you keep episodes low.
3. **`SHOW_POPUPS` to `False`.** Set this for a long unattended run. It stops a Tk window from
   opening and taking focus every 25 episodes. The GIFs are still recorded and saved either way,
   so no evidence is lost. This is a convenience setting, not a learning setting.
4. **`DEMO_EVERY` from 25 to 250**, for a long run only. Each demonstration writes a
   **6.76 MB** checkpoint, measured. At an 8,000-episode ceiling the default interval writes
   320 checkpoints and needs 4.3 GB, on a drive with 23 GB free; 250 writes 32 and needs 0.4 GB.
   Each demonstration also plays a full extra game, so 320 of them cost about an hour of training.
   32 intermediate GIFs is well past the assignment's bar, which asks for intermediate GIFs
   "if your run reaches 25 episodes or more" and does not require them every 25.

Changes 1, 3 and 4 are recommended for the overnight run.
Every change must be named in the README with a reason.

## 5. Run plan

The environment is already prepared in this folder: `.venv`, Python 3.13, torch 2.14 with Metal (MPS)
confirmed working, gymnasium 1.3.0, ALE 0.11.2. The benchmark in section 3 was measured with it.

Local is preferred over Colab. There is no session limit, the run cannot be disconnected, and the
measured speed here already matches or beats a free Colab T4 for this workload. The bottleneck is
the single forward pass per decision and the Atari emulator, not raw GPU throughput.

1. Confirm the three values, plus the replay capacity change.
2. Edit only those values. Everything else in the notebook stays as distributed.
3. Run all cells in order. Do not skip the baseline evaluation; it is the before half of your evidence.
4. Leave the machine alone during training. Interrupting once saves progress and lets you continue
   to section 6, but the README must then report the run as interrupted.
5. After the final evaluation, run the save cell. Copy the evidence into `results/`.
6. Write the README from the actual numbers.

Open the notebook with the prepared kernel:

```sh
cd "~/Fundamentals of Agentic AI/pacman-dqn"
.venv/bin/python -m jupyter lab pacman_dqn.ipynb
```

In VS Code, open the notebook and select the `.venv` interpreter as the kernel instead.

**Prediction to record before you run.** Write down what you expect, before you see the result.

**The baseline is fixed at 492**, on seeds 101/202/303/404/505: 350, 500, 320, 800, 490.
The notebook seeds the network before building it, so this reproduces exactly, for you and for
every classmate running it unmodified. Do not confuse it with a random-action agent, which
scores 237. **492 is the number to beat.**

Reasonable prediction for an overnight run: the mean rises above 492, with wide spread across
the five seeds and at least one seed that does not improve. The agent learns to move toward
pellets and clear corridors. It does not learn to hunt ghosts, for the reason in section 6.
Loss may fall while the score does not rise.

## 6. The explanation section

Two answers to prepare in advance. Both come from the code, so they hold whatever the score is.

**Limitation, the strongest one available.** Training rewards are clipped to [-1, 1].
A pellet is 10 points and a ghost is 200 to 1,600 points, but after clipping both count as 1.
The agent therefore learns to maximise the number of scoring events, not their value.
It has no reason to learn the high-scoring strategy of the game, which is to eat a power pellet
and then hunt ghosts. A second limitation, if you prefer: losing a life gives no penalty and does
not end the episode, so the cost of dying is only the future pellets not eaten. That signal is weak
and delayed, so ghost avoidance is learned slowly.

**Next experiment, one setting.** Replace the constant exploration with a decay from 1.0 to 0.05
over the first half of training. The current run explores at a fixed rate to the last episode,
which both slows early learning and adds noise to late learning. A decay gives broad data early
and clean, on-policy data late, at no extra compute cost.

## 7. Honesty rules

- Report all five before scores and all five after scores. Never report only the means.
- Five seeds is a small sample. If the change in mean is smaller than the spread across seeds,
  say the result is within noise.
- A falling loss is not evidence of better play. Say so.
- If the run does not improve, report that. The assignment asks for it directly.
- Watch the GIFs. Describe what the agent actually does, not what the score implies.

## 8. Submission checklist

- [ ] Notebook saved with all outputs from the final run, pushed to the repository
- [ ] Untrained GIF, best trained GIF, and every 25-episode GIF embedded in the README
- [ ] `training_dashboard.png` embedded
- [ ] Table with five before scores, five after scores, and both means
- [ ] `comparison.json`, `config.json`, `training.csv`, `training_summary.json` linked
- [ ] Three choices stated with a reason for each, and any extra settings changed
- [ ] Prediction, then observation
- [ ] Completed episodes, decisions, learning updates, elapsed time, hardware
- [ ] Observations, actions, rewards explained in plain language
- [ ] One limitation and one next experiment
- [ ] Repository set to public, and checked in a private browser window
- [ ] Large checkpoints kept out of the repository, with their location explained
- [ ] URL submitted at the portal
