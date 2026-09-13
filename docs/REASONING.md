# Reasoning for every value I set

This document gives the reason for each value that I set in the notebook.
I wrote it to prepare for questions in class.

I took every technical fact from the notebook source code.
I took every measurement from `SMOKE_TEST.md`.

Each section has the same six parts:

1. What this value controls
2. The numbers
3. Why I selected this value
4. The argument against my choice
5. How I will know if I am wrong
6. A question the grader can ask, and my answer

## Glossary

I use each of these words with one meaning only.
The last column gives the name in the notebook code and the value that the notebook uses.

### Symbols

| Term | Meaning | In this notebook |
|---|---|---|
| Epsilon (ε) | The fraction of moves that the agent selects at random. It is a number between 0 and 1. Epsilon is the Greek letter that authors use for this value. | `EXPLORATION`, and the variable `epsilon`. I set 0.10 |
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
| Experience replay | A store of past experience. The agent learns from random samples of the store, not from the current moment. Random samples remove the correlation between consecutive moments. | The class `ReplayMemory` |
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

## How strong these six arguments are

The six arguments are not equally strong. This table ranks them.

| Value | Basis | Strength |
|---|---|---|
| `REPLAY_CAPACITY` | Measurement and mechanism | Strongest |
| `EPISODES` | Measurement | Strong |
| `DEMO_EVERY` | Measurement. It does not change the learning | Strong, but narrow |
| `LEARNING_RATE` | Mechanism and risk | Fair |
| `SHOW_POPUPS` | Code check. It changes only the display | Very small |
| `EXPLORATION` | Mechanism only. I did not test it | **Weakest** |

Tell the grader this ranking. Do not present six arguments with equal confidence.
The exploration argument is the weak one. A grader who asks questions will find this quickly.

---

# 1. Exploration rate: 0.20 to 0.10

## What this value controls

The function `choose_action` selects a move in one of two ways:

- With probability epsilon, it selects one of the nine moves at random.
- If not, it selects the greedy move.

The training loop sets epsilon with one line:

```python
epsilon = 1.0 if total_steps < WARMUP_STEPS else EXPLORATION
```

The first 1,000 decisions are fully random. After that, **epsilon stays constant**.
The notebook has no decay schedule.
My value applies to the last episode in the same way as to the first episode.

Standard DQN decreases epsilon from 1.0 to 0.1 across the first million frames.
This notebook removes that schedule. The upstream README says so.

## The numbers

The environment sets `repeat_action_probability=0.25`.
These are sticky actions. One time in four, the emulator ignores the new move.
It repeats the previous move instead.

The agent therefore executes a new greedy move less often than epsilon suggests:

| Exploration rate | Probability that a new greedy move executes |
|---|---|
| 0.20 | 0.75 x 0.80 = **60%** |
| 0.10 | 0.75 x 0.90 = **67.5%** |

The difference between the two values is 7.5 percentage points.
The sticky actions supply most of the randomness.

**This is an argument against a strong claim.**
This value changes the result much less than `EPISODES` or `REPLAY_CAPACITY`.
I must say this. This argument is weak, and I must tell the grader that it is weak.

## Why I selected 0.10

I have two reasons. Both come from the mechanism.

1. **The training data must be similar to the test data.**
   The evaluation always uses `EVAL_EXPLORATION = 0.05`.
   The exploration rate controls which states enter the replay memory.
   A random agent survives only 464 decisions, so a high rate fills the memory with
   states from the start of a game.
   A rate of 0.10 makes the training states more similar to the test states than a rate of 0.20.

2. **The environment already supplies randomness.**
   The sticky actions add 25% noise. I do not need to add as much noise myself.

## An important point about the learning rule

The update rule uses the maximum value of the next state:

```python
targets = rewards + GAMMA * (~ended).float() * target(next_obs).max(dim=1).values
```

The agent therefore learns the value of the best move.
It learns this value even when it made a random move.
Engineers call this an off-policy method.

The exploration rate does **not** make the learned behaviour more random.
It only changes **which experiences** the agent learns from.
This difference is the most important part of this choice.

## The argument against my choice

