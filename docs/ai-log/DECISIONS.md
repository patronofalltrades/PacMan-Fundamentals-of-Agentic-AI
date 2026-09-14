# Decisions and outputs

A hand-written companion to [AI-LOG.md](AI-LOG.md). The log records *what was
said and done*, automatically. This file records *what was decided and why* —
which no hook can capture. Claude appends here whenever a choice is made; Hanif
edits freely.

Each entry: what was decided, the alternatives, the reason, and what it produced.

---

## 2026-09-08 · Record AI use for this assignment

**Decided.** Log every prompt, tool action, and Claude reply for this assignment
to `docs/ai-log/`, using Claude Code hooks scoped to this repository only.

**Alternatives considered.** Logging globally across the whole machine (rejected:
this is the only assignment that needs a record, and a global log would sweep in
unrelated work); logging file changes only (rejected: loses the reasoning trail,
which is the part worth showing for an Agentic AI course).

**Reason.** The course is about working with agentic AI. A verbatim record of the
collaboration is both an honesty artefact and the raw material for the written
explanation the brief requires.

**Produced.** `.claude/hooks/log_ai_activity.py`, `.claude/settings.json`,
`docs/ai-log/AI-LOG.md`, `docs/ai-log/raw.jsonl`, this file.

---

## 2026-09-08 · Run overnight on Friday 11 September, ended by interrupt

**Decided.** Hanif runs the experiment overnight on Friday 11 September, starting in
the evening and stopping it on Saturday morning. `EPISODES` is set as a ceiling that
will not be reached, and the run is ended by pressing Interrupt once, rather than by
letting a predicted episode count run out.

**Alternatives considered.** A 1.5-hour run in an afternoon (rejected: Hanif has the
weekend available, and the extra hours buy roughly an order of magnitude more learning
updates); predicting an exact episode count and letting the loop finish (rejected: games
lengthen as the agent improves, so the count is not predictable in advance, and a run
that ends at 3am wastes the rest of the night).

**Reason.** Throughput measurement showed an overnight run reaches 2.2-6.1 million
decisions against the DQN paper's 50 million, versus roughly 0.1 million for the
notebook default. The notebook catches `KeyboardInterrupt`, saves the model, metrics and
plot, and continues to evaluation, so interrupting is a supported path, not a failure.
The assignment explicitly asks that an interrupted run be identified, so this is honest.

**Produced.** `docs/RUN_PLAN.md`.

---

## 2026-09-08 · Verify the whole path before committing a night to it

**Decided.** Execute the real notebook end to end as a 5-episode test before Friday.

**Alternatives considered.** Trusting the upstream repository's own verification
(rejected: it was done on a different machine and a different package set); starting
the long run directly on Friday (rejected: a failure discovered on Saturday morning
costs the entire weekend and there is no second night before submission).

**Reason.** The cost is 90 seconds. The downside it protects against is losing the run.

**Produced.** `docs/SMOKE_TEST.md`. Three findings that changed the plan:

1. **The baseline is 492, not 237.** The assignment's baseline is an untrained *network*,
   not a random-action agent. An untrained network favours one move and scores 492;
   a genuinely random agent scores 237. The notebook seeds the network before building
   it, so 492 is deterministic and should reproduce for the whole class. 492 is the
   number to beat. An earlier draft of the brief quoted 237 and was wrong.
2. **Five episodes made the agent worse**, 492 to 274, on all five seeds. Early training
   disrupts a network before it improves it. This is evidence for a long run, and it is
   worth reporting in the README.
3. **Throughput is uncertain between 62 and 169 decisions per second**, and the device is
   not the explanation — `config.json` confirms MPS in both cases. Left unresolved on
   purpose: the high episode ceiling makes the plan insensitive to it.

---

## 2026-09-08 · Proposed: raise the demonstration interval to 250 (awaiting confirmation)

**Proposed.** `DEMO_EVERY` from 25 to 250 for the overnight run only.

