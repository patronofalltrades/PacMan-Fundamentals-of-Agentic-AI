# Ms. Pac-Man DQN — Fundamentals of Agentic AI, Class 3

A Deep Q-Network trained to play Ms. Pac-Man. Built on the class notebook from
[pepealonso95/pacman-dqn](https://github.com/pepealonso95/pacman-dqn).

This repository is the single deliverable. It holds the executed notebook, the evidence
from one training run, and the explanation. Read this README alone to understand what ran,
what the agent learned, and how to reproduce it.

## ▶ Read the executed notebook here

### **[Open pacman_dqn.ipynb in nbviewer](https://nbviewer.org/github/patronofalltrades/PacMan-Fundamentals-of-Agentic-AI/blob/main/pacman_dqn.ipynb)**

The notebook is [`pacman_dqn.ipynb`](pacman_dqn.ipynb) in this repository, saved with every
output from the final run. **GitHub shows it as a blank page.** The file is 14.6 MB, because
the training cell holds 305 embedded gameplay GIFs, and GitHub's notebook viewer gives up at
that size. The link above renders the same file in full: the five before and after scores,
the training dashboard, and the gameplay.

The outputs have not been cleared. The file is exactly as the run saved it.

## About this repository

| Path | What it holds |
|---|---|
| `pacman_dqn.ipynb` | The executed notebook, saved with all outputs from this run. 14.6 MB, so read it [in nbviewer](https://nbviewer.org/github/patronofalltrades/PacMan-Fundamentals-of-Agentic-AI/blob/main/pacman_dqn.ipynb) — GitHub cannot render it |
| `results/comparison.json` | Five before scores and five after scores, on seeds 101, 202, 303, 404, 505 |
| `results/training_dashboard.png` | Score, loss, and exploration curves |
| `results/demos/` | 307 GIFs: the untrained game, 305 demonstrations, and the best trained game |
| `results/config.json` | Settings, hardware, and package versions |
| `results/training.csv` | One row for each of the 7,628 completed games |
| `results/training_summary.json` | Status, episodes, decisions, learning updates, elapsed time |
| `results/demo_scores.json` | Score and length of every demonstration game |
| `FINDINGS.md` | Findings and observations: what the evidence supports, and what it does not |
| `stop_training_at.sh` | Ends the training loop at a set clock time. See "How the run was controlled" |

Model checkpoints are not in this repository. Each checkpoint is 6.76 MB and a run writes
many. They stay in the local run ZIP. The last section gives its location.

## How to open and run it

**Local, macOS or Linux:**

```sh
git clone https://github.com/patronofalltrades/PacMan-Fundamentals-of-Agentic-AI.git
cd PacMan-Fundamentals-of-Agentic-AI
uv venv --python 3.13 .venv          # or: python3.13 -m venv .venv
VIRTUAL_ENV=.venv uv pip install -r requirements.txt ipykernel
.venv/bin/python -m jupyter lab pacman_dqn.ipynb
```

Select the `.venv` kernel. Choose Run All. The notebook detects CUDA, Apple Metal (MPS),
or CPU automatically.

**Google Colab:** open the notebook. Choose Runtime → Change runtime type → T4 GPU.
Choose Runtime → Run all. The first cell installs the packages.

## My settings and why

| Setting | Notebook default | My value | Reason |
|---|---|---|---|
| `EXPLORATION` | 0.20 | **0.15** | The midpoint between the notebook default and the 0.10 I first argued for. I changed four settings at once, so I held this one near the default to limit how much moved. This is my weakest argument. I did not test it |
| `EPISODES` | 100 | **20000** | A ceiling, not a target. The run ends at a clock time, not at an episode count. See below |
| `LEARNING_RATE` | 0.0001 | **0.0001** | Unchanged. The standard Adam value for DQN. A long run needs stability across many updates more than early speed. 0.00025 is the RMSProp value from the original paper, and learning rates do not transfer between optimisers |

**Other settings I changed.**

| Setting | Notebook default | My value | Reason |
|---|---|---|---|
| `REPLAY_CAPACITY` | 5000 | **50000** | 5,000 transitions is about eight recent games. Every batch then comes from a narrow, correlated window, and the agent forgets early experience within minutes. This run collects millions of transitions, so 5,000 keeps far less than 1% of it. Measured cost: 1.7 GB of RAM and under 3% of throughput |
| `SHOW_POPUPS` | True | **False** | Stops a Tk window opening during an unattended overnight run. GIFs are still recorded and saved. Display only. No effect on learning |

**Settings I did not change.** The evaluation is untouched, so this result compares with the
rest of the class. Evaluation uses the same five seeds (101, 202, 303, 404, 505), 5%
exploration, and the same 3,000-decision cap, before and after training. The baseline is an
untrained network, not a random-action agent.

### Why the episode budget is a ceiling

Throughput on this machine measures between 62 and 169 decisions per second. That is a
spread of 2.7 times. A random agent plays 464 decisions per game, and games lengthen as the
agent improves. No episode count therefore produces a run of known length.

I fixed the length instead. `EPISODES = 20000` cannot be reached at either rate. The run
starts at 00:00 and a script sends one interrupt at 06:00. The notebook catches that
interrupt, records the status as `interrupted`, and saves the model, metrics, and plot.
A higher ceiling costs nothing: checkpoints scale with episodes reached, not with the ceiling.

An earlier plan used `EPISODES = 8000`. At the fast measured rate that budget completes in
6.3 hours, so the run could end before morning and leave the machine idle. I raised it.

**The measurement was wrong, and the ceiling absorbed the error.** The run reached 288
decisions per second, above the 62 to 169 range measured beforehand. The machine had been
running for 30 days with swap 90% full and 0.1 GB of free memory. A restart before the run
removed that, and the throughput nearly doubled. At 288 decisions per second, `EPISODES = 8000`
would have completed at about 04:30 and wasted two hours. The ceiling of 20,000 was reached
at 38%, so the clock decided the run length, exactly as intended.

## How the run was controlled

```sh
.venv/bin/python -m jupyter lab pacman_dqn.ipynb   # then Run All
./stop_training_at.sh 06:47                        # in a second terminal
```

[`stop_training_at.sh`](stop_training_at.sh) finds the notebook kernel, keeps the Mac awake,
waits until the set time, and sends one interrupt. It sends nothing if this run's
`training_summary.json` already exists, because that file means training has ended and an
interrupt would then break the evaluation.

The run started at 00:47 and was stopped at 06:47. The machine was restarted first, for the
reason given above.

## What I expected, and what happened

**Recorded on 11 September 2026, before the run started.**

I expect the mean score to rise above the 492 baseline. I expect a wide spread across the
five seeds, and at least one seed that does not improve. I expect the agent to move toward
pellets and clear corridors. I do not expect it to hunt ghosts, for the reason in
"One limitation". Loss may fall while the score does not rise.

**What I observed.** The mean rose from 492 to **2578**, a gain of 2086 points. The agent
moves toward pellets, clears corridors, and survives 66% longer. It also learned something I
did not predict: it seeks power pellets and eats ghosts. It never finishes a ghost chain,
which turns out to be the sharper limitation. See "One limitation". Two parts of the
prediction were wrong. I expected at least one seed that did not improve, and **all five
improved**. I expected the loss might fall while the score did not rise, and the opposite
happened: the loss rose early and then stayed near 0.11 for the whole run, while the score
more than doubled. Loss and playing strength moved independently, which is the point the
brief makes, in the opposite direction from the one I predicted.

## Results

### Five evaluation games, before and after

Same five seeds, 5% exploration, 3,000-decision cap, applied identically before and after.

| Game | Seed | Before (untrained) | After (trained) | Change |
|---|---|---|---|---|
| 1 | 101 | 350 | 2790 | +2440 |
| 2 | 202 | 500 | 2330 | +1830 |
| 3 | 303 | 320 | 2610 | +2290 |
| 4 | 404 | 800 | 3110 | +2310 |
| 5 | 505 | 490 | 2050 | +1560 |
| **Mean** | | **492** | **2578** | **+2086** |

The mean score rose by a factor of 5.2. Full data: [comparison.json](results/comparison.json).

The before scores reproduce exactly for anyone running the notebook unmodified. The notebook
calls `torch.manual_seed(42)` immediately before it builds the network, so the untrained
weights are identical on every machine. The baseline is 492, not the 237 a random-action
agent scores.

**This result is not within noise.** The change in mean is 2086. The spread across the five
trained seeds is 1060, from 2050 to 3110. The change is about twice the spread. Every seed
improved, and the weakest trained game (2050) beats the strongest untrained game (800) by
1250 points.

**What the agent does differently.** Two measurements separate survival from skill.

| | Before | After |
|---|---|---|
| Decisions per game | 589 | 976 |
| Raw game points per decision | 0.84 | 2.64 |

The agent lives 66% longer and scores 3.1 times more per decision. It is not only surviving,
it is eating more while it lives.

**It still dies every game.** No evaluation game reached the 3,000-decision cap, before or
after. The longest trained game lasted 1018 decisions of the 3000 allowed. Across all 305
demonstration games recorded during training, not one reached the cap. Death ends every
game, so ghost avoidance is still the limit on the score.

### Training dashboard

![Training dashboard](results/training_dashboard.png)

**Read the score panel, not the loss panel.** The 25-game average (orange) rises steadily
from about 700 to about 2100 across 7,628 episodes. Individual games (pale blue) spread from
near zero to 5,600, which is why the average matters.

The loss panel shows the opposite of the usual warning. The loss did **not** fall. It rose
from 0.02 to about 0.13 in the first 100 episodes, then stayed between 0.10 and 0.14 for the
rest of the run, with only a slight decline at the end. Meanwhile the score more than
doubled. A flat loss did not mean a flat agent. The loss measures how well the network
predicts its own moving target, not how well the agent plays.

The exploration panel confirms the setting: 100% during the 1,000-decision warm-up, then a
flat 15% to the last episode. There is no decay.

### Training score by segment

Training scores use 15% exploration, so they are not comparable with the evaluation numbers
above. The trend is what matters.

| Episodes | Mean score | Mean decisions | Mean loss |
|---|---|---|---|
| 1 – 762 | 811 | 631 | 0.117 |
| 763 – 1524 | 1033 | 693 | 0.128 |
| 1525 – 2286 | 1209 | 739 | 0.115 |
| 2287 – 3048 | 1345 | 771 | 0.111 |
| 3049 – 3810 | 1453 | 806 | 0.120 |
| 3811 – 4572 | 1670 | 852 | 0.126 |
| 4573 – 5334 | 1800 | 888 | 0.116 |
| 5335 – 6096 | 1924 | 925 | 0.100 |
| 6097 – 6858 | 1962 | 924 | 0.099 |
| 6859 – 7620 | 1993 | 932 | 0.096 |

The score rises in every segment. Episode length rises in every segment but the last. The
gain per segment shrinks near the end, from +222 in the second segment to +31 in the last,
so the run was approaching a plateau when it stopped. Full data: [training.csv](results/training.csv).

### Gameplay

**Before training (untrained network):**

![Untrained](results/demos/episode_0000.gif)

**After training (best of the five evaluation games, 3110 points):**

![Trained](results/demos/final_best.gif)

**Progress during training.** One demonstration game every 25 episodes, at the evaluation
exploration rate of 5%, on seed 101. All 305 are in [results/demos/](results/demos/).

| After 25 | After 250 | After 1000 |
|---|---|---|
| ![25](results/demos/episode_0025.gif) | ![250](results/demos/episode_0250.gif) | ![1000](results/demos/episode_1000.gif) |

| After 2500 | After 5000 | After 7625 |
|---|---|---|
| ![2500](results/demos/episode_2500.gif) | ![5000](results/demos/episode_5000.gif) | ![7625](results/demos/episode_7625.gif) |

Mean demonstration score over each window of about 11 games:

| Episodes | 25–250 | 1000–1250 | 2500–2750 | 5000–5250 | 7375–7625 |
|---|---|---|---|---|---|
| Score | 530 | 933 | 1474 | 2195 | 2179 |
| Decisions | 584 | 637 | 833 | 856 | 931 |

The best single demonstration game scored 5140, at episode 5225. The last two windows are
level, which is the same plateau the training segments show.

Each GIF plays at 4x speed and shows the first 20 seconds of game time. The trained GIF is
the best of five evaluation games, selected by full-game score.

### What the run cost

| | |
|---|---|
| Status | **Interrupted**, by design, at 06:47 after six hours |
| Completed episodes | 7,628 of a 20,000 ceiling |
| Total decisions | 6,225,108 |
| Learning updates | 1,556,027 |
| Elapsed time | 6.00 hours |
| Throughput | 288 decisions per second |
| Against the DQN paper's 50M decisions | 12.5% |
| Hardware | Apple M5, MPS, 16 GB unified memory |
| Software | Python 3.13.15, torch 2.14.0, gymnasium 1.3.0, ale-py 0.11.2, macOS 26.4.1 arm64 |

The run was stopped by one interrupt at a set clock time, not by exhausting the episode
ceiling. This is a disclosed limitation, not a failure. The notebook catches the interrupt,
records the status as `interrupted`, and saves the model, metrics and plot before the
evaluation runs.

A longer analysis, including why the loss never fell and why the machine mattered more than
the settings, is in [FINDINGS.md](FINDINGS.md).

Executed notebook: **[open in nbviewer](https://nbviewer.org/github/patronofalltrades/PacMan-Fundamentals-of-Agentic-AI/blob/main/pacman_dqn.ipynb)**

Full records: [config.json](results/config.json) ·
[training.csv](results/training.csv) ·
[training_summary.json](results/training_summary.json) ·
[demo_scores.json](results/demo_scores.json)

**One harmless output in the notebook.** The package-install cell prints
`No module named pip`. The environment was built with `uv`, which does not install `pip`
into the virtual environment. Every package was already present, and the version cell below
it confirms them. The run is unaffected.

## How the agent learns, in plain language

**What it observes.** The game screen becomes grayscale and shrinks to 84 x 84 pixels. The
agent sees the last four of these screens stacked together. One screen does not show
direction or speed. Four screens do. One agent decision covers four emulator frames, so the
four screens span 16 frames.

**What it can do.** The agent picks one of nine joystick moves: no move, up, down, left,
right, and the four diagonals. One move in four repeats the previous move instead of the
chosen one. That is the sticky-action setting, and it makes the game less predictable.

**How it is rewarded.** Game points supply the reward, but the agent is not trained on game
points. Two different numbers come out of the same event, and the training loop sends them to
two places:

```python
next_obs, reward, ended, truncated, _ = train_env.step(action)
replay.add(obs, action, reward, ...)   # clipped to [-1, 1] inside add()
score += reward                        # raw, never clipped
```

The raw number is summed into the score this README reports. A clipped copy goes into the
replay memory and becomes the training signal. After clipping, a 10-point pellet and a
1,600-point ghost are both worth exactly 1.

| | Game points | Training reward |
|---|---|---|
| Pellet | 10 | 1 |
| Power pellet | 50 | 1 |
| Ghost, first to fourth in a chain | 200, 400, 800, 1600 | 1, 1, 1, 1 |

**The network never sees a game point.** It maximises the number of scoring events, not their
value. Every score in this README is raw game points, so the number the agent optimises and
the number it is graded on are not the same number. "One limitation" shows where those two
numbers disagree.

Clipping is not a mistake in the notebook. It comes from the 2015 DQN paper, which trained one
architecture with one set of hyperparameters across 49 Atari games whose scores range from
about 1 to many thousands. It also bounds the size of a single gradient, because a 1,600-point
reward would otherwise produce one very large error and damage the weights. It buys
generality and stability, and it pays for them in fidelity.

**How it learns.** A convolutional network reads the four screens and predicts one value per
move. The agent stores each experience in a replay memory. Every four decisions it samples
32 past experiences and moves its prediction toward the reward plus 99% of the best value it
expects next. A second, slowly updated copy of the network supplies that expected next value.
That copy keeps the target from moving as fast as the learner.

## One limitation

**Reward clipping does not stop the agent eating ghosts. It stops the agent finishing the
chain.**

I expected to report that the agent never hunts ghosts. The gameplay shows the opposite, and
the real limitation is sharper.

Training rewards are clipped to the range -1 to 1 in `ReplayMemory.add`. In Ms. Pac-Man the
four ghosts eaten after one power pellet pay 200, 400, 800 and 1600 points, which is 3000
points in total. After clipping, each of those four is worth exactly 1, and so is a single
10-point pellet. Crossing the maze to reach the fourth ghost therefore pays the agent the
same as eating one pellet next to it.

The agent behaves exactly as that structure predicts.

| Behaviour | Evidence |
|---|---|
| It learned to eat power pellets | Frightened ghosts appear in 5% of demonstration games before episode 500, and in 100% after episode 4500 |
| It eats ghosts | Score jumps of 200, then 400, in the same power-pellet window |
| It never finishes a chain | Across the last 12 demonstration games, every ghost-sized jump is 200 or 400. There is no 800 and no 1600 |

So the agent takes the one or two ghosts that are convenient and ignores the rest. It
collects 200 to 600 points from a power pellet that is worth 3000.

**Clipping does not flatten the incentive. It reverses it.** Consider the choice the agent
faces with two ghosts left and both across the maze. The trip costs about 20 decisions, and
in those decisions it could eat about 5 pellets instead.

| | Chase the last two ghosts | Eat 5 nearby pellets | Better choice |
|---|---|---|---|
| In game points | 2400 | 50 | Chase, by 48 times |
| In clipped training reward | 2 | 5 | Eat pellets, by 2.5 times |

Under the reward it was actually trained on, walking away from the chain is the correct move.
**The agent did not fail to learn. It learned its reward function exactly, and the reward
function is wrong about what the game is worth.**

Measured by reading the on-screen score directly from the gameplay GIFs, frame by frame.
The method and the full numbers are in [FINDINGS.md](FINDINGS.md), section 8.

**A second limitation.** Losing a life gives no penalty and does not end the episode, so the
only cost of dying is the future pellets not eaten. That signal is weak and late. No game
ever reached the 3,000-decision cap: not the 5 untrained games, not the 5 trained games, and
not one of the 306 demonstration games. Every game ends in death.

## One next experiment

**Replace the reward clipping with a transform that keeps the order of the rewards, such as
`sign(r) * sqrt(|r|)`. Change that one setting only.**

This is the experiment the gameplay points to. Clipping makes all four ghosts in a chain
worth the same as one pellet, and the agent responds by taking one or two and leaving the
rest. A square-root transform keeps large rewards bounded enough to stay stable, but a
1600-point ghost is then worth 40 units against 3.2 for a pellet, so finishing a chain is
worth pursuing. The measured ceiling this would lift is large: the agent currently collects
200 to 600 points from a power pellet worth 3000.

This is not an invented fix. Invertible value rescaling, `h(x) = sign(x)(sqrt(|x|+1) - 1) + ex`,
is used by Ape-X and R2D2 for this exact purpose: it removes reward clipping while keeping the
training targets small enough to stay stable.

**How I would know I was wrong.** If the trained agent still shows no 800 or 1600 score jump,
the limit is not the reward transform. The next suspect would then be the exploration
schedule.

**The alternative, if the grader prefers a change to one of the three named settings.**
Replace the constant exploration rate with a decay from 1.0 to 0.05 across the first half of
training. Exploration stayed at a flat 15% to the last episode, with 25% sticky actions on
top. The score gain per segment fell from +222 early to +31 at the end, and the
demonstration score was level at about 2,190 across the final 2,600 episodes. A plateau that
arrives while one move in seven is still random is the pattern a decay schedule addresses.

## Assignment objectives

**The task.** Use the ready-made notebook to train a Deep Q-Network on Ms. Pac-Man.
Choose three hyperparameters, train the agent, and explain what it actually learned.
Submit one public GitHub repository URL, with the notebook and the evidence in its README.

### The three hyperparameters

Only these three values in section 1 of the notebook are chosen by the student.

| Setting | What it is | Reference point |
|---|---|---|
| Exploration | A number from 0 to 1. A value of 0.20 makes about 20% of training moves random after warm-up. | The notebook starts at 0.20 |
| Episodes | A positive whole number of training games. | 5 to check the setup; 100 is the notebook's starting value |
| Learning rate | The size of each update. | 0.0001 |

Exploration stays constant after 1,000 random warm-up decisions. An episode ends at game
over, or at the notebook's fixed time limit. Other hyperparameters may be tuned, but every
change must be named and explained.

### Fair evaluation

The notebook's evaluation settings must stay unchanged: the same five seeds, 5% exploration,
and the same time limit, applied before and after training. The baseline is an untrained
network, not a random-action agent. Every evaluation score and both means must be reported.
The GIFs must be watched, not only the scores. A lower training loss does not prove better
play. Runs that fail, or that do not improve, must be reported honestly.

### What the README must contain

- A brief overview, and instructions to open and run the notebook.
- The exploration rate, the episode budget, and the learning rate, each with a short reason.
- What was expected before training, followed by what was observed.
- The completed episodes, decisions, learning updates, elapsed time, and hardware used.
- A plain-language explanation: four game screens are the observations, joystick moves are
  the actions, and game points supply the reward.
- One observed limitation, and one next experiment. Name the single setting that would
  change, and why.

### Evidence required in the README

- The untrained GIF, the best trained GIF, and any intermediate GIFs from the run, embedded.
- `training_dashboard.png`, embedded, so the score, loss, and exploration curves are visible.
- A table with all five baseline scores, all five trained scores, and both means, linking
  `comparison.json`.
- Links to the notebook, `config.json`, `training.csv`, and `training_summary.json`.
- An interrupted run, or a run with no learning updates, must be identified as such.

### Definition of done

- The notebook runs with the chosen hyperparameters, and the README records the actual
  training budget.
- The untrained and the trained agents are evaluated under the same settings, with all
  five scores shown.
- The plot, the gameplay, and the explanation agree with the recorded results.
- The student can explain what the agent observes, what it can do, how it is rewarded,
  and one limitation.

### Grading

Gameplay performance is part of the rubric. A class leaderboard compares agents by the mean
score across the five trained evaluation games, with the same evaluation settings for
everyone. Grading also covers the explanation of the learning process, the hyperparameter
choices, and the quality and completeness of the evidence.

### Scope

The supplied DQN is used. Building an agent from scratch is optional. No website, backend,
or deployment is required. A proposed next experiment is enough; a second training run is
optional.

## Glossary

I use each of these words with one meaning only.
The last column gives the name in the notebook code and the value that the notebook uses.

### Symbols

| Term | Meaning | In this notebook |
|---|---|---|
| Epsilon (ε) | The fraction of moves that the agent selects at random. It is a number between 0 and 1. Epsilon is the Greek letter that authors use for this value. | `EXPLORATION`, and the variable `epsilon`. I set 0.15 |
| Gamma (γ) | The discount factor. It sets how much a future reward counts against an immediate reward. A value of 0.99 means that the agent values the next step at 99% of this step. | `GAMMA = 0.99`. Unchanged |
| Alpha (α) | The learning rate. Some authors use this letter. This notebook does not. | `LEARNING_RATE = 0.0001` |

### The agent and the network

| Term | Meaning | In this notebook |
|---|---|---|
| DQN | Deep Q-Network. A neural network that predicts the value of each move. DeepMind published the method in 2015. | The class `DQN` |
| Q-value | The predicted total future reward, if the agent makes one specific move now and then plays well. The letter Q means "quality". | The nine numbers that `model(screens)` returns |
| Convolutional layer | A network layer that finds visual patterns in an image. It applies the same small filter across the whole image. | Three `nn.Conv2d` layers |
| Weights | The numbers inside the network. Training changes them. Also called parameters. | About 1.69 million numbers |
| Policy | The rule that selects a move. | `choose_action` |
| Greedy move | The move with the highest Q-value. | `model(screens).argmax()` |
| Epsilon-greedy | A policy that selects a random move with probability epsilon, and the greedy move at other times. | `choose_action` |
| Target network | A second copy of the network. It supplies the future value in the update rule. The notebook copies the weights into it at intervals. A frozen copy stops the target from moving as fast as the learner. | `target`, copied every `TARGET_EVERY = 1000` decisions |

### Learning

| Term | Meaning | In this notebook |
|---|---|---|
| Update | One change to the network weights. | One call to `learn()`. One update for every four decisions |
| Experience replay | A store of past experience. The agent learns from random samples of the store, not from the current moment. Random samples remove the correlation between consecutive moments. | The class `ReplayMemory`, capacity 50,000 |
| Transition | One record in the replay memory. It holds the four screens, the move, the reward, the next screen, and the end flags. | One item in the deque |
| Batch | The group of transitions in one update. | `BATCH_SIZE = 32` |
| Warm-up | The first period of a run. The agent acts at random and makes no updates. It collects data first. | `WARMUP_STEPS = 1000` decisions |
| Bootstrapping | The network uses its own prediction to build its training target. The learned value is on both sides of the equation. | `target(next_obs).max()` inside the target |
| Off-policy | The agent learns the value of the best move, even when it made a random move. The `max` in the update rule causes this. | The `.max(dim=1)` call |
| Loss | A number that measures the size of the error. Training reduces it. | The return value of `learn()` |
| Huber loss | A loss function that increases linearly for large errors, and quadratically for small errors. One unusual transition therefore cannot produce a very large gradient. | `nn.functional.smooth_l1_loss` |
| Gradient | The direction and size of the change that reduces the loss. | `loss.backward()` |
| Gradient clipping | A limit on the size of the gradient. It stops one large gradient from destroying the weights. | `clip_grad_norm_(..., 10.0)` |
| Optimizer | The algorithm that applies the gradient to the weights. | `torch.optim.Adam` |
| Adam | A common optimizer. It scales each step by recent gradient sizes. A learning rate does not transfer between Adam and other optimizers. | `Adam(..., lr=LEARNING_RATE)` |
| Learning rate | The size of each step that the optimizer takes. | `LEARNING_RATE = 0.0001` |
| Reward clipping | The notebook limits each training reward to the range -1 to 1. Every scoring event therefore counts as 1 during training. Reported scores use raw game points. | `np.clip(reward, -1, 1)` in `ReplayMemory.add` |

### The game environment

| Term | Meaning | In this notebook |
|---|---|---|
| Frame | One image from the game emulator. The game produces 60 frames each second. | The raw output of the emulator |
| Decision | One move that the agent selects. The emulator advances four frames for each decision. Also called a step. | One pass through the inner loop |
| Episode | One complete game, from the start to game over. It can also end at the decision limit. | `MAX_STEPS = 3000` decisions |
| Frame skip | The number of frames that the emulator advances for each decision. It reduces the work with little loss of information. | `FRAME_SKIP = 4` |
| Frame stack | The group of recent screens that the agent sees at one time. One screen does not show direction or speed. Four screens do. | `stack_size=4`, shape `(4, 84, 84)` |
| Sticky actions | The emulator ignores the new move at random intervals and repeats the previous move. This stops the agent from memorising one fixed sequence. | `repeat_action_probability=0.25` |
| No-op | A move that does nothing. The game also starts with a random number of no-op moves. | `NOOP`, and `noop_max=30` |
| Terminated | The game ended for a real reason. The agent lost all its lives. The future value then counts as zero. | `ended` in the code |
| Truncated | The game stopped at the time limit. The game was not over. The future value still counts. | `truncated` in the code |
| ALE | Arcade Learning Environment. The software that runs the Atari game. | `ale-py`, version 0.11.2 |
| Gymnasium | The library that gives a standard interface to the game. | `gymnasium`, version 1.3.0 |

### The run and its files

| Term | Meaning | In this notebook |
|---|---|---|
| Seed | A number that fixes a random sequence. The same seed gives the same sequence. Seeds make a run repeatable. | `SEED = 42`, and `EVAL_SEEDS` |
| Baseline | The score of the untrained network. It is the "before" measurement. | 492, from five evaluation games |
| Evaluation | Five complete games with fixed settings. It runs before and after training. It changes no weights. | `evaluate()` |
| Checkpoint | A saved copy of the network weights. It allows playback later. | A `.pt` file of 6.76 MB |
| Epoch | A complete pass through a fixed dataset. **This method has no epochs.** The data arrives while the agent plays. | Not used |
| MPS | Metal Performance Shaders. The interface that PyTorch uses for the GPU on an Apple computer. | The selected device |


## Where the large files are

Model checkpoints are not committed. They are in the run ZIP, kept locally at
`~/Fundamentals of Agentic AI/pacman-dqn/pacman_runs/`. The `results/` folder in this
repository holds the published evidence: configuration, metrics, plot, GIFs, and comparison.
