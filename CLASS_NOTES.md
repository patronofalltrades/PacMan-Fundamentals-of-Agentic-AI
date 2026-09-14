# Class notes

One page to speak from. The full work is in the [README](README.md).

---

## The shape of the talk

I trained an agent. It worked. Then I twice predicted how to make it better, ran the
experiments, and was wrong both times. **The two failures are the result.** They moved my
explanation of the agent from a guess about reward to a measured claim about experience.

---

## 1. The agent learned — 492 to 2578

**The headline number is 2578, from run 1: clipping, exploration 0.15, six hours.** That is
the best of every run, and it is the result to lead with.

| | 101 | 202 | 303 | 404 | 505 | **Average** |
|---|---|---|---|---|---|---|
| Before | 350 | 500 | 320 | 800 | 490 | 492 |
| **After** | **2790** | **2330** | **2610** | **3110** | **2050** | **2578** |

Same five seeds, same settings, before and after. All five games improved.
Six hours. 7,628 games. 1.56 million corrections to the network.

**It is not luck.** The gain is 2086. The spread across the five results is 1060. The worst
game after training beats the best game before training. The two sets do not overlap.

**The loss never fell.** It stayed level for the whole run while the score more than doubled.
The network is graded against a goal it also produces. As the agent improves, the goal moves
away as fast as it approaches. A walker never gets closer to the horizon.

---

## 2. What the agent does, and where it stops

In Ms. Pac-Man you eat a power pellet, then the four ghosts become edible. They pay 200, 400,
800 and 1600. That is 3000 points, and most of it is in the last two.

- It **learned to eat power pellets**. 5% of early games, 100% of late games.
- It **eats ghosts**. The reward record shows +200, then +400.
- It **never eats a third**. No +800, no +1600. Not once, in any test game of any run.

I predicted before run 1 that it would never chase ghosts at all. It does. That was the first
correction.

---

## 3. My explanation, and the experiment that killed it

**The claim.** The agent never sees a game point. Every scoring event is cut down to 1 before
it learns from it. That is reward clipping, from the 2015 DQN paper.

Two ghosts left, across the maze. The trip costs about 20 decisions, or five pellets.

| | Chase the ghosts | Eat five pellets |
|---|---|---|
| In real game points | 2400 | 50 |
| In what the agent learns from | 2 | 5 |

**Clipping does not weaken the reason to chase. It reverses it.**

**Run 2 tested it.** I replaced clipping with a square-root rule, which keeps the rewards in
order. A 1600-point ghost became worth 17 pellets instead of 1. One line changed.

| | Run 1, clipping | Run 2, square root |
|---|---|---|
| Average | 2578 | 2298 |
| Third ghost, ever | 0 | **0** |

**Nothing changed.** The arithmetic above is still correct, and it is not the reason the agent
stops.

*Say this plainly: 2298 against 2578 is not a loss. The spread across five games is about
1000, so a gap of 280 is no difference at all. Five games cannot separate two numbers that
close.*

---

## 4. The second experiment, and what it revealed

Run 2 said the next suspect was exploration. Run 3 lowered it from 0.15 to 0.10.

| | Run 3 (0.10) | Run 1 (0.15) | Run 2 (0.15) |
|---|---|---|---|
| Average | **1748** | 2578 | 2298 |
| Power pellets eaten | 20 | 20 | 19 |
| **Ghosts eaten** | **5** | **16** | **12** |

**This one is a real difference.** Worse on five of five games, and the two sets of scores
overlap by 30 points. Same test I used to call run 1's gain real.

Look at the two middle rows, because that is the whole finding:

> **Every agent eats power pellets at the same rate. What changes is what happens next, and it
> moves with exploration, not with reward.**

---

## 5. The finding

**The agent stops after one or two ghosts because it almost never experiences a chain, not
because a chain is worth too little.**

A network learns only from what its memory holds. Run 2 raised the price of an experience the
memory does not contain, and a price cannot teach an experience that never happened. Run 3 made
those experiences rarer, and the ghost count fell with it.

Random movement is what puts the agent beside an edible ghost the first time. That accident is
the start of the loop.