A low exploration rate can make the agent select one route too early and keep it.
The notebook has no decay schedule. Epsilon is therefore my only method to make the agent try new moves.
If the early value estimates are bad, the agent can select one poor route and keep it.
A person can reasonably argue for 0.20.

I cannot answer this question with evidence.
A comparison test needs many episodes.
The difference between the two rates must be larger than the random variation.
I measured that short runs give a result smaller than the random variation.
Five episodes made the agent worse.
This choice therefore uses mechanism, not measurement. I say so.

## How I will know if I am wrong

The score panel on the dashboard becomes flat early and stays flat.
The GIFs show the agent that repeats one route through the maze.
The agent does not clear new areas.

## Question: why did you not decrease epsilon during the run?

The notebook calculates epsilon inside the training loop from one constant.
A decay schedule therefore needs a change to the training loop, not a change to a value.
I kept the loop unchanged so that my run stays comparable with the class.
A decay schedule is my proposed next experiment.

---

# 2. Episodes: 100 to 8000

## What this value controls

`EPISODES` sets the number of games that the agent plays.
The number of updates follows from it, because `learn()` runs once for every four decisions:

```
updates = (total decisions - 1,000) / 4
```

An episode ends in one of two ways:

- The game ends, when the agent loses all its lives.
- The agent reaches the limit of `MAX_STEPS = 3000` decisions.

The setting `terminal_on_life_loss` is `False`.
The loss of one life therefore does not end the episode.

## The numbers

I measured 62 to 169 decisions each second on this machine.
A random agent plays 464 decisions in one game.
Games become longer as the agent improves, up to the limit of 3,000 decisions.

| Budget | Decisions | Updates | Fraction of the DQN paper |
|---|---|---|---|
| 100 episodes (the default) | 61,000 | 15,000 | 0.1% |
| 1 hour | 0.22 - 0.6 M | 0.06 - 0.15 M | 0.4 - 1.2% |
| **10 hours, overnight** | **2.2 - 6.1 M** | **0.6 - 1.5 M** | **4 - 12%** |

**Be careful with the word "frames" in class.**
The Nature DQN paper says that it trained for 50 million frames.
It also says that this is about 38 days of game experience.
Atari runs at 60 frames each second. 38 days at 60 frames each second is 200 million frames.
The paper's "50 million frames" therefore means 50 million decisions, with four frames in each.
The table above compares decisions with decisions.
If the grader reads the paper differently, our fraction becomes four times larger.
The conclusion is the same in both cases.

## Why I set a limit that I will not reach

I measured that five episodes moved the mean score from 492 down to **274**.
The score became worse on all five seeds.
500 updates are too few. Early training makes a network worse before it makes the network better.
A small budget is therefore harmful, not merely useless.
The default of 100 episodes is inside this region.

Games become longer as the agent improves.
I therefore cannot convert "ten hours" into a number of episodes before the run.
A limit of 8,000 episodes is a number that I will not reach.
The run cannot stop at 3am and waste the remaining hours.
I stop the run with the Interrupt button in the morning.

The notebook supports this method:

```python
except KeyboardInterrupt:
    status = "interrupted"
finally:
    train_env.close()
    save_training_result(status)
```

The notebook saves the model, the metrics, and the plot in all cases.

One detail is important. The log `history` gets a row for **completed** episodes only.
But the saved weights include the updates from the interrupted episode.
The episode count therefore understates the training a little. I will say this in the README.

## The argument against my choice

An interrupted run is not a clean experiment.
The night produced the episode count. I did not select it.
The assignment asks me to identify an interrupted run.
This limitation is therefore disclosed, not hidden.

## How I will know if I am wrong

The score curve becomes flat for the last thousands of episodes.
The extra hours then gave no benefit.
Some different limit controls the result, most probably the reward clipping.

---

# 3. Learning rate: 0.0001, unchanged

## What this value controls

The learning rate sets the size of each Adam step:

```python
optimizer = torch.optim.Adam(model.parameters(), lr=LEARNING_RATE)
```

This is one of my three assigned choices.
I must give a reason for it, although I keep the default value.

## Why DQN is sensitive to this value

