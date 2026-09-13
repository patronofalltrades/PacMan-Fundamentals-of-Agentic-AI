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
