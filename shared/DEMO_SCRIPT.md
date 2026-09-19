# GridPoint — demo video script

**Target: 2 min 40 s.** Brochure requires 2–3 minutes.
Tool: Screen Studio. Record in one pass, edit after.

Every number below was pulled from the actual app — none are invented. If a
number on screen differs from this script, trust the screen and say that one.

---

## Before you hit record

1. **Deploy to Vercel first** and record the *live URL*, not localhost. Judges
   see the URL bar. It is free credibility.
2. **Warm the caches.** Load the page, click Optimise, click Upload → "Try one
   with unfamiliar headers", wait for the AI model to finish downloading (the
   badge must read **AI mapped**), then hard-refresh. The 23 MB model is now
   cached and will not stall on camera.
3. **Window 1600×950 or larger.** The layout is three columns; narrower and it
   stacks.
4. **Close every other tab.** Notification banners kill demo videos.
5. Set sample to **Bengaluru — 12 zones**, K to **3**, everything else default.
6. Turn the mic gain up and do one throwaway take. Nobody's first take is good.

---

## The script

### 0:00 — 0:15 · The problem

> "An e-commerce company delivers to twelve Bengaluru neighborhoods. Three
> thousand eight hundred orders a day. They need to know where to put their
> warehouses — and how many to build."

**On screen:** the loaded map, circles sized by order volume. Hover Electronic
City and Whitefield so the tooltips show.

> "Circle size is daily orders. The two biggest are on opposite edges of the
> city. That's what makes this hard."

---

### 0:15 — 0:35 · Data in, and the AI component

**Click Upload → "Try one with unfamiliar headers".**

> "Real logistics spreadsheets don't have columns called id, lat, lon, orders.
> This one says Locality Name, Y Coordinate, Parcels Per Day."

**Point at the purple "AI mapped" badge and the percentages.**

> "A sentence-transformer runs in the browser and maps those headers by meaning.
> No API key, no server — the model is running on this machine. And where the
> header alone is ambiguous, like X Coordinate versus Y Coordinate, it settles it
> from the values."

*(If the badge says "alias table", say: "the model's still loading, so it fell
back to the deterministic mapper — and the interface tells you which one ran."
Do not pretend. Then re-record once it's cached.)*

**Switch back to Sample → Bengaluru — 12 zones.**

---

### 0:35 — 1:05 · Optimise, and the real question

**Press Optimise.** Let the map animate.

> "Three warehouses. Every neighborhood assigned to the one that's genuinely
> cheapest to serve it from — that's what the coloured lines are."

**Point at the hero number.**

> "Twenty-eight percent cheaper than one depot in the middle of the map."

**Now point at the trade-off chart.**

> "But three isn't the answer. Every warehouse you build cuts delivery cost and
> adds rent, so the total has a genuine minimum. The model says four."

**Click "Use the optimum · K=4".**

> "Thirty thousand three hundred sixty rupees a day, down to nineteen thousand
> six hundred and ninety. Thirty-five percent. Forty-six lakh a year — and forty-one
> tonnes of CO₂ that don't get emitted."

---

### 1:05 — 1:35 · The mathematics *(this is the section that wins)*

> "Here's the part that matters. Almost everyone solving this reaches for
> k-means. k-means is the wrong tool."

> "Delivery cost is linear in distance. k-means minimises distance *squared*.
> Square it, and one far-away high-volume neighborhood drags a warehouse toward
> it far harder than its real cost justifies."

**Point at the "vs k-means network" figure.**

> "So we use the geometric median instead of the centroid — weighted k-medians.
> Same number of warehouses, two point two percent cheaper. On a real logistics
> budget that is not a rounding error."

**Open the Proof tab.**

> "And we don't just claim it's optimal. At K equals one it *provably* is — the
> objective is convex, so Weiszfeld's algorithm converges to the global minimum.
> That's a theorem, not a search."

> "Above one, k-medians is NP-hard, so we prove two weaker things honestly:
> we solve the discrete p-median problem exactly — all four hundred and ninety-five
> ways of siting four warehouses on the demand points — and we confirm no
> perturbation within two kilometres improves it. One thousand seven hundred
> and sixty-four probes."

---

### 1:35 — 2:00 · Constraints and robustness

**Open Constraints, tick max radius, set 8 km, drop K to 2.**

> "Constraints are real, and we flag what breaks rather than hiding it. Two
> warehouses, eight kilometre service radius — six neighborhoods out of range."

**Put K back to 4.** The warnings clear.

**Open Fleet & costs, switch traffic to Gridlock.**

> "Monsoon evening gridlock: the same network, twenty-six thousand four hundred a
> day. The plan doesn't change, the cost does — because traffic changes driver
> hours, not distance."

**Set traffic back to Light. Scroll to the robustness line.**

> "And we stress-tested it. Across sixteen runs with demand shifted up to thirty
> percent either way, keeping these warehouses costs zero point six percent more
> than re-optimising with perfect hindsight. The plan survives being wrong."

---

### 2:00 — 2:25 · The thing nobody else has

> "One last thing. The maths was written twice — Tejas in Python, and
> TypeScript for the browser. Independently. Different geometry: the Python runs
> on a projected plane, the TypeScript on the sphere."

**Show the terminal, run `npm run crossval`.**

> "They agree to one ten-thousandth of a percent on cost, and two metres on
> warehouse position. That's not a claim we're asking you to believe. It's a
> script you can run."

---

### 2:25 — 2:40 · Close

> "GridPoint. Upload your neighborhoods, and it tells you where to build, how
> many to build, what it costs, and proves the answer. Runs entirely in the
> browser. No API keys, no backend, nothing to fall over."

**End on the map at K=4, before/after toggled once.**

---

## Shot list (for editing)

| Time | Shot | Must be visible |
|---|---|---|
| 0:00 | Map, hover two circles | circle size = orders |
| 0:15 | Upload → unfamiliar headers | **AI mapped badge + percentages** |
| 0:35 | Press Optimise | lines drawing, 28.2% |
| 0:50 | Trade-off chart | the ★ on K=4 |
| 0:58 | Click "Use the optimum" | 35.1%, ₹46.8L, 41.3 t |
| 1:15 | vs k-means stat | −2.2% |
| 1:25 | Proof tab | "certified", 495 subsets, 1,764 probes |
| 1:40 | Radius 8 km, K=2 | "6 beyond 8 km" warning |
| 1:50 | Traffic → Gridlock | ₹26,436 |
| 1:55 | Robustness line | 0.6% |
| 2:05 | Terminal: `npm run crossval` | the agreement table |
| 2:30 | Before/after toggle | the contrast |

---

## Rules for the recording

- **Never say a number that isn't on screen.** If you misremember, the judges
  see it.
- **Don't apologise for anything.** No "sorry, this is a bit slow."
- **Let the map finish animating** before speaking over it.
- **The k-means section is the one to nail.** It is the difference between "they
  built an app" and "they understood the problem". If you fluff one take, re-do
  that one.
- Slow down. Everyone talks 30% too fast on camera.

## If something breaks mid-take

The map renders its data even with no basemap at all — that's deliberate. If the
tiles don't load, keep going; the circles, lines and warehouses are all still
there. Don't stop and don't mention it.
