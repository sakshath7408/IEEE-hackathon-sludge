# Running the GridPoint web app on your machine — Tejas

Five minutes, no account, no deploy. You get the real thing running at
`localhost:3000`.

---

## What you need

- **Node 20 or newer.** Check with `node -v`.
  If it's missing or older: `brew install node` (Mac) or grab it from nodejs.org.
- **Python 3** — you already have it. Only needed for the cross-validation
  script, not to run the app.
- That's everything. **No API keys, no `.env` file, no database.** The app is
  entirely client-side by design.

---

## Run it

```bash
git clone https://github.com/sakshath7408/gridpoint.git
cd gridpoint
npm install
npm run dev
```

Then open **http://localhost:3000**.

`npm install` takes a minute or two the first time. After that `npm run dev`
starts in about a second.

---

## What you should see

A dark full-screen map of Bengaluru with twelve circles, sized by daily order
volume. Controls float on the left, results on the right.

**Press `Optimise`.** Warehouses appear, every neighborhood gets assigned to one,
and the right panel fills in. On the default sample you should get **28.2%**
cheaper than a single central depot at K=3, and the app will tell you the real
optimum is **K=4** at **35.1%**.

Worth clicking through:

- **Left panel → "Fleet & costs"** — vehicle, traffic, fuel, wages, rent. These
  feed the ₹/km the optimiser is actually minimising.
- **Left panel → "Constraints"** — capacity and max service radius. Violations
  are flagged on the map, not hidden.
- **Right panel → "The trade-off"** — the K-sweep. This is your `sweep_k` idea,
  rendered.
- **Right panel → "Proof" tab** — which claim applies at the current K, and the
  numbers behind it.
- **Left panel → Upload → "Try one with unfamiliar headers"** — this is the AI
  component. Watch the badge turn purple and read **AI mapped**.

---

## Run the maths checks

From the same folder:

```bash
npx tsx scripts/test_core.ts   # 70 tests — geometry, cost model, all 8 bonus features
npm run crossval               # YOUR solver.py vs the TypeScript port
```

`npm run crossval` is the one you'll care about. It runs **your `python/solver.py`**
and the TypeScript `lib/solver.ts` on the same 13-neighborhood dataset (your
`SAMPLE_NEIGHBORHOODS`) and compares them:

```
   K  |  python (order-km)  typescript (order-km)   gap    worst site gap
   1  |          55490.66              55490.74   +0.000%        0.000 km
   3  |          30378.14              30378.17   +0.000%        0.002 km
   5  |          17904.77              17904.80   +0.000%        0.000 km
```

They're not identical by construction — your Weiszfeld runs on a local
tangent-plane projection, the TypeScript runs on the sphere with haversine, and
the seeds differ. **They agree to 0.0001% on cost and about 2 metres on
position.** Please use this in the mathematical write-up; it is the strongest
evidence we have.

---

## If something breaks

**`npm install` fails** — check `node -v` is 20+. That's almost always it.

**Port 3000 is taken** — `npm run dev -- -p 3001`.

**Map is plain dark with no streets** — the tile server is unreachable from your
network. This is deliberate: the map boots on a blank style and only adds a
basemap after probing that it responds, so the circles, lines and warehouses all
still render. The app is fine; you just don't get the pretty backdrop.

**The AI badge says "alias table" instead of "AI mapped"** — the model (~23 MB,
from the Hugging Face CDN) didn't load. It falls back to a deterministic alias
table and says so rather than pretending. If you see this, **tell Sakshath** —
the AI component is a mandatory submission requirement.

**`npm run crossval` can't find python3** — it shells out to `python3`. Use
`python3 python/dump_reference.py` directly to check it works standalone.

---

## What you're looking for

You wrote the mathematics. The point of running this is to check the app hasn't
misrepresented it — that the numbers on screen match what your solver would say,
and that nothing in the UI overclaims. If anything looks wrong, say so; the
contract is frozen but the presentation is not.
