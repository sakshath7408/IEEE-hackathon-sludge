# Paste this into Tejas's Claude session

Everything below the line. It assumes zero shared context.

---

Pull the shared context repo and get the GridPoint web app running on my machine
so I can see it. Then report back.

**Step 1 — sync the shared context.**

```bash
cd ~/Documents/IEEE-HACKATHON   # or wherever you cloned it
git pull
```

Then read these four files and tell me in 3–4 lines what changed on Sakshath's
side since I last looked:

- `CONTEXT.md`
- `logs/sakshath.md`
- `shared/BRIEFING_FOR_TEJAS.md`  ← read this one carefully, it is addressed to me
- `decisions/` (all four files)

**Important:** `gridpoint/HANDOFF_SAKSHATH.md` that I wrote earlier is now out of
date. The briefing supersedes it. Do not act on the handoff doc.

**Step 2 — run the web app.**

The code repo is **https://github.com/sakshath7408/gridpoint** (public). Clone it
somewhere OUTSIDE the context repo — do not nest it inside `IEEE-HACKATHON`:

```bash
cd ~/Documents
git clone https://github.com/sakshath7408/gridpoint.git
cd gridpoint
npm install
npm run dev
```

Needs Node 20+. No API keys, no `.env`, no database — it is entirely
client-side. Open http://localhost:3000.

**Step 3 — check these four things and tell me what you find.**

1. Press **Optimise**. Does it show **28.2%** cheaper than one central depot, and
   does it say the real optimum is **K=4** at **35.1%**?
2. Left panel → **Upload** → **"Try one with unfamiliar headers"**. Does the badge
   go purple and read **"AI mapped"**, or orange and read **"alias table"**?
   This matters — the AI component is a mandatory submission requirement with a
   disqualification clause, and Sakshath's side has never been able to verify it.
3. Run `npm run crossval`. This runs **my** `python/solver.py` against the
   TypeScript port on my `SAMPLE_NEIGHBORHOODS` and compares. It should report
   agreement to about 0.0001% on cost and ~2 metres on warehouse position across
   K=1..5. Confirm it passes on my machine.
4. Run `npx tsx scripts/test_core.ts` — should be 70/70.

**Step 4 — check the app has not misrepresented my mathematics.**

I wrote the reference implementation. Look at `lib/solver.ts` and `lib/engine.ts`
against my `python/solver.py` and `python/engine.py`, and at what the UI claims
in the **Proof** tab. Tell me if anything overclaims or contradicts what my
solver actually does. The data contract is frozen; the presentation is not, so
if something is wrong say so.

**Step 5 — then my real job.**

Per the briefing, my remaining task is the **mathematical write-up**, not more
code. "Mathematical Modelling & Problem Solving" is an explicit judging criterion
and this is a mathematics society's hackathon. Help me draft it covering:

- Why weighted k-medians and not k-means — delivery cost is linear in distance,
  not squared, and what that costs in rupees
- Weiszfeld's algorithm, and why the K=1 case is *provably* globally optimal
  (convex objective, descent method — a theorem, not a search)
- Why K>1 is NP-hard, and what we therefore claim instead: exact discrete
  p-median over all C(n,k) subsets as a benchmark, plus local-optimality
  certification
- The infrastructure-vs-delivery trade-off and why total cost has an interior
  minimum
- The cross-validation result from step 3 — two independent implementations in
  two languages agreeing to 0.0001%

**Step 6 — follow the repo protocol from here.**

Read the protocol in `README.md` of the context repo. In particular: at the end
of the session, append a dated entry to `logs/tejas.md` (mine only — never touch
`logs/sakshath.md`), update `CONTEXT.md` if project state changed, then run
`./sync.sh "message"`.

Note: `logs/tejas.md` is still the blank template. My code push at 00:15 went
unnoticed by Sakshath's side for 45 minutes because the protocol says to read the
other person's *log*, and mine was empty. Please write an entry this time.

Deadline is **18:00 IST today**, submission form opens 17:00, target is to submit
by **17:00**.
