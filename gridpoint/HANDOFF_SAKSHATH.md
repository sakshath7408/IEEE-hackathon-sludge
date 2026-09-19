# GridPoint — handoff to Sakshath (`data.py` + `app.py`)

Written 20 Sep, ~00:15. Hard deadline **6:00 PM today**. Submission form opens 5:00 PM.

## Where things stand

| File | Owner | Status |
|---|---|---|
| `solver.py` | Tejas | done, audited twice, exact-optimum verified |
| `engine.py` | Tejas | done — the one function `app.py` calls |
| `verifier.py` | Rajath (+ fixes) | done — gives you a "Verified optimal" badge |
| `README.md` | shared | done except the rows marked **UI TODO** — those are yours |
| `data.py` | **you** | input + validation + sample data |
| `app.py` | **you** | Streamlit + Folium, the thing that gets filmed |

Everything below is copy-paste ready. The compute side is finished; you should not need to touch any of the three compute files.

## Run it

```bash
pip install -r requirements.txt
streamlit run app.py
```

Each compute file also runs on its own and prints its checks: `python solver.py`, `python engine.py`, `python verifier.py`.

## 1. The input contract (`data.py` produces this)

A plain list of dicts:

```python
[{"id": "Koramangala", "lat": 12.9259, "lon": 77.6229, "orders": 950}, ...]
```

- `id` — string, must be unique
- `lat`, `lon` — numbers (not strings!), lat in −90…90, lon in −180…180
- `orders` — number ≥ 0

**You don't need to write validation.** `solver.solve()` checks every field and raises `ValueError` with a message that names the offending row, e.g. `solve: 'Whitefield' has invalid latitude 'abc' (need a number in -90..90)`. Just wrap the call:

```python
try:
    result = engine.run(neighborhoods, K, constraints)
except ValueError as e:
    st.error(str(e)); st.stop()
```

For CSV upload: columns `id, lat, lon, orders`. Cast `lat/lon` to `float` and `orders` to `int` before building the list — pandas may leave them as strings or numpy types.

**Sample data for the default view:** `from solver import SAMPLE_NEIGHBORHOODS` — 13 real Bangalore neighborhoods (Wikipedia coordinates, illustrative order counts).

## 2. The one call: `engine.run()`

```python
from engine import run

r = run(neighborhoods, K,
        constraints={"capacity": 3000, "max_radius_km": 10.0},   # or None
        cost_per_km=12.0,        # user slider; None = no rupee figures
        co2_g_per_km=150.0,      # user slider; None = no CO2 figures
        robustness_trials=50)    # 0 = skip (fast); 50 = ~4 s
```

Returns one dict. **Frozen keys** (always present):

| Key | What |
|---|---|
| `warehouses` | `[{"id": "W1", "lat", "lon"}, ...]` — **W1 is always the busiest** |
| `assignments` | `{neighborhood_id: warehouse_id}` — every neighborhood, always |
| `total_cost` | optimized weighted cost, order-km |
| `baseline_cost` | naive: one warehouse at the plain map centroid |
| `improvement_pct` | `100 × (baseline − total) / baseline` |

**Additive keys** (use what you like):

| Key | What | Use it for |
|---|---|---|
| `loads` | `{warehouse_id: orders/day}` | pin tooltip, capacity bar |
| `distances_km` | `{neighborhood_id: km to its warehouse}` | marker tooltip |
| `unserved` | list of neighborhood ids beyond `max_radius_km` — **only when radius is set** | red markers + banner "N neighborhoods outside service range" |
| `over_capacity` | list of warehouse ids still overloaded — **only when demand > K × capacity** | warning: "Not enough capacity: increase K or capacity" |
| `baseline` | `{"definition", "warehouses", "assignments"}` | draw the naive pin greyed out for before/after |
| `comparison` | 3 rungs: naive → k-means → GridPoint | the comparison table (see §4) |
| `impact` | km / ₹ / CO₂ per day and year | the savings cards |
| `robustness` | ±30% demand stress test | one line: "plan stays within X% of re-optimizing" |

Timing on the 13-point sample: `run()` ≈ 0.1 s without robustness, ≈ 4 s with 50 trials. On 100 neighborhoods ≈ 1.5 s. Constrained adds ~1 s. Fine for a button; **run on click, not on every slider move.**

## 3. Map (Folium)

- Neighborhood markers: colour by `assignments[id]` (one colour per warehouse id). Radius ∝ `orders`. Tooltip: `id`, `orders`, `distances_km[id]`.
- Warehouse pins: `warehouses[i]["lat"/"lon"]`, label `W1 · 2990 orders/day` from `loads`.
- Lines from each neighborhood to its warehouse — cheap and makes the assignment obvious on camera.
- If `unserved` is non-empty: those markers red, plus a banner. This is the "max service radius" requirement made visible.
- Before/after toggle: `baseline["warehouses"]` (one grey pin) vs `warehouses`.

