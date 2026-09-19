# The maths is Python; the app runs a TypeScript transliteration

**Date:** 2026-09-20 · **By:** Sakshath · **Affects:** Tejas

## Decision

The product is a **Next.js app on Vercel with no backend** - all optimisation
runs client-side in TypeScript.

Tejas's Python stays the **reference implementation and the author of record**
for the mathematics. The TypeScript in the app is a line-for-line
transliteration of it, and a cross-validation harness asserts both produce
identical output to **1e-9** across every sample dataset and every K.

## Why this way

Streamlit cannot deploy to Vercel - it needs an always-on Python server holding
a WebSocket per user, and Vercel runs stateless serverless functions. There is
no workaround.

The alternative was a Python API on a free tier, but those cold-start for ~50
seconds, which is the single most common way a hackathon demo dies live in
front of judges. Zero backend means zero cold start.

## What this is NOT

This is not "Sakshath rewrote the maths." The algorithms, parameters and
modelling choices are Tejas's. The transliteration is mechanical. The
cross-validation harness exists precisely so that claim is checkable rather
than asserted - and having two independent implementations that agree is a
credibility exhibit for the "Technical Execution" score, not wasted effort.

## What this means for you

Write `solver.py` and `engine.py` normally, to the frozen contract. Do not
write TypeScript. If you change the maths, change it in the Python first and
tell me, and I re-transliterate. The Python is the source of truth.
