# Findings and observations

What the run showed, beyond the headline score. The README reports the result.
This document records what the evidence supports, what it does not, and what the
method itself taught.

Every number here comes from [`results/`](results/). The source for each is named.

---

## 1. The agent learned, and the result is not noise

Mean evaluation score rose from **492 to 2578**, a gain of 2086 points.

The honesty test the brief sets is whether the change in mean is larger than the
spread across seeds. It is, by about two times.

| | Value |
|---|---|
| Change in mean | +2086 |
| Spread across the five trained seeds | 1060 (2050 to 3110) |
| Seeds that improved | 5 of 5 |
| Weakest trained game vs. strongest untrained game | 2050 vs. 800 |

No trained game scored lower than any untrained game. The two distributions do not
overlap. Source: `results/comparison.json`.

---

## 2. The loss never fell, and the agent improved anyway

This is the most useful finding for understanding what the loss measures.

The brief warns that a falling loss is not evidence of better play. This run shows
the same lesson from the other side. The loss **rose** from 0.02 to about 0.13 in
the first 100 episodes, then stayed between 0.10 and 0.14 for the remaining 7,500
episodes, declining only slightly at the end. Over the same period the mean score
more than doubled.

| Episodes | Mean score | Mean loss |
|---|---|---|
| 1 – 762 | 811 | 0.117 |
| 3049 – 3810 | 1453 | 0.120 |
| 6859 – 7620 | 1993 | 0.096 |

A flat loss did not mean a flat agent. The reason is bootstrapping: the network is
trained against a target built from its own predictions, supplied by a target network
that is refreshed every 1,000 decisions. As the agent reaches higher-scoring states,
the values it must predict grow. The target moves away as fast as the learner
approaches it, so the error stays roughly constant while the policy improves.

**Do not read the loss panel as a progress bar.** Source: `results/training.csv`,
`results/training_dashboard.png`.

---

## 3. The agent both survives longer and scores faster

A higher score could mean only that the agent lives longer. It does not. Two
measurements separate survival from skill.

| | Before | After | Change |
|---|---|---|---|
| Decisions per game | 589 | 976 | +66% |
| Raw game points per decision | 0.84 | 2.64 | +214% |

If the agent had only learned to avoid dying, the points per decision would have
stayed flat. It rose by more than three times. The agent is eating more **and**
living longer. Source: `results/comparison.json`.

---

## 4. It never survives the time limit

Not one game reached the 3,000-decision cap: not the 5 untrained games, not the 5
trained games, and not one of the 305 demonstration games recorded during training.
The longest trained game used **1018 of the 3000 decisions allowed**, about a third.

Every game ends in death. This matters for the limitation argument: the cap is not
binding, so ghost avoidance is what limits the score, and that is the part the reward
structure teaches least well. Losing a life carries no penalty and does not end the
episode, so the only cost of dying is the future pellets not eaten. That signal is
weak and arrives late.

Source: `results/comparison.json`, `results/demo_scores.json`.

---

## 5. The run was approaching a plateau when it stopped

The score rose in every one of the ten training segments, but the size of each gain
fell steadily.

| Segment | Gain over the previous segment |
|---|---|
| 763 – 1524 | +222 |
| 3811 – 4572 | +217 |
| 5335 – 6096 | +124 |
| 6097 – 6858 | +38 |
| 6859 – 7620 | +31 |

The demonstration games show the same shape. Mean demonstration score was 2195
across episodes 5000 to 5250, and 2179 across episodes 7375 to 7625. Flat across the
final 2,600 episodes.

**This does not mean more training is useless.** The run reached 12.5% of the DQN
paper's decision budget. A plateau at this point is more likely to be a limit of the
exploration schedule or the reward structure than a limit of the method. Section 8
gives the experiment that separates the two.

Source: `results/training.csv`, `results/demo_scores.json`.

---

## 6. The prediction was wrong in two ways, and a stated claim in a third

The prediction was recorded before the run and committed to this repository before
training started. Two parts of it failed.

| Predicted | Observed |
|---|---|
| At least one seed will not improve | All five improved |
| Loss may fall while the score does not rise | Loss stayed flat while the score doubled |
| Mean rises above 492 | Correct: 2578 |
| Wide spread across seeds | Correct: 2050 to 3110 |

Both failures were in the same direction: the run went better than expected. The
second failure is the more interesting one, because it inverts the warning in the
brief rather than confirming it. Section 2 explains why.

A third thing written before the run also turned out to be wrong, though it was a
claim rather than a prediction. The limitation stated that the agent would not learn
to eat power pellets or hunt ghosts. It does both. Section 8 gives the measurement and
the corrected limitation.

---

## 7. A method finding: the machine was the bottleneck, not the settings

Throughput was measured before the run at between 62 and 169 decisions per second,
and the difference between those two figures was recorded as unexplained. The
`SMOKE_TEST.md` note suggested Jupyter overhead or thermal throttling.

Neither was the cause. Before this run the machine had been running for 30 days, with
swap 90% full and 0.1 GB of free memory. A restart cleared it. The run then held
**288 decisions per second**, above the top of the measured range and 4.6 times the
figure measured inside the notebook.

| | Decisions per second |
|---|---|
| Measured in the notebook, before restart | 62 |
| Measured in a clean process, before restart | 169 |
| Actual, after restart | **288** |

Two consequences:

1. **The restart was worth more than any hyperparameter chosen here.** It multiplied
   the training budget by between 1.7 and 4.6 times for two minutes of work.
