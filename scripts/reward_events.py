"""Count what the game actually paid, decision by decision, in the five test games.

Section 8 of FINDINGS read the score from the pictures of the animations. That
method sees only the first 20 seconds of one game. This reads the reward the
emulator pays at every decision of all five test games, so a ghost chain cannot
be missed.

Ms. Pac-Man pays 200, 400, 800 and 1600 for the four ghosts of one chain.
A rise of 800 or 1600 is therefore proof of a third or fourth ghost.

Usage:  reward_events.py LABEL=CHECKPOINT [LABEL=CHECKPOINT ...]
"""
import json, sys, pathlib, collections
NB = pathlib.Path("pacman_dqn_rescaled.ipynb")
cells = json.loads(NB.read_text())["cells"]
g = {"__name__": "__main__"}
for i in (2, 4, 8, 10, 12, 15, 17, 19, 21, 23, 25):
    exec("".join(cells[i]["source"]), g)

import torch, numpy as np, random
DQN, make_env, choose_action = g["DQN"], g["make_env"], g["choose_action"]
EVAL_SEEDS, EVAL_EXPLORATION, MAX_STEPS = g["EVAL_SEEDS"], g["EVAL_EXPLORATION"], g["MAX_STEPS"]
DEVICE = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
GHOST = {200.0: "ghost 1", 400.0: "ghost 2", 800.0: "ghost 3", 1600.0: "ghost 4"}

def run(path):
    ck = torch.load(path, map_location="cpu", weights_only=True)
    model = DQN(ck["n_actions"]).to(DEVICE); model.load_state_dict(ck["model"]); model.eval()
    env = make_env()
    tally, scores, chains = collections.Counter(), [], []
    try:
        for seed in EVAL_SEEDS:
            rng = random.Random(seed + 10000)
            obs, _ = env.reset(seed=seed)
            total, this = 0.0, []
            for _ in range(MAX_STEPS):
                a = choose_action(model, obs, EVAL_EXPLORATION, rng, ck["n_actions"])
                obs, r, ended, trunc, _ = env.step(a)
                total += r
                if r:
                    tally[float(r)] += 1
                    if float(r) in GHOST:
                        this.append(int(r))
                if ended or trunc:
                    break
            scores.append(total); chains.append(this)
    finally:
        env.close()
    return ck["episode"], tally, scores, chains

for arg in sys.argv[1:]:
    label, path = arg.split("=", 1)
    ep, tally, scores, chains = run(path)
    print(f"\n===== {label}  (episode {ep}) =====")
    print(f"scores: {[int(s) for s in scores]}   mean {np.mean(scores):.0f}")
    print("ghost rewards paid, across all five games:")
    for v, name in GHOST.items():
        print(f"   {name:8s} {int(v):>5} points : {tally.get(v, 0):>3}")
    print(f"   power pellets (50)      : {tally.get(50.0, 0):>3}")
    print("per game, the ghosts eaten in order:")
    for s, c in zip(EVAL_SEEDS, chains):
        print(f"   seed {s}: {c if c else 'none'}")
