# Sakshath - work log

Newest entries at the top.

---

## 2026-09-20 (01:00 IST)

**Did:**

1. **Redesigned the whole web UI.** It was dense and jarring - three columns of
   controls all shouting at once. Now: two steps visible (data, number of
   warehouses), everything advanced folded into four collapsible groups
   (fleet & costs, constraints, demand scenario, AI component) whose summary
   rows show their current value so nothing is hidden-and-forgotten. Every
   section carries one plain-English line explaining *why it exists*. Before the
   first run the results panel shows a four-step explainer of what Optimise is
   about to do, so a judge understands the model before seeing a number.
   **No features were removed** - all 8 bonus features are still there.
   Builds clean, verified by browser screenshot, 119 kB first load.

2. **Found Tejas's code.** It had been in the repo since ~00:15 under
   `gridpoint/` - `solver.py` (854 lines), `engine.py` (434), `verifier.py`
   (527), plus a handoff doc. My session-start check missed it because the
   protocol says to read the other person's log, and his log was still the
   blank template. Process fix noted in
   `decisions/2026-09-20-engine-reconciliation.md`: check `git ls-files` too.

**What I learned from his code:** the five frozen contract keys match exactly
between his Python and my TypeScript. Two people built to a written contract
without speaking and it lined up. Three additive keys are named differently
(`loads`/`load`, `unserved`/`out_of_radius`, `baseline`/`baseline_warehouse`) -
I will accept both, he changes nothing.

**Broken / known issues:**
- Still nothing deployed. No Vercel URL.
- Still no code repo. **This is the top blocker** - the submission requires a
  public source repo and it does not exist.
- The AI model has still never been executed end to end by me (my sandbox
  blocks huggingface.co). Sakshath confirmed the app runs locally; the model
  path specifically still needs a visual confirm of the "AI mapped" badge.
- `gridpoint/__pycache__/*.pyc` is committed to this PUBLIC repo. Should be
  removed with `git rm -r --cached`.
- Cost units unreconciled: his order-km vs my rupees/day. See the decision file.

**Need from Tejas:**
1. **The code repo URL.** Everything is blocked on this.
2. **Read `decisions/` before writing any more code** - specifically, there is
   no Streamlit app anymore. His handoff doc assumes `app.py` "is the thing that
   gets filmed". That is no longer true; the deliverable is a Next.js app on
   Vercel. If he keeps optimising for Streamlit he will waste the night.
3. **Write the mathematical write-up.** Highest-value thing only he can do.
4. Confirm rupees/day as the headline cost unit.
5. Put his canonical sample dataset in `shared/` so cross-validation has one
   agreed input - he has 13 Bangalore areas, I have 12.
6. Is the Python solver deterministic (seeded)? Cross-validation needs to know.

---

## 2026-09-20 (00:45 IST)

**Did:**

Built my entire half of GridPoint. Two tracks, both finished and tested.

*Track 1 - Python (done earlier, delivered as a zip):*
- `data.py` - CSV/manual parsing, validation, sample datasets. 38/38 tests pass.
  Tolerates messy headers, reports every bad row instead of dying on the first.
- `app.py` - a Streamlit + Folium version of the whole product. 31/31
  end-to-end tests pass via Streamlit's AppTest harness.

*Track 2 - the actual submission: a Next.js web app for Vercel.*
- `lib/geo.ts` - haversine, weighted centroid, Weiszfeld geometric median
- `lib/solver.ts` - weighted k-medians (Lloyd's + geometric median update,
  k-means++ seeding), **exact discrete p-median by full enumeration**, and a
  **local-optimality certificate**
- `lib/engine.ts` - the Rs/day cost model, the `run()` pipeline, K-sweep, and
  the proof report
- `lib/data.ts` - parsing/validation/samples, ported from `data.py`
- `lib/ai/columnMapper.ts` - the AI component
- `components/MapView.tsx`, `components/KSweepChart.tsx`, `app/page.tsx`
- **56/56 tests pass** (`npx tsx scripts/test_core.ts`)

