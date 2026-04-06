# Methodology

This document explains the end-to-end research workflow used in the project.

---

## Stage 1 — Data Preparation

Historical price data is imported and cleaned.

### Steps
- remove missing observations
- align timestamps
- standardize time index
- transform prices into log returns

Output:
- clean return series

---

## Stage 2 — Distribution Diagnostics

The empirical return process is compared against the Gaussian assumption.

### Diagnostics Performed
- histogram
- KDE overlay
- Gaussian fit
- quantile deviation curve
- bootstrap distribution fan

Purpose:
to identify fat tails and non-normality.

---

## Stage 3 — Regime Inference

The market is modeled using three latent states.

### Regimes
- Calm
- Stress
- Crisis

Each state captures different volatility behavior.

Purpose:
to understand state transitions and instability.

---

## Stage 4 — Volatility Geometry

Rolling volatility is computed across inferred states.

This creates:
- regime heatmaps
- volatility clustering visualization

Purpose:
to observe local instability.

---

## Stage 5 — Tail Risk Modeling

Downside tail-event probability is computed.

This creates:
- tail-risk heatmaps
- crisis shock surfaces

Purpose:
to model extreme downside risk.

---

## Stage 6 — Belief Dynamics

The derivative of crisis probability is studied.

This produces:
- belief velocity surface
- ignition zones
- attractor dynamics

Purpose:
to identify rapid instability escalation.