## 4. Comparison table

`r["comparison"]` is a list of three rungs, each with `label`, `cost`, `improvement_pct` (vs naive), `saving_vs_prev_pct`. On the sample, K=3:

| Rung | order-km | vs naive |
|---|---|---|
| Naive: one warehouse at the map centre | 55,673 | — |
| Textbook k-means, K=3 | 33,997 | 38.9% |
| GridPoint weighted k-median, K=3 | 30,378 | 45.4% |

**The sentence for the video:** *"38.9% better than eyeballing the middle, and 10.6% better than the k-means everyone else will ship — because we minimise distance, not distance squared."*

## 5. Savings cards — `r["impact"]`

Keys: `km_per_day`, `km_per_year`, `cost_per_day`, `cost_per_year`, `co2_kg_per_day`, `co2_tonnes_per_year`, `assumption`.

**Set the ₹/km slider default LOW (₹0.5–1), not 12.** At ₹12 the sample shows ₹110 million/year, which reads as inflated because it treats every order as its own van trip. Lead with km and CO₂; show ₹ as "at your rate".

## 6. "Verified optimal" badge — this is a differentiator

Nobody else will have this. `verifier.py` brute-forces the exact optimum and confirms the solver hit it.

```python
from verifier import verify, spot_check
from solver import solve

if constraints is None or all(v is None for v in constraints.values()):
    if len(neighborhoods) <= 10:
        v = verify(neighborhoods, K, r)          # ~2–4 s
        # v["verdict"] is "PASS" / "FAIL" / "SKIP"; v["note"] is one sentence
        st.success(f"✓ Verified against exact brute force: {v['note']}")
    else:
        sc = spot_check(neighborhoods, K, solve, samples=5, size=8)   # ~4 s
        st.success(f"✓ Optimal on {sc['passed']}/{sc['samples']} random 8-neighborhood sub-instances (exact brute force)")
```

Only show it for **unconstrained** runs (capacity/radius legitimately push cost above the unconstrained optimum). Put it behind a "Verify" button or a spinner — it's a few seconds.

## 7. "How many warehouses?" chart — bonus points

```python
from solver import sweep_k, recommend_k
rows = sweep_k(neighborhoods, 6, constraints)     # ~1 s on the sample
best_k = recommend_k(rows)
# rows[i] has "k", "cost", "km_per_order", "saving_vs_prev_pct"
```

Plot `k` vs `cost` as a line, mark `best_k`. Caption: *"each extra warehouse costs money to build; this is how much delivery cost it buys back."* Covers the brochure's "infrastructure vs delivery cost trade-off" bullet. On the 13-point sample the curve is nearly straight so the elbow is weak — **show the curve, don't oversell the number.**

## 8. Requirement checklist (brochure → your UI)

| Brochure requirement | Where it comes from | UI |
|---|---|---|
| Upload / enter neighborhood data | `data.py` | file uploader + editable table |
| Visualize on map | `app.py` | Folium |
| Choose number of warehouses | slider → `K` | |
| Run optimization | `engine.run` | button |
| Assign each neighborhood | `assignments` | colours + lines |
| Total delivery distance and cost | `total_cost`, `impact` | cards |
| Display optimized locations | `warehouses` | pins |
| Compare original vs optimized | `baseline`, `comparison` | toggle + table |
| Capacity / max radius | constraints inputs → `over_capacity`, `unserved` | banner |
| *Bonus:* fuel cost | `impact.cost_per_*` | slider |
| *Bonus:* demand changes | `robustness` | one line |
| *Bonus:* infra vs delivery trade-off | `sweep_k` | chart |

## 9. Demo video (2–3 min) — must follow this exact order

Brochure: *Neighborhood data → Location visualization → Warehouse optimization → Neighborhood assignment → Delivery cost comparison.*

1. Load sample → map with 13 dots (10 s)
2. Set K=3 → Optimize → pins appear, dots recolour, lines draw (20 s)
3. Comparison table → say the sentence from §4 (20 s)
4. Toggle capacity 3000 + radius 10 km → 3 red markers + banner (15 s)
5. Verified badge (10 s)
6. Sweep chart (15 s)
7. Upload a custom CSV, re-run, show it just works (20 s)

## Don'ts

- **Don't recompute cost in `app.py`.** Use `total_cost` / `impact`. Three different cost loops on screen that disagree is how demos die.
- **Don't rename warehouse ids** — `W1` = busiest is deliberate and stable across runs.
- **Don't call `solve()` on every widget change.** Button-triggered only.
- **Don't fetch anything from the internet at runtime** (map tiles excepted). No API keys, nothing to fail at 5:50 PM.
- README: fill your rows (`data.py`, `app.py`, the **UI TODO** marks), team surnames, repo URL, video link. The AI-component and disclosure sections are done — don't remove them.