> **The reward rule sets the price. It does not make the agent walk to the shop.**

My limitation has now had three versions. Version 1 came from reading the code and was wrong.
Version 2 came from the gameplay and was wrong. Version 3 came from two experiments that each
changed one thing.

---

## 6. What I would change next

**Raise exploration from 0.15 to 0.25, and judge it on the ghost count before the score.**

| Ghosts eaten | Score | What it means |
|---|---|---|
| More than 16 | Up | The explanation holds, and it is also better play |
| More than 16 | Down | The explanation holds. Random moves also walk it into ghosts that are not edible |
| 16 or fewer | Either | The explanation is wrong |

**The middle row is what I expect.** It would confirm the mechanism while the score gets worse,
and that is the point: it would be the first measurement in this project that moves the
behaviour on purpose instead of guessing at a setting.

## Lessons learned, in six lines

1. **A falling error is not progress, and neither is a rising score.** The error stayed level
   while the score doubled. A gain smaller than the spread across five games is not a gain.
2. **Decide what counts as a difference before you see the number.** Every game must move the
   same way, and the two sets must not overlap. Run 2 fails it. Run 3 passes it.
3. **Match runs on experience, not only on time.** Run 2 was 15% faster, so six hours bought it
   more practice. Testing both networks at game 7,625 changed the gap from 280 to 642.
4. **Count behaviour, not just score.** The measurement that settled the reward question was a
   count of zero third ghosts. A zero needs no statistics.
5. **A price cannot teach an experience that never happened.** That is the finding, and it
   transfers to any problem where the useful event is rare.
6. **Publish the version that was wrong.** Three explanations, each measured and replaced, is
   worth more than one that was never put at risk.

---

## Numbers to have ready

| | |
|---|---|
| Before / after | 492 → 2578 |
| The five after scores | 2790, 2330, 2610, 3110, 2050 |
| The three run averages | 2578 / 2298 / 1748 |
| Ghosts eaten, five test games | 16 / 12 / 5 |
| Games / decisions / corrections | 7,628 / 6.2 million / 1.56 million |
| Speed | 288 decisions per second |
| Against the 2015 DQN paper | 12.5% of its decisions |
| Survival | 589 → 976 decisions per game |
| Points per decision | 0.84 → 2.64 |

---

## If someone asks

**"The loss did not go down. Did it actually learn?"**
Yes. Look at the score, not the loss. The goal moves away as fast as the network approaches it.

**"You ran three times and only the first worked. Is that a failure?"**
No. Run 1 gave a number. Runs 2 and 3 gave an explanation, and an explanation transfers to the
next problem. Both were one-variable experiments with the prediction committed to git before
the run started.

**"Why is run 2 'no difference' but run 3 'worse'? That looks convenient."**
Same test for both, and I stated it before applying it. Run 3 is worse on five of five games
with almost no overlap between the two sets. Run 2 is worse on three of five with wide
overlap, and the gap is smaller than the spread. The asymmetry is in the data, not in the
choice of test.

**"Could run 3 just have had less training?"**
No, and that was checked. Run 3 played 7,659 games against run 1's 7,628. I also tested both
saved networks at the identical point, game 7,625: run 1 scored 2302, run 3 scored 1708.

**"Why not just remove the clipping?"**
A 1600-point reward makes one huge correction, and that can destroy the network. Clipping is a
cheap guard. The square-root rule is the proper version. It just did not help here.

**"Is an interrupted run valid?"**
Yes, by design. The computer speed was uncertain by 2.7 times, so no game count gives a run of
known length. I fixed the length instead: six hours, one stop signal, and the notebook catches
it and saves everything.

**"What mattered most?"**
Restarting the computer. After a restart the speed nearly doubled, from 62–169 to 288 decisions
per second. That was worth more than any setting I picked. It also became a confound later:
run 2 ran 15% faster than run 1 for that reason alone, and I had to test both networks at the
same game number to remove it.

**"Why is the notebook blank on GitHub?"**
It is 14.6 MB. GitHub gives up. There is an nbviewer link at the top of the README.
