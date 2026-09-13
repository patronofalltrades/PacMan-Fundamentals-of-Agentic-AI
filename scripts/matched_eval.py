"""Evaluate two checkpoints at the same episode count, on the fixed eval settings.

Reuses the notebook's own definition cells, so the evaluation is the same code
that produced the before-and-after numbers. Nothing is trained and nothing is
written into the run folders.
"""
import json, sys, pathlib
NB = pathlib.Path("pacman_dqn_rescaled.ipynb")
cells = json.loads(NB.read_text())["cells"]
g = {"__name__": "__main__"}
for i in (2, 4, 8, 10, 12, 15, 17, 19, 21, 23, 25):      # constants, env, model, helpers
    exec("".join(cells[i]["source"]), g)

import torch, numpy as np
g["N_ACTIONS"] = 9
g["DEVICE"] = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
exec("".join(cells[30]["source"]), g)                    # def evaluate

evaluate, DQN, DEVICE = g["evaluate"], g["DQN"], g["DEVICE"]
print(f"device: {DEVICE}  eval seeds: {g['EVAL_SEEDS']}  "
      f"exploration: {g['EVAL_EXPLORATION']}  cap: {g['MAX_STEPS']}", flush=True)

out = {}
for label, path in [("run1_clip", sys.argv[1]), ("run2_sqrt", sys.argv[2])]:
    ck = torch.load(path, map_location="cpu", weights_only=True)
    model = DQN(ck["n_actions"]).to(DEVICE)
    model.load_state_dict(ck["model"])
    r = evaluate(model, g["EVAL_SEEDS"])
    r["episode"] = ck["episode"]
    out[label] = r
    print(f"{label}  ep {ck['episode']}  scores {[int(x) for x in r['scores']]}  "
          f"mean {r['mean']:.0f}", flush=True)

print()
a, b = out["run1_clip"], out["run2_sqrt"]
print(f"matched at episode {a['episode']}:  run1 {a['mean']:.0f}   run2 {b['mean']:.0f}   "
      f"diff {b['mean'] - a['mean']:+.0f}")
json.dump(out, open("matched_eval.json", "w"), indent=2)
