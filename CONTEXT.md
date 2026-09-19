# GRIDPOINT SLUDGE - Current State

_Last updated: 2026-09-20 02:00 IST by Sakshath_

## What we're building

**GridPoint** - a warehouse location optimisation platform. An e-commerce company
serves N neighborhoods, each with a daily order count and a lat/lon. The system
decides **where** warehouses should go, **how many** there should be, and **which
neighborhood each one serves**, minimising order-weighted delivery cost. Framed
around Indian quick-commerce / dark-store economics, so the output is in rupees
per day rather than abstract units.

Problem statement 1 of 3 (GRIDPOINT). Theme: VECTOR.
Judged by Pentagram (BMSCE Mathematical Society) + BMSCE IEEE Computer Society.

## Hackathon constraints

- **Deadline:** 2026-09-20 **18:00 IST hard**. Submission form opens 17:00.
  Team target: submit by **17:00** to keep an hour of buffer.
- **Demo format:** public GitHub repo + README + working prototype + **2-3 min
  demo video**. All four are required.
- **Judging criteria:** Real-World Impact · Technical Execution ·
  **Mathematical Modelling & Problem Solving** · Innovation & Creativity ·
  Project Demonstration.
  This is a *mathematics* society - modelling rigour is where we win or lose.
- **MANDATORY AI COMPONENT.** The brochure requires the README to name the AI
  component used, and lists "faking or hardcoding the AI component" as a
  disqualification reason. Confirmed with organisers. See
  `decisions/2026-09-20-mandatory-ai-component.md`.
- **All code must be written inside the hacking window.** No pre-built projects.
- **Every open-source library must be credited in the README.** Explicit rule.

## Status

- **Working:**
  - Math engine complete and tested - **56/56 tests passing**
    (`scripts/test_core.ts` in the code repo) - now 70/70
  - Next.js web app builds clean and renders correctly, verified in a real
    browser via Playwright screenshot
  - All 8 GridPoint bonus features implemented
  - CO2 impact, +/-30% demand robustness and stable warehouse ids adopted from
    Tejas's engine; the web engine now also emits his key names (`loads`,
    `unserved`, `baseline`) so either implementation drops in unchanged
  - README written, with the AI component named and every library credited
  - **70/70 tests passing**
  - Python track also done earlier: `data.py` (38/38 tests) and a Streamlit
    `app.py` (31/31 end-to-end tests)
  - Tejas's `solver.py`, `engine.py` and `verifier.py` received and moved into
    the code repo under `python/`. One repo now holds both halves.
  - Python<->TypeScript cross-validation harness done and passing (15/15)
  - **Deployed and live: https://gridpointsludge.vercel.app**
- **VERIFIED ON A REAL MACHINE (2026-09-20 ~01:50 IST, live production URL):**
  Both items that were unverifiable from the build sandbox have now been
  checked in a real browser against the deployed site.
  - **AI component runs.** Loading `unfamiliar_headers.csv` turns the badge
    purple and reads **"AI mapped"**. The MiniLM embedding model downloads from
    the Hugging Face CDN and runs in-browser on WebAssembly. Mapped
    `Parcels Per Day -> orders` (79%), `Locality Name -> id` (72%),
    `Y Coordinate -> lat` (50%), `X Coordinate -> lon` (39%). The percentages
    are raw cosine similarity, displayed honestly rather than laundered.
    **The mandatory AI component is no longer a risk.**
  - **Basemap tiles render.** OpenFreeMap vector tiles graft successfully;
    attribution shows on the live site. Real streets, not the blank fallback.
  - Optimise returns **28.2%** at K=3, identifies **K=4** as the true optimum,
    beats k-means by **2.9%** at equal K. Zero console errors.
- **Not started:** demo video recording; Tejas's mathematical write-up

### Deployment note - IMPORTANT

Vercel could **not** link the GitHub repo (`Failed to connect
sakshath7408/gridpoint to project`). **A `git push` does NOT update the live
site.** To redeploy, from the code repo checkout:

```
vercel --prod
```

## Split of work

- **Sakshath:** the product - data ingestion + validation, the web app, map,
  charts, cost model wiring, the AI component, deploy, demo video.
- **Tejas:** the mathematics - `solver.py` and `engine.py` as the reference
  implementation, plus the mathematical write-up for the judges. He is the
  author of record on the model. See
  `decisions/2026-09-20-typescript-port-and-cross-validation.md`.
- **Rajath:** `verifier.py`, independent brute-force checker. **Unconfirmed -
  needs chasing.**

## Stack and key choices

