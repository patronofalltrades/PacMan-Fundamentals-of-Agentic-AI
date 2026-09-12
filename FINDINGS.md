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

## 6. The prediction was wrong in two ways

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

## 8. What the numbers cannot settle

The measurements above describe how much the agent scores and how long it survives.
They do not describe **what it does**. Two questions need the gameplay watched, not
the data read.

1. **Does the agent ever eat a power pellet and then hunt ghosts?** The limitation
   argument says it has no reason to, because training rewards are clipped to the
   range -1 to 1, so a 10-point pellet and a 1,600-point ghost both count as 1. The
   score is consistent with that reading: 2.64 points per decision is about what
   eating 10-point pellets produces, and a ghost chain would show a much higher rate.
   But consistency is not proof. Watching settles it.
2. **Does it avoid ghosts deliberately, or only incidentally?** A policy that flees
   looks different from one that walks toward pellets and survives by luck.

### Observations from watching the gameplay

_To be completed after watching `results/demos/episode_0025.gif` against
`results/demos/episode_7625.gif`._

- Movement:
- Power pellets and ghosts:
- Ghost avoidance:
- Coverage of the maze:
- How it dies:

---

## 9. The next experiment, and how it would be judged

**Replace the constant exploration rate with a decay from 1.0 to 0.05 across the
first half of training. Change that one setting only.**

Exploration stayed at a flat 15% to the last episode. With 25% sticky actions on top,
a large share of moves late in training were not what the policy chose. A plateau that
arrives while roughly one move in seven is still random is the pattern a decay
schedule addresses: broad data early, clean on-policy data late, at no extra compute.

**How I would know I was wrong.** Run the same six hours with a decay schedule. If the
score plateaus at the same level and at a similar episode count, the limit is the
reward structure, not the exploration schedule. The next change would then be to the
reward clipping rather than to exploration.