**Reason.** Checkpoints are 6.76 MB each, measured, and one is written per demonstration.
At an 8,000-episode ceiling the default interval would write 320 checkpoints and need
4.3 GB, on a drive with 23 GB free; 250 writes 32 and needs 0.4 GB. Each demonstration
also plays a full extra game, so 320 of them would cost roughly an hour of training time.
32 intermediate GIFs is well past the assignment's bar, which asks only for intermediate
GIFs "if your run reaches 25 episodes or more" and does not require them every 25.

**Trade-off to be aware of.** This is a visible deviation from the distributed notebook and
must be stated in the README with its reason.

---

## 2026-09-09 · Write the full reasoning before confirming the values

**Decided.** Produce `docs/REASONING.md` covering all six settings in depth — mechanism, numbers,
counter-argument, falsifier, and the likely grader question — before Hanif confirms any value.

**Reason.** The assignment grades the reasons for the choices, not only the score. Hanif has to
defend these in class, so the reasoning has to be his understanding, not a lookup table.

**Produced.** `docs/REASONING.md`. Writing it corrected three errors in earlier advice:

1. **The exploration argument is weaker than claimed.** Sticky actions run at 0.25, so the chance
   of executing a freshly chosen greedy move is 60% at epsilon 0.20 and 67.5% at 0.10 — a gap of
   7.5 points, not the large difference implied. Exploration is the least consequential of the
   three assigned choices, and its justification is mechanistic with no supporting measurement.
2. **"0.00025 is the classic DQN value" was sloppy.** That is the **RMSProp** value from the
   original paper. This notebook uses **Adam**, and rates do not transfer between optimisers.
   Adam DQN implementations sit at 0.0001 or below. This strengthens keeping the default.
3. **The "frames" comparison was ambiguous.** The Nature paper's "50 million frames" means agent
   decisions (~200 million emulator frames, its reported 38 days at 60 Hz). Comparisons now state
   the convention. The 4-12% overnight figure is correct on a decisions-to-decisions reading.

Also established: raising replay capacity does **not** increase how often each transition is
reused — that stays at about 8 times regardless, because capacity cancels. The benefit is the age
range of data within each batch. This is the precise form of the strongest argument of the six.

---

## Pending decisions

The three choices in `docs/BRIEF.md` §3 are not yet confirmed by Hanif. Record each here
when confirmed, with the reason, then copy the reasons into the README table.
Recommendations below are revised after the 8 September measurements.

- [ ] `EXPLORATION` — recommend `0.10`
- [ ] `EPISODES` — recommend `8000` as an unreachable ceiling, not a target
- [ ] `LEARNING_RATE` — recommend `0.0001`
- [ ] `REPLAY_CAPACITY` — recommend raising `5000` → `50000`
- [ ] `DEMO_EVERY` — recommend raising `25` → `250`
- [ ] `SHOW_POPUPS` — recommend `False` for an unattended run
- [ ] Prediction recorded *before* the run (brief §5, §7). Baseline to beat is **492**
- [ ] Public GitHub repository created, URL given to Claude

---

## 2026-09-11 · Final settings, and a six-hour run ended by a scheduled interrupt

**Decided.** Run overnight on 11 September, starting at 00:00 and ending at 06:00.
Settings: `EXPLORATION = 0.15`, `EPISODES = 20000`, `LEARNING_RATE = 0.0001`,
`REPLAY_CAPACITY = 50000`, `SHOW_POPUPS = False`. `DEMO_EVERY` stays at 25.
The interrupt is sent by a script at 06:00, not by hand.

**Alternatives considered.** `EXPLORATION = 0.10`, the value argued in `REASONING.md`
(not selected: 0.15 sits between the notebook's 0.20 and that recommendation, and Hanif
prefers the midpoint); `EPISODES = 8000` (rejected on measurement: at the fast measured
rate of 169 decisions per second, and at the measured 464 decisions per game, 8,000
episodes complete in 6.3 hours, so the ceiling could be reached before morning and the
machine would idle — 20,000 cannot be reached at either rate and costs nothing, because
checkpoints scale with episodes reached, not with the ceiling); `DEMO_EVERY = 250`
(not selected: Hanif keeps 25 for more intermediate GIFs, at a cost of about 40 minutes
of extra demonstration games and 2.5 GB of disk at the expected episode count);
interrupting by hand at 06:00 (rejected: it needs someone awake at 06:00).