- **Next.js 15.5.25** + React 19 + TypeScript, deployed to **Vercel**.
- **All optimisation runs client-side in TypeScript.** No backend at all.
  Chosen so there is no cold-start server to die live in front of judges.
- **maplibre-gl PINNED TO 5.24.0.** v6 has a web-worker regression under
  Next 15's bundler: GeoJSON sources never parse and the map silently renders
  nothing. Do not bump this without re-testing the map.
- **@huggingface/transformers 3.7.6** (Transformers.js) running
  `Xenova/all-MiniLM-L6-v2` in the browser on WebAssembly.
- **NO API KEYS ANYWHERE.** Keyless map tiles, in-browser AI. Nothing to leak,
  no quota to run out mid-demo.
- Python remains the reference implementation and lives in the repo as the
  mathematical source of truth.

## Interface between our two halves

**FROZEN. Do not change either shape without writing a decision file first.**

A `neighborhood`:
```python
{"id": str, "lat": float, "lon": float, "orders": int}
```
- `id` unique, non-empty · `lat` in [-90, 90] · `lon` in [-180, 180]
- `orders` a non-negative integer

The `RESULT` returned by `engine.run(neighborhoods, k, constraints)`:
```python
{
  "warehouses":      [{"id": str, "lat": float, "lon": float}],
  "assignments":     {neighborhood_id: warehouse_id},
  "total_cost":      float,
  "baseline_cost":   float,
  "improvement_pct": float,
}
```

The web app also *displays* these optional extras when an engine provides them,
and degrades silently when it does not - so a leaner engine still works:
`baseline_warehouse`, `distances_km`, `load`, `cost_units`, `breakdown`,
`out_of_radius`, `over_capacity`.

Full detail: `decisions/2026-09-20-frozen-data-contracts.md`.

## The model (so Tejas's Claude can match it exactly)

Objective: minimise order-weighted delivery distance, solved as **weighted
k-medians** - Lloyd's alternating minimisation with a **geometric median
(Weiszfeld)** update, k-means++ seeding, and a warm start from the exactly
solved discrete p-median.

The key insight: cost per neighborhood works out to
`straightKm x [2 x trips x roadFactor x ratePerKm]`, where the bracket is a
constant. So the whole vehicle/fuel/traffic model is **free** in the optimiser -
it only changes the weights, and the problem stays weighted k-medians.

Cost model (Rs/day), trunk leg + facilities:
```
roadKm    = haversineKm x 1.32
trips     = ceil(orders / vehicleCapacity)
vehicleKm = 2 x roadKm x trips
ratePerKm = fuelPerKm x fuelPrice + upkeepPerKm + driverWage / (speed/congestion)
total     = sum(vehicleKm x ratePerKm) + K x facilityCostPerDay
```

Defaults: two-wheeler (25/trip), light traffic, Rs 102/L fuel, Rs 145/hr driver,
Rs 2,500/day facility, road factor 1.32.

Reference numbers on the Bengaluru 12-zone sample (useful as a cross-check):
- K=1 -> Rs 30,360/day · K=2 -> Rs 25,258 · K=3 -> Rs 21,799
- **K=4 -> Rs 19,690/day, the cost optimum, 35.1% below a single depot**
- K=5 -> Rs 19,775 · K=6 -> Rs 20,682
- Our k-medians beats a k-means network at the same K by 1.3-6.1%.

## Code repo

**https://github.com/sakshath7408/gridpoint** (public)

The Next.js web app - this is what gets submitted. Contains the TypeScript
solver/engine, the AI component, the map, and the README with the AI disclosure
and open-source credits.

**Live site: https://gridpointsludge.vercel.app**

Tejas's Python reference implementation has been moved into the code repo under
`python/` (`solver.py`, `engine.py`, `verifier.py`, `dump_reference.py`), so the
judges see one repo with both halves. The copy in `gridpoint/` in THIS repo is
now historical - the code repo is authoritative.

## Open questions

- ~~Code repo URL?~~ **Answered:** https://github.com/sakshath7408/gridpoint
- ~~Does the AI model load and run on a real machine?~~ **Answered: yes**,
  verified on the live deployment. See Status above.
- Is Rajath actually building `verifier.py`? A `verifier.py` arrived with
  Tejas's code and is in `python/`. Still unconfirmed whether Rajath wrote it
  or Tejas did.
- **The mathematical write-up has not been started.** This is the single
  biggest remaining risk. "Mathematical Modelling & Problem Solving" is an
  explicit judging criterion at a mathematics society's hackathon, and most of
  100+ teams will submit code with no mathematics behind it. Tejas owns this.
- The demo video has not been recorded. Script is in `shared/DEMO_SCRIPT.md`.
