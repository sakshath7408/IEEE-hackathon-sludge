# Frozen data contracts

**Date:** 2026-09-20 · **By:** Sakshath · **Affects:** Tejas (solver/engine), Rajath (verifier)

## Decision

Two shapes are frozen. Neither changes without a new decision file first.

### `neighborhood`
```python
{"id": str, "lat": float, "lon": float, "orders": int}
```
- `id` unique and non-empty
- `lat` in [-90, 90], `lon` in [-180, 180]
- `orders` a non-negative **integer**

### `RESULT` - returned by `engine.run(neighborhoods, k, constraints)`
```python
{
  "warehouses":      [{"id": str, "lat": float, "lon": float}],
  "assignments":     {neighborhood_id: warehouse_id},
  "total_cost":      float,
  "baseline_cost":   float,
  "improvement_pct": float,
}
```

Every neighborhood id must appear in `assignments`, and every value in
`assignments` must be the id of a warehouse in `warehouses`.

## Optional extras

The web app renders these when present and degrades silently when absent, so
a leaner engine still works. They are additive - never required:

`baseline_warehouse`, `distances_km`, `load`, `cost_units`, `breakdown`,
`baseline_breakdown`, `perNeighborhood`, `out_of_radius`, `over_capacity`,
`naive_k_cost`, `placement_gain_pct`.

## Why

The app is the top of the dependency chain and imports only `run` from the
engine. Freezing these two shapes means the Python and TypeScript halves can
be developed completely independently and swapped without touching the UI.

## What this means for you

Match these shapes exactly and integration is a file replacement. `baseline_cost`
should be the cost of the **un-optimised** arrangement - we use one warehouse at
the plain unweighted geographic centre, the naive "put it in the middle" choice.