**Reason.** The throughput measurement in `SMOKE_TEST.md` spans 62 to 169 decisions per
second, a spread of 2.7 times. No episode count can target a six-hour run across that
spread. A ceiling that neither rate reaches, plus a stop at a fixed clock time, makes the
run length exact and independent of throughput. The notebook catches `KeyboardInterrupt`,
records the status as `interrupted`, and saves the model, metrics and plot in a `finally`
block, so the evidence survives the interrupt.

**The exploration argument is the weakest one, and is now weaker.** `REASONING.md` already
ranks `EXPLORATION` last, on mechanism alone with no test. The reason for 0.15 is that it
is the midpoint between the notebook's starting value and the recommended value. State
this plainly to the grader. Do not present it as a measured choice.

**Free disk is 11 GiB, not the 23 GB assumed in `BRIEF.md`.** At `DEMO_EVERY = 25` the run
writes one 6.76 MB checkpoint every 25 episodes, and the notebook also writes a ZIP of the
run folder, which roughly doubles the cost. At an expected 3,000 to 4,600 episodes that is
about 2.5 GB. At 8,000 episodes it would be 4.3 GB. Both fit, but check free space before
the run starts.

**Produced.** Edited `pacman_dqn.ipynb` (five values, three cells, nothing else) and
`stop_training_at.sh`.

---

## 2026-09-13 · Run 2, the controlled experiment on the reward rule

**Decided.** Run the experiment notebook `pacman_dqn_rescaled.ipynb` from 01:00 to 07:00
on 13 September. One variable changes against run 1. The reward rule becomes
`sign(r) * (sqrt(|r| + 1) - 1) + 0.001r` in place of `clip(r, -1, 1)`. Every other
setting holds at the run 1 value: `EXPLORATION = 0.15`, `EPISODES = 20000`,
`LEARNING_RATE = 0.0001`, `REPLAY_CAPACITY = 50000`, `DEMO_EVERY = 25`,
`SHOW_POPUPS = False`, training seed 42. The evaluation settings are untouched:
seeds 101/202/303/404/505, 5% exploration, and a 3,000-decision cap.

**Why this variable.** Clipping makes every scoring event worth the same. A 1600-point
ghost and a 10-point pellet both become 1. The agent therefore cannot learn that a chain
of ghosts is worth more than a line of pellets. The square-root transform holds the
magnitudes low enough to train, but it keeps the order of the rewards. The small linear
term `0.001r` stops two large rewards from becoming equal after the square root.

**Alternatives considered.** A second run at the same settings, to measure the spread
between runs (rejected: it tests no idea, and the five evaluation seeds already give a
measure of spread); changing the exploration schedule instead (not selected: it is the
next experiment, and two changed variables in one run explain nothing); removing the
reward transform completely (rejected: unbounded rewards make the training unstable,
which is the reason clipping exists).

**Prediction, recorded before the run starts.** The baseline to beat is the run 1 result
of **2578**, and the run 1 spread across the five seeds was **1060**, from 2050 to 3110.

1. The average score after training is above 3110. That is above every run 1 seed, not
   only above the run 1 average.
2. The demonstration GIFs show scores of 800 and 1600 in one life. That is the agent
   eating a second and a third ghost after one power pellet.
3. The prediction error is larger than the 0.10 to 0.14 band of run 1, because the
   targets are no longer held between -1 and 1. It still does not fall as the play
   improves, for the reason given in `FINDINGS.md` section 2.
4. The rate stays near the 288 decisions per second of run 1. The transform adds one
   arithmetic operation for each decision.

**How the prediction can fail.** If the average after training falls inside the run 1
spread of 2050 to 3110, the change is within noise. The conclusion is then that the
reward scale was not the limit, and the exploration schedule is the better candidate.
Report that outcome in full. Do not report it as a smaller success.