**All 8 GridPoint bonus features are implemented:** multiple warehouses,
warehouse capacity, max service radius, vehicle types (5), fuel costs,
traffic-dependent delivery times, demand-change scenarios (5), and the
infrastructure-vs-delivery cost trade-off.

That last one is the headline. Because each warehouse adds a fixed facility
cost and removes delivery cost, total cost has a genuine interior minimum - so
the app answers **how many warehouses to build**, not just where. On the
Bengaluru 12-zone sample the optimum is **K=4 at Rs 19,690/day, 35.1% cheaper
than a single central depot (Rs 30,360/day)**.

**On the mathematics (this is our edge with a maths society judging):**
- We use **k-medians, not k-means**. Delivery cost is linear in distance, not
  squared. k-means lets one distant high-volume neighborhood drag a warehouse
  far harder than its real cost justifies. We compute both and show the gap:
  a k-means network costs 1.3-6.1% more at the same K.
- **K=1 is provably globally optimal** - the weighted 1-median objective is
  convex, Weiszfeld is a descent method on it, so its fixed point is the global
  minimum. That is a theorem, not a search.
- **K>1 is NP-hard**, so we do not claim global optimality. We prove two weaker
  but real things: (a) our continuous solution is never worse than the exactly
  solved discrete p-median optimum over all C(n,k) subsets of the demand points,
  and (b) it is a certified local optimum - no perturbation of any single
  warehouse within 2 km improves it.

**Five real bugs caught by actually running things** (all fixed):
1. CartoDB map tiles now require an API key - the maps would have rendered
   blank in the demo video.
2. The cost model was miscalibrated and reported **-104% "improvement"**.
   Recalibrated to two-wheeler + Rs 2,500/day dark store.
3. The solver was fractionally worse than the exact discrete optimum at K=2
   and K=4. Fixed by warm-starting Lloyd's from the discrete solution, which
   makes being worse than it mathematically impossible.
4. **maplibre-gl v6 has a web-worker regression under Next 15** - GeoJSON
   sources never parse and the map renders nothing at all. Pinned to 5.24.0.
5. A failing tile source freezes MapLibre in "style not loaded", where it
   paints *nothing* - data included. The map now boots on a blank style and
   only adds a basemap after probing that it responds, so the data layer
   renders even with zero network.

**Now working:** README (with the AI disclosure and library credits), the
Python<->TypeScript cross-validation harness, and the demo video script.

**Broken / known issues:**
- **Nothing is deployed yet.** No Vercel URL exists.
- **The AI component has never actually been executed.** The build sandbox
  blocks huggingface.co, so the model has never downloaded or run. It has a
  deterministic fallback and the UI states which path was used, but somebody
  has to open the app on a real machine and confirm it works.
- **Map basemap tiles are unverified** for the same reason. The data layer
  renders regardless - confirmed by screenshot with tiles fully blocked.
- The `python/` reference and the cross-validation harness do not exist yet.

**Need from Tejas:**
1. **The code repo URL.** This repo is context only and the code has nowhere
   to live. This is the single biggest blocker.
2. **`solver.py` and `engine.py`**, matching the frozen `RESULT` contract in
   `CONTEXT.md`. I have not seen a single line of your code yet - I have been
   designing against the contract alone.
3. **The mathematical write-up.** You are the author of record on the model and
   "Mathematical Modelling & Problem Solving" is an explicit judging criterion.
   Please read the model section of `CONTEXT.md` first - if your maths differs
   from what I have implemented, say so now, because that is the contract.
4. **Confirm whether Rajath is actually building `verifier.py`.** Nobody has
   checked and it is on the plan.

---

## 2026-09-20

**Did:** Created the shared context repo, set up structure and protocol.

**Now working:** Repo is live and cloned locally.

**Broken / known issues:** none

**Need from Tejas:** Clone the repo and confirm you can push to it.
