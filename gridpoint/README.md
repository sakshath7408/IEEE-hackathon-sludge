# GridPoint — Where Should the Warehouse Go?

**Hack-a-Matics 2026** · Theme: VECTOR · Problem statement: **GRIDPOINT**
Pentagram (The Mathematical Society of BMSCE) × BMSCE IEEE Computer Society

A warehouse location optimization platform. Given a set of neighborhoods with
geographic coordinates and daily order volumes, GridPoint decides **where to
build K warehouses** and **which neighborhood each one serves**, so that total
weighted delivery cost is as low as possible.

---

## The problem

An e-commerce company delivers to many neighborhoods. Each has a different
location and a different number of daily orders. Put the warehouses in the wrong
places and every delivery van drives further than it needs to, every day,
forever.

The catch: a neighborhood with 900 orders/day matters far more than one with 40.
Minimizing plain average distance gets the wrong answer. GridPoint minimizes
**order-weighted** distance:

```
total cost  =  Σ  orders_i × distance( neighborhood_i , its warehouse )
```

---

## The AI / machine learning component

**GridPoint uses unsupervised machine learning: weighted k-median clustering
with k-means++ seeding and Weiszfeld geometric-median updates.**

This is learning, not lookup. The system is never told where the demand centres
are, how many neighborhoods belong to each region, or which neighborhood pairs
belong together. There are no labels and no training set. It discovers the
structure directly from the order data:

1. **Seeding (k-means++)** — initial warehouse candidates are drawn with
   probability proportional to their squared distance from existing centres,
   spreading the starting guesses instead of clumping them.
2. **Expectation step** — every neighborhood is assigned to whichever warehouse
   currently serves it most cheaply.
3. **Maximization step** — each warehouse relocates to the *weighted geometric
   median* of the neighborhoods that chose it, computed iteratively via
   **Weiszfeld's algorithm**, with daily order counts as the weights.
4. Steps 2–3 repeat until assignments stop changing. Multiple randomized
   restarts are run and the lowest-cost configuration is kept, guarding against
   local optima.

This is the same expectation–maximization family as k-means, deliberately
adapted: **k-means minimizes squared distance, which is the wrong objective
here.** Squared error is dominated by outliers and corresponds to minimizing
variance, not travel. Delivery cost is linear in distance, so the correct
estimator is the geometric median (L1), not the centroid (L2). Weiszfeld's
algorithm is what makes that tractable.

Nothing about the clustering is hardcoded. Change the order volumes and the
warehouses move.

---

## Mathematical modelling

**Distance.** Great-circle distance via the **haversine formula** on a spherical
Earth (R = 6371 km), rather than straight-line Euclidean distance on raw
latitude/longitude — which would be wrong, because a degree of longitude is
shorter than a degree of latitude everywhere except the equator.

**Projection.** Weiszfeld iterations are performed in a local equirectangular
projection (kilometres), anchored at the cluster's mean latitude, then converted
back to lat/lon. Running the update directly on degrees would treat the
horizontal and vertical axes as equally scaled and drag the solution
east–west. Distances are always reported with haversine on true coordinates.

**Degeneracy handling.** Weiszfeld's update is undefined when the estimate
lands exactly on a data point (division by zero). Naive implementations stop
there and return that point — but a data point is the true minimum only if its
own weight exceeds the combined pull of all other points, |Σ wᵢ(xᵢ−y)/dᵢ| ≤ wⱼ.
When that test fails, the solver applies the **Vardi–Zhang (2000) modified
Weiszfeld step** to move off the point and continue converging. On a crafted
test instance the naive stop returns a point 20% more expensive than the
optimum; the corrected iteration reaches the optimum.

**Input validation.** Uploaded CSVs arrive with strings, blanks, negatives and
swapped columns. Every field is checked (finite numbers, lat ∈ [−90, 90],
lon ∈ [−180, 180], orders ≥ 0, unique ids, positive capacity) and rejected with
a message that names the offending row, instead of a stack trace.