2. **The ceiling design absorbed the error.** At 288 decisions per second the earlier
   plan of `EPISODES = 8000` would have finished at about 04:30 and left the machine
   idle for two hours. The ceiling of 20,000 was reached at 38%, so the clock decided
   the run length, which is what it was set up to do.

The general lesson: measure the machine in the state it will actually run in. A
benchmark taken on a machine under memory pressure measures the pressure, not the
workload.

---

## 8. What the gameplay showed, and how the limitation changed

The score data describes how much the agent scores. It does not describe what the agent does.
Two questions needed the gameplay watched. Both are now answered, and the answer reversed the
limitation I had written.

### Method

The GIFs are 75 frames of the first 20 seconds of game time. Two things were read from them
directly, frame by frame, rather than judged by eye.

1. **Frightened ghosts.** An edible ghost is drawn in `RGB(66,114,194)`, a colour that
   appears nowhere else in the palette. One ghost covers about 58 pixels, so the pixel count
   gives the number of frightened ghosts on screen.
2. **The score.** The on-screen score sits at rows 185 to 195. Digit templates were built
   from one GIF whose score sequence was read by eye, then matched against every frame of the
   others. A pellet pays 10, a power pellet 50, and the four ghosts in one chain pay 200,
   400, 800 and 1600.

### The agent learned to eat power pellets

`RGB(66,114,194)` never appears in the untrained game or in the game after 25 episodes. It
appears in 41 of 75 frames after 7,625 episodes. Across all 306 demonstration games:

| Episodes | Demos showing a frightened ghost | Mean frames frightened, of 75 |
|---|---|---|
| 1 – 500 | 5% | 1.3 |
| 501 – 1500 | 50% | 12.6 |
| 1501 – 3000 | 90% | 26.6 |
| 3001 – 4500 | 98% | 36.5 |
| 4501 – 6000 | 100% | 37.8 |
| 6001 – 7625 | 98% | 38.5 |

The first demonstration containing a frightened ghost is episode 125. By episode 4500 the
agent takes a power pellet within the first 20 seconds of every game.

### The agent eats ghosts

The score confirms it. In `final_best.gif` the score goes 140 to 190, a gain of 50, on the
exact frame the ghosts turn blue: a power pellet. It later goes 320 to 530, a gain of 210,
and 670 to 1070, a gain of 400. In `episode_7625.gif` the same pattern appears: 150 to 210
when the ghosts turn blue, then 520 to 770 and 770 to 1180.

The 200 followed by 400 is the doubling that only occurs when two ghosts are eaten inside one
power-pellet window.

### The agent never finishes a chain

This is the finding that matters. Every ghost-sized score jump in the last 12 demonstration
games:

| Episode | Ghost-sized jumps |
|---|---|
| 7350 | 200 |
| 7375 | 200, 400 |
| 7400 | 200 |
| 7425 | none |
| 7450 | 200 |
| 7475 | 200, 400 |
| 7500 | 200, 200 |
| 7525 | 200, 200 |
| 7550 | 200, 200 |
| 7575 | 200, 400 |
| 7600 | 200, 200 |
| 7625 | 200, 400 |

There is no 800 and no 1600 anywhere. The agent takes one or two ghosts and stops. Where two
200s appear, they come from two separate power pellets with one ghost each, because the chain
resets between windows.

### Why this is the reward clipping, measured

Training rewards are clipped to the range -1 to 1. The four ghosts in a chain pay 200, 400,
800 and 1600 points, and after clipping each is worth exactly 1, the same as one 10-point
pellet. Crossing the maze for the fourth ghost pays the agent what eating one adjacent pellet
pays. The agent therefore takes whichever ghosts are nearby and ignores the rest.

A full chain is worth 3000 points. The agent collects 200 to 600.

**The limitation I first wrote was wrong.** I wrote that the agent has no reason to learn the
high-scoring strategy, and would not eat power pellets or hunt ghosts. It does both. The
correct statement is narrower and better evidenced: clipping does not stop the agent eating
ghosts, it stops the agent finishing the chain. Eating a nearby ghost is cheap and pays 1.
Finishing a chain is expensive and also pays 1.

This is a better limitation than the one I predicted, because it was measured from the
gameplay rather than argued from the source code.

## 9. The next experiment, and how it would be judged

**Replace the reward clipping with a transform that preserves the order of the
rewards, such as `sign(r) * sqrt(|r|)`. Change that one setting only.**

Section 8 measured the ceiling this would lift. Under clipping, the four ghosts in a chain
and a single pellet are all worth 1, and the agent responds by taking one or two ghosts and
leaving 2,400 points on the board. A square-root transform keeps large rewards bounded enough
for stable training, but a 1600-point ghost is then worth 40 units against 3.2 for a pellet.
Finishing a chain becomes worth the trip.

**How I would know I was wrong.** If the trained agent still produces no 800 or 1600 score
jump, the reward transform is not the limit, and the exploration schedule is the next suspect.

### The alternative, if the change must be one of the three named settings

**Replace the constant exploration rate with a decay from 1.0 to 0.05 across the
first half of training.**

Exploration stayed at a flat 15% to the last episode. With 25% sticky actions on top,
a large share of moves late in training were not what the policy chose. A plateau that
arrives while roughly one move in seven is still random is the pattern a decay
schedule addresses: broad data early, clean on-policy data late, at no extra compute.

**How I would know I was wrong.** Run the same six hours with a decay schedule. If the
score plateaus at the same level and at a similar episode count, the limit is the
reward structure, not the exploration schedule. The next change would then be to the
reward clipping rather than to exploration.
