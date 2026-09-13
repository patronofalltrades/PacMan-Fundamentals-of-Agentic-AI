# Class notes

One page to speak from. The full work is in the [README](README.md).

---

## The result

| | Average of five test games |
|---|---|
| Before training | 492 |
| After training | **2578** |

Same five seeds, same settings, before and after. All five games improved.
Six hours. 7,628 games. 1.56 million corrections to the network.

**It is not luck.** The gain is 2086. The spread across the five results is 1060. The worst
game after training beats the best game before training.

---

## My three settings

| Setting | Value | Reason in one line |
|---|---|---|
| Exploration | 0.15 | Between the default 0.20 and the 0.10 I argued for. **My weakest reason. I did not test it.** |
| Episodes | 20,000 | A limit I could not reach. The clock ended the run, not the count. |
| Learning rate | 0.0001 | Unchanged. The standard value. A long run needs steady progress. |

I also raised the memory from 5,000 to 50,000 experiences. 5,000 is about eight games, so the
program kept learning from the same few minutes and forgot everything else.

---

## What I got wrong

Three things. All three were wrong in a good direction.

1. I expected **at least one** of the five games not to improve. All five improved.
2. I expected the **error to fall while the score stayed level**. The opposite happened. The
   error stayed level and the score doubled.
3. I wrote that the program **would never chase ghosts**. It chases ghosts.

The third one is the interesting one.

---

## The finding worth explaining

**I said the program would never use the advanced strategy. I checked, and I was wrong.**

In Ms. Pac-Man you eat a power pellet, then the four ghosts become edible. They pay 200, 400,
800 and 1600. That is 3000 points, and most of it is in the last two.

I measured the recorded games picture by picture. Two results:

- The program **learned to eat power pellets**. 5% of early games, 100% of late games.
- The program **eats ghosts**. The score shows +200, then +400.
- The program **never eats more than two**. No +800. No +1600. Not once, in the 12 games I read.

### Why

The program never sees a game point. Every scoring event is cut down to 1 before it learns
from it. That is called reward clipping, and it comes from the original 2015 DQN paper.

So take the decision it faces with two ghosts left, across the maze. The trip costs about 20
decisions, or about five pellets.

| | Chase the ghosts | Eat five pellets |
|---|---|---|
| In real game points | 2400 | 50 |
| In what the program learns from | 2 | 5 |

**Clipping does not weaken the reason to chase. It reverses it.**

> The program did not fail. It learned its instructions perfectly. The instructions were wrong
> about what the game is worth.

---

## What I would change next

Replace clipping with a square-root rule. It keeps big rewards bigger than small ones, but
still small enough to train safely. A 1600-point ghost becomes worth about 17 pellets instead
of 1. The true ratio is 160, so the rule restores the order without restoring the full size.

Ape-X and R2D2 use the same function, but they apply it to the predicted value rather than to
the reward. Applying it to the reward is the simpler version of the same idea.

**How I would know I was wrong:** run it again, and if there is still no +800 or +1600, the
reward is not the limit. Exploration would be the next suspect.

---

## Numbers to have ready

| | |
|---|---|
| Before / after | 492 → 2578 |
| The five after scores | 2790, 2330, 2610, 3110, 2050 |
| Games / decisions / corrections | 7,628 / 6.2 million / 1.56 million |
| Speed | 288 decisions per second |
| Against the 2015 DQN paper | 12.5% of its decisions |
| Survival | 589 → 976 decisions per game |
| Points per decision | 0.84 → 2.64 |

---

## If someone asks

**"The loss did not go down. Did it actually learn?"**
Yes. Look at the score, not the loss. The network is graded against a goal it also produces.
As the program gets better, the goal moves away as fast as it approaches. The gap stays the
same. A walker never gets closer to the horizon.

**"Why not just remove the clipping?"**
A 1600-point reward makes one huge correction, and that can destroy the network. Clipping is a
cheap guard. The square-root rule is the proper version: it shrinks the number without
throwing away which reward was bigger.

**"Is the run interrupted? Does that count?"**
Yes, by design. The computer speed was uncertain by 2.7 times, so no game count gives a run of
known length. I fixed the length instead: start at 00:47, one stop signal at 06:47. The
notebook catches it and saves everything.

**"What mattered most?"**
Restarting the computer. It had been running 30 days with its memory 90% full. After the
restart the speed nearly doubled, from 62–169 to 288 decisions per second. That was worth more
than any setting I picked.

**"Why is the notebook blank on GitHub?"**
It is 14.6 MB. GitHub gives up. There is an nbviewer link at the top of the README.
