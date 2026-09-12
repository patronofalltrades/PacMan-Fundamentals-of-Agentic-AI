# Ms. Pac-Man DQN — Fundamentals of Agentic AI, Class 3

A Deep Q-Network trained to play Ms. Pac-Man. Built on the class notebook from
[pepealonso95/pacman-dqn](https://github.com/pepealonso95/pacman-dqn).

This repository is the single deliverable. It holds the executed notebook, the evidence
from one training run, and the explanation. Read this README alone to understand what ran,
what the agent learned, and how to reproduce it.

**Notebook:** [pacman_dqn.ipynb](pacman_dqn.ipynb) — saved with all outputs from the final run.

## About this repository

| Path | What it holds |
|---|---|
| `pacman_dqn.ipynb` | The executed notebook. All cell outputs from the final run are visible |
| `results/comparison.json` | Five before scores and five after scores, on seeds 101, 202, 303, 404, 505 |
| `results/training_dashboard.png` | Score, loss, and exploration curves |
| `results/demos/` | Untrained GIF, best trained GIF, and the intermediate GIFs |
| `results/config.json` | Settings, hardware, and package versions |
| `results/training.csv` | One row per completed game |
| `results/training_summary.json` | Status, episodes, decisions, learning updates, elapsed time |
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

## How the run was controlled

```sh
.venv/bin/python -m jupyter lab pacman_dqn.ipynb   # then Run All at 00:00
./stop_training_at.sh 06:00                        # in a second terminal
```

[`stop_training_at.sh`](stop_training_at.sh) finds the notebook kernel, keeps the Mac awake,
waits until 06:00, and sends one interrupt. It sends nothing if `training_summary.json`
already exists, because that file means training has ended and an interrupt would then
break the evaluation.

## What I expected, and what happened

**Recorded on 11 September 2026, before the run started.**

I expect the mean score to rise above the 492 baseline. I expect a wide spread across the
five seeds, and at least one seed that does not improve. I expect the agent to move toward
pellets and clear corridors. I do not expect it to hunt ghosts, for the reason in
"One limitation". Loss may fall while the score does not rise.

**What I observed:** _pending the run._

## Results

_Pending the run. This section is filled from the actual outputs._

### Five evaluation games, before and after

| Game | Seed | Before (untrained) | After (trained) |
|---|---|---|---|
| 1 | 101 | 350 | _pending_ |
| 2 | 202 | 500 | _pending_ |
| 3 | 303 | 320 | _pending_ |
| 4 | 404 | 800 | _pending_ |
| 5 | 505 | 490 | _pending_ |
| **Mean** | | **492** | _pending_ |

The before scores are fixed. The notebook calls `torch.manual_seed(42)` immediately before
it builds the network, so the untrained weights are identical on every run. Full data:
[comparison.json](results/comparison.json).

### Training dashboard

_Pending the run._ Raw score per game, mean update loss, and training exploration.
A falling loss is not evidence of better play. Read the score panel, not the loss panel.

### Gameplay

_Pending the run._ Untrained GIF, best trained GIF, and the intermediate GIFs.
Each GIF plays at 4x speed and shows the first 20 seconds of game time.
The trained GIF is the best of five evaluation games, selected by full-game score.

### What the run cost

| | |
|---|---|
| Status | _pending_ |
| Completed episodes | _pending_ |
| Total decisions | _pending_ |
| Learning updates | _pending_ |
| Elapsed time | _pending_ |
| Hardware | Apple M5, MPS |
| Software | Python 3.13.15, torch 2.14.0, gymnasium 1.3.0, ale-py 0.11.2, macOS 26.4.1 arm64 |

## How the agent learns, in plain language

**What it observes.** The game screen becomes grayscale and shrinks to 84 x 84 pixels. The
agent sees the last four of these screens stacked together. One screen does not show
direction or speed. Four screens do. One agent decision covers four emulator frames, so the
four screens span 16 frames.

**What it can do.** The agent picks one of nine joystick moves: no move, up, down, left,
right, and the four diagonals. One move in four repeats the previous move instead of the
chosen one. That is the sticky-action setting, and it makes the game less predictable.

**How it is rewarded.** Game points supply the reward. Pellets, power pellets, ghosts, and
fruit all score. During training every reward is clipped to the range -1 to 1, so every
scoring event counts as 1. All reported scores are raw game points.

**How it learns.** A convolutional network reads the four screens and predicts one value per
move. The agent stores each experience in a replay memory. Every four decisions it samples
32 past experiences and moves its prediction toward the reward plus 99% of the best value it
expects next. A second, slowly updated copy of the network supplies that expected next value.
That copy keeps the target from moving as fast as the learner.

## One limitation

Training rewards are clipped to the range -1 to 1. A pellet scores 10 points and a ghost
scores 200 to 1,600 points. After clipping, both count as 1. The agent therefore learns to
maximise the number of scoring events, not their value. It has no reason to learn the
high-scoring strategy of the game, which is to eat a power pellet and then hunt ghosts.

## One next experiment

Replace the constant exploration rate with a decay from 1.0 to 0.05 across the first half of
training. Change that one setting only. The current run explores at a fixed 15% to the last
episode, which slows early learning and adds noise to late learning. A decay gives broad data
early and clean, on-policy data late. It costs no extra compute.

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