The training target uses the predictions of the network itself.
Engineers call this bootstrapping. The learned value is on both sides of the equation.

A large step changes the predictions. The changed predictions change the targets.
The changed targets change the predictions again. This loop can diverge.

Three parts of the notebook reduce this risk:

- A **target network** supplies the right side of the equation. The notebook copies the weights
  into it every 1,000 decisions.
- The **Huber loss** (`smooth_l1_loss`) increases linearly for large errors, not quadratically.
  One unusual transition therefore cannot produce a very large gradient.
- **Gradient clipping** limits the gradient norm to 10.

One detail supports a small learning rate here.
`TARGET_EVERY = 1000` decisions is only 250 updates between two copies.
Standard DQN copies the weights every 10,000 decisions, which is 2,500 updates.
This notebook refreshes the target **ten times more frequently** than standard DQN.
The target therefore moves more, and a large learning rate becomes more dangerous.

## About the value 0.00025

I said before that 0.00025 is the classic DQN value. That statement was not accurate.

0.00025 is the classic value for **RMSProp**. The original paper used that optimizer.
This notebook uses **Adam**.
The two optimizers calculate their steps differently.
A learning rate does not transfer from one optimizer to the other.

Adam implementations of DQN usually use 0.0001 or less.
Dopamine's Rainbow agent uses 0.0000625.
0.0001 is therefore the correct value for the optimizer in use.
It is not only the value that I did not change.

## The risk is not symmetrical

The function `learn()` stops the run if the loss becomes non-finite:

```python
if not torch.isfinite(loss):
    raise RuntimeError("Loss became non-finite. Start a new run with a smaller learning rate.")
```

The `finally` block saves the files. But the exception stops the cell.
Run All does not continue, and the run loses the remaining hours.

I am asleep during the run. The two risks are therefore not equal:

- If the learning rate is too large, I lose all the hours of the run.
- If the learning rate is too small, I get a weaker agent.

This difference supports the safer value.

## How I will know if I am wrong

The loss panel continues to fall steeply at the end of the run, and the score continues to increase.
A larger step was then possible.

---

# 4. Replay capacity: 5,000 to 50,000

This is the strongest of my six arguments. I present it first.

## What this value controls

`ReplayMemory` contains a `deque(maxlen=capacity)`.
When the memory is full, a new transition removes the oldest transition.
Every four decisions, the agent selects 32 transitions at random from the memory.

The memory format is compact.
It does not keep two four-frame stacks that overlap.
It keeps one four-frame stack and **one** new frame, then builds the next stack again:

```python
next_obs = np.concatenate([obs[:, 1:], np.stack(last_frames)[:, None]], axis=1)
```

Each transition therefore costs five frames of 84 x 84 bytes.

| Capacity | Pixel memory |
|---|---|
| 5,000 | 168 MiB |
| 50,000 | 1.64 GiB, of 16 GB |

## What a larger capacity does not do

A larger capacity does **not** make the agent study each transition more frequently.
The number of uses is the same for both values.

1. A transition stays in the memory for `capacity` decisions.
2. The agent makes `capacity / 4` updates in that time.
3. Each update selects 32 transitions from `capacity` transitions.
4. The expected number of selections is `(capacity / 4) x 32 / capacity = 8`.

The capacity cancels.
**The agent uses each transition about 8 times, at both values.**

The capacity controls the **range of ages of the data in each batch**.
That is the complete argument.
This exact statement is better than a general statement such as "more memory is better".

## Why 5,000 is too small for this run

The agent plays 464 to 600 decisions in one game.
5,000 transitions are therefore about **eight recent games**.
A policy that is almost the same as the current policy played those eight games.
The batches are therefore correlated.
Correlated batches are the problem that experience replay must prevent.

An overnight run collects 2 to 6 million transitions.
A memory of 5,000 keeps less than 0.2% of the run. It removes the remainder in minutes.

A memory of 50,000 holds about 80 to 100 games.
Each batch of 32 then contains a wider range of situations.
The transitions also come from more different versions of the policy.
The network does not forget what it learned earlier in the night.

## Measured cost

