# Overnight run plan — Friday 11 September 2026

Target: start Friday evening, stop Saturday morning, submit over the weekend.
This is the checklist. Everything marked DONE is already prepared.

---

## A. Prerequisites

### 1. Software — DONE

| Item | Status |
|---|---|
| Python 3.13.15 in `.venv` | ready |
| PyTorch 2.14.0, Metal (MPS) confirmed working | ready |
| gymnasium 1.3.0, ALE 0.11.2, OpenCV, NumPy, Matplotlib, Pillow | ready |
| Ms. Pac-Man ROM | bundled with ALE 0.11.2, no separate download |
| Notebook, `pacman_player.py`, `requirements.txt` | copied from upstream, unmodified |
| Full notebook executed end to end as a 5-episode test | see section E |

Nothing needs installing on Friday. There is no login, no API key, and no account to set up.
The whole thing runs offline once the packages are in place.

### 2. Disk space — RESOLVED, no action needed

Your drive is at 95% full, with 23 GB free. I checked what a long run actually writes.
Checkpoints dominate: each is **6.76 MB**, measured, and one is written at every demonstration.
GIFs are trivial at about 30 KB each. The final ZIP duplicates the whole run folder.

At the notebook's default demonstration interval of 25 episodes, an 8,000-episode ceiling would
write 320 checkpoints and need **4.3 GB**. Raising the interval to 250 reduces that to **0.4 GB**:

| Demo interval | Checkpoints | Run folder | With ZIP |
|---|---|---|---|
| 25 (default) | 320 | 2,177 MB | 4.3 GB |
| **250 (proposed)** | **32** | **230 MB** | **0.4 GB** |

32 intermediate GIFs and checkpoints is ample evidence, and well past the assignment's bar,
which asks only for intermediate GIFs "if your run reaches 25 episodes or more".
It also saves time: each demonstration plays a full extra game, so 320 of them would cost
roughly an hour of the night that should go to training.

So no disk clearing is required. 23 GB is still tight for macOS generally, but it does not block this run.

### 3. Power and sleep — ACTION NEEDED on the night

- Plug the laptop into mains power. On battery, macOS reduces performance, and the run may
  stop when the battery empties.
- Turn off Low Power Mode.
- **Leave the lid open.** A closed lid sleeps the machine, and a sleeping machine suspends the run.
- Open a second terminal window and run this. Leave it running all night:
  ```sh
  caffeinate -is
  ```
  This stops the Mac from sleeping. Press Ctrl+C in that window when the run is done.
- Quit Chrome, Slack, Zoom, and anything else heavy. They compete for the same GPU.
- Put the laptop on a hard surface, not a bed or a cushion. A hot machine slows itself down.

### 4. GitHub — ACTION NEEDED, can do before Friday

Create an empty **public** repository. Do not add a README, since we already have one.
Then tell me the URL and I will connect this folder to it.

This folder is already a git repository with the correct `.gitignore`:
model checkpoints and raw run folders stay out, and `results/` is published.

### 5. Your prediction — ACTION NEEDED before you start

The assignment marks "what you expected before training, followed by what you observed."
Write the prediction **before** the run, not after. I will put it in the README.
You need one or two sentences on what you think will happen to the score, and why.

For reference, **the untrained baseline scores exactly 492**: 350, 500, 320, 800, 490 on the five
evaluation seeds. That is measured from the real notebook, and it is deterministic, because the
notebook fixes the seed before it builds the network. You will get those same five numbers on
Friday, and so will every classmate running the unmodified notebook. 492 is the number to beat.

Note also that the 5-episode test made the agent **worse**: 492 down to 274. Early training
disrupts a network before it improves it, so a short run is not merely useless, it is harmful.

---

## B. Settings to confirm

| Setting | Current | Proposed | Why |
|---|---|---|---|
| `EXPLORATION` | 0.20 | **0.10** | Close to the 5% used at scoring, so training resembles the test |
| `EPISODES` | 100 | **8000** | A ceiling you will not reach. You stop it when you want (see section C) |
| `LEARNING_RATE` | 0.0001 | **0.0001** | Unchanged. The stable value for a long run |
| `REPLAY_CAPACITY` | 5000 | **50000** | 5,000 is about 8 games of memory. 50,000 is about 100 |
| `SHOW_POPUPS` | True | **False** | Stops a window opening overnight. GIFs are still saved either way |
| `DEMO_EVERY` | 25 | **250** | 32 checkpoints instead of 320: 0.4 GB instead of 4.3 GB, and an hour saved |

Everything else stays as distributed, including all five evaluation seeds, the 5% evaluation
exploration, and the 3,000-decision cap. That keeps your leaderboard number comparable with the class.

**`EPISODES = 8000` is not a promise to run 8,000 games.** It is a ceiling you will not reach.
Setting it high means the run never stops on its own while you are asleep, so you get every hour
you paid for. Measured throughput is between 62 and 169 decisions per second (see section E),
which over ten hours is 2.2 to 6.1 million decisions. Games also lengthen as the agent improves,
so the episode count is not predictable in advance. The ceiling removes the need to predict it.

---

## C. The night itself

1. Do section A3, the power and sleep steps.
2. Open the notebook and confirm the five values in section B.
3. Write down your prediction.
4. Choose Run All.
5. Watch the first three or four minutes. You want to see:
   - `Using MPS; training-batch check passed.`
   - The baseline evaluation finish, printing five scores.
   - `Episode 1/8000 | score ... ` and then episode 2, 3, 4.
   If those appear, it is working. Go to bed.
6. **Saturday morning: press the Interrupt / Stop button once.** Only once.
   The notebook catches it, saves the model, the metrics and the plot, and prints
   `Stopped early. Saving your agent; continue to section 6 for results.`
7. Run the remaining cells from section 6 onward. These do the trained evaluation,
   the comparison table, the final GIF and the ZIP. It takes a few minutes.
8. Save the notebook **with its outputs**. Do not clear them.

**Do not press Stop twice.** A second interrupt can break the save.

If something goes wrong overnight, the run folder under `pacman_runs/` still holds everything
written up to that point, including `training.csv` and the periodic checkpoints. Nothing is lost.

---

## D. Saturday, after the run

I will do these with you:

1. Run `./collect_results.sh` to copy the evidence into `results/`.
2. Fill the README from the real numbers: all five before scores, all five after scores,
   both means, episodes completed, decisions, updates, elapsed time, hardware.
3. Choose which of the intermediate GIFs to embed.
4. Report the run honestly as **interrupted**, and state the completed episode count.
   The assignment asks directly for this. It is not a penalty.
5. Push to GitHub, check the repository in a private browser window, and submit the URL.

---

## E. Verification record

A 5-episode execution of the real notebook through the same kernel, to prove the whole path works
before committing a night to it.

- Result: see `docs/SMOKE_TEST.md`