**Verification.** An independent brute-force checker (`verifier.py`, standard
library only, shares no code with the solver) computes the exact optimum two
ways: the **discrete** optimum (warehouses restricted to neighborhood sites,
every C(N,K) combination tried) and the **continuous** optimum (every partition
of the neighborhoods into K groups, each group's warehouse at its exact weighted
geometric median found by golden-section search — a different algorithm from
the solver's Weiszfeld iteration, on purpose). On every small instance tested
the heuristic matches the exact continuous optimum to within search tolerance,
and the interface can show that verdict as a "verified optimal" badge; for
larger uploads, `spot_check` verifies random sub-instances.

---

## Core requirements — coverage

| Requirement | Status |
|---|---|
| Upload / enter neighborhood data (location + daily orders) | TODO |
| Visualize all neighborhood locations on a map | TODO |
| User selects the number of warehouses (K) | TODO |
| Optimization algorithm determines warehouse locations | `solver.solve` |
| Assign each neighborhood to its optimal warehouse | `solver.solve` |
| Calculate total delivery distance and cost | `solver.weighted_cost` (one shared function); reported by `engine.run()` as `total_cost` |
| Display optimized locations and assignments | TODO |
| Compare original vs optimized arrangement | `engine.comparison_ladder` — naive (one warehouse at the map centre) → textbook k-means → GridPoint; `baseline_cost` / `improvement_pct` in `run()`. UI TODO |
| Warehouse capacity and maximum service radius | TODO |

## Bonus features

| Bonus | Status |
|---|---|
| Multiple warehouses | `solver.solve`, any K |
| Limited warehouse capacity | `solver` — capacity constraint |
| Maximum delivery radius | `solver` — `unserved` list |
| Fuel / delivery cost | `engine.impact` — km, ₹ and CO₂ per day/year from user-set rates. UI TODO |
| Model changes in customer demand | `engine.robustness` — ±30% demand stress test, fixed plan vs re-optimized. UI TODO |
| Infrastructure cost vs delivery cost trade-off | `sweep_k` + `recommend_k` (solver) — UI TODO |

> **Service radius.** Neighborhoods beyond `max_radius_km` from their assigned
> warehouse are still assigned — no neighborhood is ever silently dropped from
> the cost calculation — and are additionally returned in `unserved` so the
> interface can flag them as out of range.
>
> **Capacity.** Nearest-warehouse assignment ignores load, so the solver repairs
> the unconstrained optimum rather than rebuilding it: neighborhoods are moved
> off overloaded warehouses by cheapest-cost-increase, several greedy variants
> are swept across a ladder of capacity targets, each candidate is polished with
> relocate/swap local search and recentred (a short capacitated Lloyd loop), and
> the cheapest legal plan is kept. If total demand exceeds K × capacity the
> instance is infeasible; the least-overloaded plan is returned with the
> offending warehouses listed in `over_capacity`.

**Sample data.** The built-in demo dataset is 13 real Bangalore neighborhoods
(coordinates from Wikipedia / latlong.net) with **synthetic** daily order
volumes — no public per-neighborhood e-commerce dataset exists, so volumes are
illustrative, scaled to relative residential and commercial density.

---

## Architecture

```
data.py  →  solver.py  →  engine.py  →  app.py
                              ↑
                         verifier.py  (independent check)
```

| File | Responsibility |
|---|---|
| `data.py` | Input parsing, validation, sample datasets |
| `solver.py` | Haversine geometry, k-means++ seeding, Weiszfeld updates, k-median optimization, assignment |
| `engine.py` | `run()` pipeline for the UI: cost, naive baseline, three-rung comparison ladder (naive → k-means → GridPoint), real-unit impact, demand-shift robustness, verifier cross-check |
| `app.py` | Streamlit interface, Folium map rendering, integration |
| `verifier.py` | Standalone exact brute-force checker: discrete and continuous optima, `verify()` verdicts for the UI badge, `spot_check()` for large inputs; `engine.cross_check` uses it |

The dependency chain is strictly one-directional — no circular imports.

### Data contracts

Neighborhood:
```python
{"id": str, "lat": float, "lon": float, "orders": int}
```

Solver output:
```python
{
  "warehouses":    [{"id": str, "lat": float, "lon": float}],
  "assignments":   {neighborhood_id: warehouse_id},      # frozen contract
  "loads":         {warehouse_id: daily orders served},
  "distances_km":  {neighborhood_id: km to its warehouse},
  "unserved":      [neighborhood_id],   # only when max_radius_km is set
  "over_capacity": [warehouse_id]       # only when capacity is set AND infeasible
}
```

Also exported by `solver.py`:

| Function | Purpose |
|---|---|
| `weighted_cost(neighborhoods, result)` | The objective. One implementation shared by engine, verifier and UI so every number on screen agrees. |
| `sweep_k(neighborhoods, k_max, constraints)` | Solves K = 1…k_max; returns cost, km/order and % saving per step — the infrastructure-vs-delivery trade-off curve. |
| `recommend_k(rows)` | Elbow of that curve: the K after which another warehouse stops paying for itself. |

Output is deterministic and independent of input row order; warehouse ids
are assigned by descending load (`W1` is the busiest), so labels never jump
between runs.

---

## Running it

```bash
pip install -r requirements.txt
streamlit run app.py
```

Each compute module runs standalone against the built-in sample dataset:

```bash
python solver.py     # placement + assignment
python engine.py     # contract checks, comparison ladder, impact, robustness, verifier PASS/FAIL
```

**Cost model.** The optimizer minimises order-kilometres (orders × km), which
needs no assumptions. Rupee figures multiply that by a user-set rate per
order-kilometre (default ₹12, illustrative — real last-mile costs depend on
batching and vehicle type). The rate changes the labels, never the ranking.

---

## Tech stack

Python · Streamlit (interface) · Folium / Leaflet (mapping)
Core optimization is written from scratch in pure Python — no clustering library
is used for the placement algorithm itself.

---

## Team

| Member | Modules |
|---|---|
| Tejas Nayak | `solver.py`, `engine.py` |
| Sakshath | `data.py`, `app.py` |
| Rajath | `verifier.py` |

---

## Disclosures

**AI coding assistants.** Claude (Anthropic) was used as a coding assistant
while writing this project. The problem decomposition, module architecture,
choice of algorithm, data contracts between modules, and integration were
designed and directed by the team.

**Open-source libraries.** Streamlit (interface), Folium (mapping). No
pre-built project, template, or prior personal work was reused. All code in
this repository was written during the official 24-hour hacking window.

---

## Links

- **Repository:** <TODO: public GitHub URL>
- **Demo video (2–3 min):** <TODO: video link>
