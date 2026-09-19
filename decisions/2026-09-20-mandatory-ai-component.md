# The AI component is mandatory, and it is real

**Date:** 2026-09-20 · **By:** Sakshath · **Affects:** Tejas, Rajath, and the README

## The rule

The hackathon brochure (page 12) states: *"README File: The README file should
clearly mention the AI component used."* Under Disqualification it lists
*"Faking or hardcoding the AI component."*

GridPoint as specified is pure optimisation maths with no AI anywhere. This was
not mentioned in the opening call and is easy to miss. **Confirmed with the
organisers: an AI component is required.**

## What we built

**Model:** `Xenova/all-MiniLM-L6-v2` (sentence-transformers MiniLM-L6-v2,
ONNX, int8-quantised, ~23 MB)
**Runtime:** Transformers.js v3 on WebAssembly - inference runs **entirely in
the visitor's browser**. No API key, no server, no data leaves the machine.

**What it does:** semantic CSV column mapping. A real logistics spreadsheet does
not have columns called `id/lat/lon/orders` - it has "Locality Name",
"Y Coordinate", "Parcels Per Day". We embed each incoming header and each target
field description into the same vector space and match them by cosine
similarity, so headers nobody anticipated still map correctly.

**Honest accounting of the signals**, because overclaiming here is a
disqualification risk:
1. Semantic similarity from the transformer - the **primary** signal.
2. A numeric-range prior from the column's own values - a **tie-breaker only**.
   "X Coordinate" and "Y Coordinate" are near-identical strings; only the
   values can settle which is which, and no language model can do that from a
   header alone.

The prior is additive and bounded. Every returned mapping records which path
produced it, and the UI shows whether the model or the deterministic fallback
ran. If the model cannot load, we fall back to an alias table and **say so** in
the interface rather than pretending the model ran.

## Status

**NOT YET VERIFIED.** The build sandbox blocks huggingface.co, so the model has
never actually downloaded or executed. Somebody must open the app on a real
machine and confirm it works before we submit.

## What this means for you

The README must name this model explicitly, and must credit every open-source
library we use - that is also an explicit rule. Do not describe the AI as doing
more than the above.
