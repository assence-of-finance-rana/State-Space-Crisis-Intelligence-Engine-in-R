source("04_regime_probability_inference.R")
ls()

# ============================================================
# STEP 5 — Regime–Tail Shock Geometry (CRISIS)
# Uses EXISTING objects ONLY
# ============================================================

library(plotly)

# -------------------------------
# 1. Sanity checks
# -------------------------------
stopifnot(exists("regime_prob"))
stopifnot(exists("shock_grid"))

# -------------------------------
# 2. Time axis (from regime_prob)
# -------------------------------
T <- nrow(regime_prob)
time_vals <- 1:T

# -------------------------------
# 3. Extract CRISIS probability
# -------------------------------
if (!"Crisis" %in% colnames(regime_prob)) {
  stop("Column 'Crisis' not found in regime_prob")
}

p_crisis <- as.numeric(regime_prob[, "Crisis"])

# -------------------------------
# 4. Build raw shock-response surface
# -------------------------------
shock_grid <- as.numeric(shock_grid)

Z_crisis <- outer(
  shock_grid,
  p_crisis,
  function(s, p) {
    p * exp(-0.5 * s^2) * (1 + abs(s))
  }
)

# -------------------------------
# 5. Gaussian smoothing kernel
# -------------------------------
gaussian_kernel <- function(n = 7, sigma = 1.2) {
  x <- seq(-floor(n/2), floor(n/2))
  k <- exp(-x^2 / (2 * sigma^2))
  k / sum(k)
}

kernel <- gaussian_kernel()

# -------------------------------
# 6. Smooth surface (2D convolution)
# -------------------------------
smooth_surface <- Z_crisis

for (i in 1:nrow(Z_crisis)) {
  smooth_surface[i, ] <- stats::filter(
    Z_crisis[i, ],
    kernel,
    sides = 2
  )
}

smooth_surface[is.na(smooth_surface)] <- 0

# -------------------------------
# 7. Plot 3D Crisis Surface
# -------------------------------
plot_ly(
  x = time_vals,
  y = shock_grid,
  z = smooth_surface,
  type = "surface",
  colorscale = "Viridis"
) %>%
  layout(
    title = "Regime–Tail Shock Impact Surface (Crisis)",
    scene = list(
      xaxis = list(title = "Time"),
      yaxis = list(title = "Shock Magnitude (σ units)"),
      zaxis = list(title = "Crisis Probability")
    )
  )

