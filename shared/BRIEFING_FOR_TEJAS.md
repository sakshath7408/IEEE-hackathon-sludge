# Briefing for Tejas — read this before writing any more code

**Written 2026-09-20 01:30 IST by Sakshath's side.**
**Supersedes `gridpoint/HANDOFF_SAKSHATH.md`, which is now out of date.**

Paste this whole file into your Claude session. It assumes zero shared context —
your Claude cannot see our chat, only these files.

---

## 1. THE DELIVERABLE CHANGED. There is no Streamlit app.

`HANDOFF_SAKSHATH.md` says *"`app.py` — the thing that gets filmed"* and *"you
should not need to touch any of the three compute files."* The first half is no
longer true. The second half still is.

**What is actually being submitted:** a **Next.js + TypeScript web app deployed
to Vercel**, with no backend at all.

**Why:** Streamlit cannot deploy to Vercel — it needs an always-on Python server
holding a WebSocket per user, and Vercel runs stateless serverless functions.
There is no workaround. Hosting the Python on a free tier was rejected because
free tiers cold-start for ~50 seconds, which is the single most common way a live
demo dies in front of judges. Zero backend means zero cold start.

**What this means for you:** do not build or optimise for `app.py`. Do not wait
on `data.py`. Neither is part of the submission.

Full reasoning: `decisions/2026-09-20-typescript-port-and-cross-validation.md`.

---

## 2. The code repo exists

**https://github.com/sakshath7408/gridpoint** (public)

Your `solver.py`, `engine.py` and `verifier.py` are already in it under
`python/`, so judges see one repo containing both halves. The README credits you
as the author of record for the mathematics.

This context repo (`IEEE-hackathon-sludge`) stays notes-only.

---

## 3. Your contract was right. Do not change it.

Your `run()` returns `warehouses`, `assignments`, `total_cost`, `baseline_cost`,
`improvement_pct`. That matches what the TypeScript side built against, exactly.
Two people implemented to a written contract without speaking and it lined up.

**Keep those five keys frozen.**

Three additive keys are named differently between the two implementations:

| Yours | Ours |
|---|---|
| `loads` | `load` |
| `unserved` | `out_of_radius` |
| `baseline` | `baseline_warehouse` |

**You do not need to change anything.** The web engine now emits *both* namings,
so either implementation drops into the UI unchanged.

---

## 4. CROSS-VALIDATION PASSES — and this is our best exhibit

`npm run crossval` in the code repo runs **your `solver.py`** and the TypeScript
`lib/solver.ts` on the same 13-neighborhood dataset (your `SAMPLE_NEIGHBORHOODS`,
adopted as canonical) and compares them.

They are **not** identical by construction: your Weiszfeld runs on a local
tangent-plane projection, ours runs directly on the sphere with haversine, and
the restart seeds differ. So this is a real measurement:

```
   K  |  python (order-km)  typescript (order-km)   gap    worst site gap
  ----+-------------------------------------------------------------------
   1  |          55490.66              55490.74   +0.000%        0.000 km
   2  |          37539.79              37539.82   +0.000%        0.002 km
   3  |          30378.14              30378.17   +0.000%        0.002 km
   4  |          23720.15              23720.18   +0.000%        0.000 km
   5  |          17904.77              17904.80   +0.000%        0.000 km
```

**Agreement to 0.0001% on cost and about 2 metres on warehouse position.**

This turns what was six hours of duplicated work into evidence. "We rewrote the
maths in another language" is something a judge takes on trust. "Two independent
implementations agree, here is the script" is proof. **Please put this in the
mathematical write-up.**

---

## 5. Three things of yours we adopted — thank you

1. **CO₂ impact.** Now derived from fuel burn rather than invented: petrol
   2.31 kg CO₂/litre, diesel 2.68 kg/litre, and grid emissions for the EV.
   Reports 41.3 tonnes/year avoided alongside the rupee saving.
2. **±30% demand robustness.** Implemented as *regret*: what keeping the chosen
   warehouses costs versus re-optimising with perfect hindsight. Result 0.6%.
3. **Stable warehouse ids, W1 always the busiest.** Makes two runs comparable.
   Good call.

---

## 6. We duplicated a lot of work. Here is the split from here.

Both sides independently built the same three things:

| You | Us |
|---|---|
| `sweep_k` / `recommend_k` | `sweepK` / `optimalK` |
| `verifier.py` | `proveOptimality` |
| naive → k-means → ours comparison ladder | `naive_k_cost` / `placement_gain_pct` |

**Stop building user-facing features.** From here:

- **You own:** the reference implementation, and **the mathematical write-up**.
- **Sakshath owns:** the web app, deployment, demo video.

### The write-up is your highest-value remaining task

*"Mathematical Modelling & Problem Solving"* is an explicit judging criterion,
this is a mathematics society, and **nobody else in the field will submit one.**
It is the single biggest scoring opportunity we have left.

Please cover:
- Why k-medians and not k-means — cost is linear in distance, not squared
- Weiszfeld's algorithm and why the 1-median case is *provably* globally optimal
  (convex objective, descent method)
- Why K > 1 is NP-hard and what we therefore claim instead: exact discrete
  p-median as a lower-bounding benchmark, plus local-optimality certification
- The infrastructure-vs-delivery trade-off and why the total has an interior
  minimum
- The cross-validation result in §4

---

## 7. Open questions — please answer these

1. **Cost units.** Yours reports order-km; ours reports rupees/day from a fuller
   model (`trips = ceil(orders/vehicleCapacity)`, road detour factor 1.32, fuel,
   driver time, facility rent). Proposal: **rupees/day is the headline,
   order-km is the secondary figure.** Confirm or object.

   Note on your warning in `HANDOFF_SAKSHATH.md` about a model that *"treats
   every order as its own van trip"* and inflates to ₹110M/year — **ours does
   not do that.** It batches by vehicle capacity and lands at ~₹47 lakh/year of
   *savings* on the sample, which is defensible.

2. **Determinism.** Is `solve()` fully seeded? The harness sees identical output
   across runs, but please confirm there is no unseeded randomness anywhere.

3. **Is Rajath actually building anything?** `verifier.py` is in the repo with
   your fixes. Nobody has confirmed his status.

---

## 8. Housekeeping

- **`logs/tejas.md` is still the blank template.** You pushed 2,257 lines of
  code at ~00:15 and Sakshath's side did not notice for 45 minutes, because the
  protocol says to read the other person's *log*. Please append an entry and run
  `./sync.sh` when you finish a session.
- **`sync.sh` had a bug** — it ran `git pull --rebase` *before* `git add`, so it
  failed every time you had local changes. Fixed and pushed. `git pull` to get it.
- **`__pycache__/*.pyc` was committed** to this public repo. Already removed and
  gitignored.

---

## 9. What is actually left

| Task | Owner | Status |
|---|---|---|
| Web app | Sakshath | done, 70 tests + 15 cross-val passing |
| README with AI disclosure + library credits | Sakshath | done |
| Code repo | Sakshath | done |
| Cross-validation harness | Sakshath | done |
| Demo script | Sakshath | done — `shared/DEMO_SCRIPT.md` |
| **Vercel deploy** | Sakshath | **not started** |
| **Demo video** | Sakshath | **not started** |
| **Mathematical write-up** | **Tejas** | **not started** |

Deadline **18:00 IST today**, submission form opens 17:00. Target submitting by
**17:00**.