| | 5,000 | 50,000 |
|---|---|---|
| Pixel memory | 168 MiB | 1.64 GiB |
| Time for one batch | 0.23 ms | 0.62 ms |
| Effect on speed | — | Less than 3% |

The function `sample()` calls `list(self.items)`. It copies the deque for each batch.
The cost therefore increases with the capacity.
At 50,000 the cost is less than 3% of the loop, so it is not important.
At a much larger capacity it becomes important.

## The argument against my choice

A very large replay memory is not always better.
Data from a much worse earlier policy can slow the learning.

50,000 is a value between the two problems.
It is large enough to remove the correlation.
It is small enough that all the data comes from the same run.
It is still only 1 to 2% of the total experience, so old data is not a real risk at this size.

I also agree with one point: the upstream README says that the small memory is a deliberate
simplification for laptops. This change is therefore one that the author expected.
I did not find a fault.

## How I will know if I am wrong

The machine has too little memory, starts to swap, and the speed decreases.
Or the score curve is **less** stable than a run with 5,000 at the same budget.
I have no controlled comparison for the second condition.

---

# 5. Demonstration interval: 25 to 250

## This value does not change the learning

The function `save_progress_sample` does four things:

1. It plays one evaluation game with seed 101.
2. It writes a GIF.
3. It saves a checkpoint.
4. It draws the dashboard again.

The function `evaluate()` uses a **separate environment**.
It sets `model.eval()` and then restores the previous mode.
It writes nothing to the replay memory. It changes no weights.

This value therefore controls the **cost and the detail of the evidence**, and nothing else.
This choice is about cost and disk space. It is not about the science. I will say this in the README.

## The numbers

Each demonstration writes a checkpoint of **6.76 MB**. I measured this.

| Interval | Checkpoints | Run folder | With the ZIP |
|---|---|---|---|
| 25 (the default) | 320 | 2,177 MB | **4.3 GB** |
| **250** | **32** | **230 MB** | **0.4 GB** |

The disk has 23 GB free.

Each demonstration also plays one more complete game.
Those games become longer as the agent improves, up to the limit of 3,000 decisions.
The cost therefore increases during the night.
320 demonstrations would use about one hour. Training needs that hour.

## Why 32 samples are enough

The assignment asks for intermediate GIFs and checkpoints
"if your run reaches 25 episodes or more".
It does not ask for one sample every 25 episodes.
32 samples across the night are enough.
I will show a selection in the README and keep the remainder in `results/`.

## How I will know if I am wrong

The GIFs are too far apart to show when the behaviour changed.
The file `training.csv` records **every** episode, so the score curve keeps its full detail.

---

# 6. Popup windows: off

This change affects only the display. It needs one line in the README.

The function `show_sample` opens a Tk window that stays above other windows.
That window would take the focus at each demonstration during the night.

The GIF is safe. The function `evaluate()` writes the GIF before `show_sample` runs:

```python
if gif_path is not None and chosen_frames:
    chosen_frames[0].save(gif_path, ...)   # inside evaluate()
```

`show_sample` also shows the GIF in the notebook. It does this with the popup off.

---

# Several changes at the same time: tell the grader first

I change several values at the same time, and I do one run.
**If the score increases, I cannot say which change caused the increase.**
This is one result with four differences from the default notebook.
It is a demonstration. It is not a controlled experiment.

Two facts make the problem smaller:

- The changes act on different things.
  `REPLAY_CAPACITY` and `EPISODES` change the learning.
  `DEMO_EVERY` and `SHOW_POPUPS` do not touch the weights. I showed this in the code.
  The problem is therefore between two values, not four.
- The notebook fixes the baseline. The untrained network scores exactly 492,
  because the notebook sets the seed before it builds the network.
  The "before" column is the same for everybody in the class.

This statement does not hurt my grade. It shows that I understand a controlled experiment.

# The next experiment comes from the weakest argument

The exploration rate has the least evidence.
My next experiment therefore keeps all the other values constant.
It replaces the constant epsilon with a decay from 1.0 to 0.05 across the first half of the run.

This change corrects a real weakness in the design.
The current run explores at a constant rate until the final episode.
That constant rate adds noise to the late training and supplies no benefit.
This experiment is better than a change to a value for which I have no evidence.