**Machine conditions.** The Mac was restarted at 00:44. macOS reopened 21 applications on
login, and the load average was above 110. Chrome, Spotify, Zoom, Xcode, ChatGPT, Grok Bot
and the Claude application were closed. The load fell to 18. `cmux` stays open, because
the Claude Code session runs inside it. Run 1 measured 288 decisions per second on a quiet
machine, so run 2 needs the same conditions to be comparable. Free disk is 40 GiB. The run
needs about 3.7 GB.

**The window moved by one hour.** The plan was 00:00 to 06:00, the same clock as run 1.
The restart finished at 00:44, so that window had passed. The new window is 01:00 to 07:00.
The length is six hours in both runs. The length is the controlled variable. The time of
day is not.

**Produced.** Started `scripts/run_overnight.sh 01:00 07:00 pacman_dqn_rescaled.ipynb`
at 00:48, detached. The log is `logs/overnight_20260913_004801.log`.

---

## 2026-09-13 · Run 2 result. The prediction failed, and the experiment is reported as such

**Produced.** Run 2 finished at 07:01, status `interrupted` as designed, exit code 0.
It reached 9,269 episodes and 7,128,525 decisions in six hours, at 330 decisions per
second. The results are in `results2/`. The run folder is
`pacman_runs/20260913_010005_795866`.

**The result.** The square-root reward transform did not improve the play.

| Measure | Run 1, `clip(r,-1,1)` | Run 2, square root |
|---|---|---|
| Average before training | 492 | 492, the same five scores |
| Average after six hours | 2578 | 2298 |
| Spread across the five seeds | 1060 | 960 |
| Average at a matched 7,625 episodes | 2302 | 1660 |
| Episodes scoring 3000 or more | 3.3% | 1.4% |
| Average loss | 0.10 to 0.12 | 0.48 to 0.51 |

**The prediction was recorded at 00:48 and it failed.** Prediction 1 said the average
would go above 3110. It was 2298, which is below the run 1 average. Prediction 2 said the
demonstration games would show ghost chains. The opposite happened: the share of episodes
scoring 3000 or more fell from 3.3% to 1.4%. Predictions 3 and 4 held. The loss was larger
and did not fall, and the rate stayed near the run 1 value.

**State the result as noise, not as a small loss.** The difference in the averages after
six hours is 280. The spread across the five seeds is 960 to 1060. The change is smaller
than the spread, so the correct statement is that run 2 gives no evidence of a difference.
Run 2 was lower on three of the five seeds. It was higher on two.

**The matched-episode test was necessary, and it changes the reading.** Run 2 was 15%
faster, because the machine was quieter, so six hours bought it more experience. At the
matched point of 7,625 episodes, run 2 scored 1660 against 2302, and it was lower on four
of the five seeds. The extra experience was hiding part of the gap. The evidence is still
inside the spread, so the honest statement is: no evidence the transform helped, and weak
evidence that it hurt.

**Alternatives considered for the reading.** Reporting run 2 as a near-match that needs
more time (rejected: the brief forbids reading a result inside the spread as a smaller
success); reporting only the six-hour figures (rejected: the 15% rate difference is a real
confound, and the matched checkpoint removes it at no cost); repeating run 2 (not selected
now: it is the right next step, but the assignment is due and the null result is already
the finding).

**What this says about the limitation.** The written limitation claimed that reward
clipping removed the ordering of the rewards, and that restoring the ordering would unlock
ghost chains. Run 2 restored the ordering. Chains did not appear, and high-scoring episodes
became less common. The reward scale is therefore not the limit. The exploration schedule
is the better candidate, which is what the alternative next experiment already named. This
is a stronger write-up than one run, because the idea was tested and it was wrong.

**Produced.** `results2/`, `scripts/matched_eval.py`, and
`results2/matched_eval.json`.

---

## 2026-09-13 · Run 3, the exploration experiment

**Decided.** Run `pacman_dqn_explore.ipynb` from 10:30 to 16:30 on 13 September.
`EXPLORATION` changes from 0.15 to 0.10. Everything else holds at the run 1 value,
**including the reward rule**, which returns to `clip(r, -1, 1)`. The evaluation settings
stay fixed: seeds 101/202/303/404/505, 5% exploration, and a 3,000-decision cap.

