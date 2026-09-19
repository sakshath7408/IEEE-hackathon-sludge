# Reconciling Tejas's engine with the web app

**Date:** 2026-09-20 01:00 IST · **By:** Sakshath · **Affects:** Tejas

## What happened

Tejas pushed `gridpoint/solver.py`, `engine.py`, `verifier.py` and
`HANDOFF_SAKSHATH.md` at ~00:15. Sakshath's session did not see it until 01:00,
because the session-start protocol says to read `logs/<other>.md` and Tejas's
log was still the blank template. **The code was pushed; the log was not.**

Process fix: read `git ls-files` and `git log` at session start, not just the
log file.

## The good news

The five frozen keys match **exactly** across both implementations:
`warehouses`, `assignments`, `total_cost`, `baseline_cost`, `improvement_pct`.
Two people built to the contract without talking and it lined up. Keep it frozen.

## Differences, and how they are resolved

| Thing | Tejas (Python) | Sakshath (TypeScript) | Resolution |
|---|---|---|---|
| Warehouse loads | `loads` | `load` | App accepts **both** |
| Radius violations | `unserved` | `out_of_radius` | App accepts **both** |
| Baseline | `baseline` (dict) | `baseline_warehouse` | App accepts **both** |
| Cost unit | order-km | **rupees/day** | See below - needs Tejas to confirm |

Tejas does **not** need to change anything. The app normalises.

## Cost units - OPEN, needs Tejas

Python reports order-km. TypeScript reports Rs/day from a fuller model:
`trips = ceil(orders/vehicleCapacity)`, `roadKm = haversine x 1.32`,
`vehicleKm = 2 x roadKm x trips`, plus fuel, driver time and facility rent.

`HANDOFF_SAKSHATH.md` warns against a model that "treats every order as its own
van trip" and inflates to Rs 110M/year. **The TypeScript model does not do that**
- it batches by vehicle capacity, and lands at ~Rs 8M/year on the sample, which
is defensible.

Proposal: **rupees/day is the headline, order-km is the secondary figure.**
Tejas to confirm or object.

## Duplicated work - stop now

Both sides independently built the same three things:
`sweep_k`/`recommend_k` vs `sweepK`/`optimalK`; `verifier.py` vs
`proveOptimality`; a naive-vs-kmeans-vs-ours comparison on both sides.

Roughly six hours of duplicated effort. From here:
- **Tejas owns:** the reference implementation and **the mathematical write-up**.
  The write-up is the highest-value remaining task and nobody else is doing it.
- **Sakshath owns:** everything user-facing, deploy, demo video.

## Adopted from Tejas

Three good ideas being ported into the web app:
1. **CO2 impact** per day/year - strong for the Real-World Impact criterion.
2. **+/-30% demand robustness** stress test.
3. **Stable warehouse ids, W1 always the busiest** - makes runs comparable.

## Still blocking

**The code repo URL.** This repo is context only. The submission requires a
public repo containing the actual source, and it does not exist yet.