**Built from run 1, not from run 2.** The notebook is a copy of `pacman_dqn.ipynb` with the
outputs removed and exactly one line changed, from `EXPLORATION = 0.15` to
`EXPLORATION = 0.10`. This was checked: the copy contains `np.clip(reward, -1, 1)` and
contains no square-root transform.

**Alternatives considered.** Keeping the square-root transform and changing exploration as
well (rejected: run 3 would then differ from run 1 by two variables, and could only be
compared with the weaker 2298 result of run 2; the transform already failed its own test,
so carrying it forward tests nothing); a decaying exploration rate (rejected: it adds a
schedule shape as a second new variable, and the notebook uses one constant rate after the
warm-up, so a constant is the smaller change); 0.05 to match the evaluation exactly
(not selected: the gap from 0.15 would be large, and a result could not be attributed to
the size of the step).

**Why this variable.** Exploration is constant after the warm-up:
`epsilon = 1.0 if total_steps < WARMUP_STEPS else EXPLORATION`. At 0.15, about one decision
in seven is random. In this game a random move beside a ghost often ends a life. The agent
is also tested at 0.05, so it is trained under noisier conditions than it is measured under.
Lowering the rate to 0.10 reduces that mismatch. `REASONING.md` recommended 0.10 originally,
and 0.15 was chosen as a midpoint, so this run tests the value that the reasoning preferred.

**Prediction, recorded before the run starts.** The baseline to beat is the run 1 result of
**2578**, with a spread across the five seeds of **1060**.

1. The average after six hours is higher than 2578, and lands between 2600 and 3100.
2. That improvement is **smaller than the spread**, so the correct report will again be
   "no evidence of a difference", not "an improvement". State it that way.
3. The matched-episode test is the more sensitive measure. At 7,625 episodes, run 3 scores
   above the run 1 value of 2302.
4. Run 3 completes **fewer** episodes than run 1's 7,628 in the same six hours. Better play
   means longer games, so the decision count per game rises while the rate stays near 330
   decisions per second.

**How the prediction can fail.** Less exploration can also lock the agent into a routine it
found early, so it never discovers the power pellet chains. If that happens the average
falls below 2578 and the share of episodes scoring 3000 or more drops below the 3.3% of
run 1. That outcome would say the exploration rate is not the limit either, and the next
candidate becomes the network update rule or the length of training.

**Prediction 2 is the important one.** Two runs have now produced differences smaller than
the spread. If run 3 does the same, the finding is not about any single setting. It is that
five evaluation games cannot resolve differences of this size, and that is a statement
about the method, which is worth more than a tuning result.

**Produced.** `pacman_dqn_explore.ipynb`.

---

## 2026-09-13 · Run 3 started on time. A mistake removed its stop signal, and it was restored

**What happened.** Run 3 started at 10:30 as scheduled, from the supervisor armed at 09:17.
At 11:20 Hanif asked to start the training now. I read the request as "it has not started
yet", and I stopped the supervisor to restart it. The time was 11:20, not 09:24. The run had
been training for 50 minutes.

**The training survived.** `kill` was sent to the supervisor shell only. The notebook runs
under `nbconvert`, which is a separate process, so the training continued without a break.
The run folder `pacman_runs/20260913_103052_091454` shows an unbroken record: 1,316 games,
846,225 decisions, and `exploration = 0.1` in every row.

**Two things were lost, and both were restored within one minute.** The supervisor held the
interrupt for 16:30, and it held the `caffeinate` that keeps the Mac awake. Stopping it
removed both. `scripts/stop_training_at.sh 16:30` was started in its place. It found the same
kernel, PID 65638, and it holds the machine awake until 16:30.

**Decided: keep the run that is already going. Do not restart it.** A restart would discard
50 minutes and move the six-hour window for no gain. The run began at the planned time, under
the planned conditions, with the prediction already committed at 09:17.

**One difference from the other runs.** `stop_training_at.sh` sends the interrupt and then
exits. It does not wait for the evaluation and it does not write the summary line to the log.
The output of the notebook still reaches `logs/overnight_20260913_091748.log`, because
`nbconvert` inherited that file. The result must be read from the run folder at about 16:45,
and not from the end of the log.

**The lesson, and it is mine.** I checked the clock at the start of the session and then
assumed time from the conversation. A tool call is the only source for the time. Read the
clock before any action that depends on it.

**Disk is the open risk.** Free space fell from 40 GiB to 22 GiB during the day. The project
is 9.4 GB. macOS is staging an operating system update, which is taking the rest. Run 3 needs
about 5.5 GB and has written 344 MB so far. The three ZIP files in `pacman_runs/` duplicate
their run folders and hold 4.0 GB. They can be deleted to recover that space, and rebuilt
from the folders. This was not done, because deleting is not reversible and Hanif did not
ask for it.

---

## 2026-09-13 · Run 3 result. Every part of the prediction was wrong, and the limitation changed

**Produced.** Run 3 finished at 16:30, status `interrupted`, 7,659 games and 6,083,408
decisions at 282 decisions per second. The results are in `results3/`. The run folder is
`pacman_runs/20260913_103052_091454`.

**The result. Lowering the exploration rate made the play worse.**

| | Run 1 | Run 2 | Run 3 |
|---|---|---|---|
| Exploration | 0.15 | 0.15 | **0.10** |
| Reward rule | clipping | square root | clipping |
| Average after six hours | **2578** | 2298 | **1748** |
| Games completed | 7,628 | 9,269 | 7,659 |
| Ghosts eaten, five test games | 16 | 12 | **5** |
| Power pellets eaten | 20 | 19 | 20 |

**Decided: report run 3 as a real difference, and run 2 as no difference.** These two are
reported differently on purpose, and the test is the one `FINDINGS.md` section 1 already used
for run 1. Run 3 is worse on five of five seeds, and the two sets of five scores overlap by
30 points. Run 2 was worse on three of five, and the sets overlap widely. Run 3 also completed
7,659 games against run 1's 7,628, so the experience confound that run 2 needed a matched test
to remove does not exist here. The matched test was still run, and it agrees: 1708 against
2302.

**Alternatives considered.** Calling both results noise, for consistency (rejected: it would
be the same error in the opposite direction, and it would hide the one real between-run signal
in the project); calling both real (rejected: run 2's difference is smaller than the spread,
and the brief is explicit about that case); repeating run 3 to confirm (not selected: no time
before the deadline, and the ghost count already gives a second, independent measurement that
points the same way).

**The limitation is now in its third version, and this one is about experience.**

1. Before run 1, from the code: the agent will never eat a power pellet or chase a ghost.
   Wrong. It does both.
2. After run 1, from the gameplay: clipping makes a full chain worth the same as one pellet,
   so the agent does not finish the chain. The arithmetic is correct, but run 2 corrected the
   price and nothing changed.
3. Now, from three runs: the agent almost never experiences a chain, so it cannot learn one.
   Random movement is what produces the first accidental ghost.

**The evidence for version 3 is the ghost count, not the score.** All three agents ate about
the same number of power pellets: 20, 19, 20. The behaviour that starts a chain is identical.
The ghosts eaten afterwards moved with the exploration rate and not with the reward rule:
5 at 0.10, and 16 at 0.15. A network learns only from what its memory holds, so a price cannot
teach an experience that never happened.

**A second sign, recorded as a sign and not as proof.** Run 1 gains 600 points when the random
moves are removed for the test, from 1978 to 2578. Run 3 loses 137, from 1885 to 1748. The two
numbers are measured differently, so this supports the reading and does not establish it.

**The next experiment is now the opposite direction.** Raise exploration from 0.15 to 0.25 and
judge it on the count of ghosts first, and the score second. The likely outcome is more ghosts
and a lower score, because random moves also walk the agent into ghosts that are not edible.
That outcome would still confirm version 3, and it would be the first measurement in this
project that moves the behaviour on purpose rather than guessing at a setting.

**A correction to the tooling.** `scripts/matched_eval.py` had the labels `run1_clip` and
`run2_sqrt` written into it, so it mislabelled the run 3 comparison on the first call. It now
takes `LABEL=PATH` arguments. The run 2 file `results2/matched_eval.json` was checked and is
unchanged, and still holds 1660.

**Produced.** `results3/`, and the run 3 sections of `README.md` and `FINDINGS.md`
(sections 11, 12 and 13).

---

## 2026-09-13 · Run 4, the test of the encounter explanation

**Decided.** Run `pacman_dqn_explore25.ipynb` from 00:00 to 06:00 on 14 September.
`EXPLORATION` changes from 0.15 to 0.25. The reward rule stays at `clip(reward, -1, 1)`, so
run 4 differs from run 1 by one setting. Every other value holds. The evaluation settings are
untouched: seeds 101/202/303/404/505, 5% exploration, a 3,000-decision cap.

**Built from run 1 again, and checked.** The notebook is a copy of `pacman_dqn.ipynb` with the
outputs removed and exactly one line changed. The copy was tested for `np.clip(reward, -1, 1)`
and for the absence of any square-root term. All four notebooks were then compared, and each
differs only in the two intended places:

| Notebook | Exploration | Reward rule |
|---|---|---|
| `pacman_dqn.ipynb` | 0.15 | clipping |
| `pacman_dqn_rescaled.ipynb` | 0.15 | square root |
| `pacman_dqn_explore.ipynb` | 0.10 | clipping |
| `pacman_dqn_explore25.ipynb` | **0.25** | clipping |

**Why this direction.** Runs at 0.10 and 0.15 gave ghost counts of 5 and 16. That is two
points on a line, and two points cannot show a relation. A third rate above 0.15 tests whether
the count continues to rise. Lowering the rate again would only repeat what run 3 showed.

**Alternatives considered.** Repeating run 1 at 0.15 to measure the spread between runs
(rejected: it tests no idea, and the deadline allows one more run); a longer run at 0.15
(not selected: it changes the length, which is the one variable held constant in every run so
far, and the encounter question can be answered in six hours); adding a reward for being near
an edible ghost (rejected: that is two changes, a new reward term and a new shape, and it
would answer nothing cleanly).

**Prediction, recorded before the run starts.** The number that matters is the ghost count,
and not the score. Run 1 ate 16 ghosts in the five test games.

1. **Ghosts eaten rises above 16.** This is the test of the explanation. I expect 20 to 30.
2. **The average score falls below 2578.** I expect 1800 to 2500. More random movement also
   walks the agent into ghosts that are not edible, and that cost is larger than the gain.
3. **Payments of 800 stay at zero.** Eating three ghosts in one power-pellet window needs
   moves that follow each other. Random movement produces encounters. It does not produce a
   sequence.
4. **Games completed rises above 7,628.** More random deaths make games shorter, so more games
   fit into six hours.

**Items 1 and 2 together are the point of the run.** If both hold, the run separates the
mechanism from the score for the first time in this project. It would show the behaviour
moving in the predicted direction while the grade gets worse, which no run so far has done.

**How the prediction can fail, and what each failure means.**

- If the ghost count does not rise above 16, the encounter explanation is wrong. Exploration
  would then look important only because 0.10 is too low for some other reason. The next
  candidates become the length of the run and the rule that updates the network.
- If the ghost count rises **and** the score also rises above 2578, then 0.15 was simply too
  low, and the explanation is right but incomplete.
- Item 3 is the one I most want to be wrong about. A single payment of 800 would be the first
  evidence in four runs that a chain can be learned at all.

**Item 3 admits a limit in my own explanation.** If encounters were sufficient, more
encounters should eventually produce a chain. I predict they will not. That means the
encounter explanation accounts for why the agent eats a first and second ghost, and not for
why it never eats a third. Say this in the write-up. Do not present the explanation as
complete.

**Disk.** Free space is 26 GiB. A run at a higher exploration rate is expected to complete
more games, so it writes more checkpoints: perhaps 400 to 480, against run 3's 308. With the
archive that is about 7 GB. It fits. Check the figure before the run starts.

**Produced.** `pacman_dqn_explore25.ipynb`.
