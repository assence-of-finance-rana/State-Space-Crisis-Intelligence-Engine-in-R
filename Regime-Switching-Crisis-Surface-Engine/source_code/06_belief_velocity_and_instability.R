source("04_regime_probability_inference.R")
source("05_regime_tail_surface_smoothing.R")

library(plotly)

stopifnot(
  exists("Z_crisis"),
  exists("time_vals"),
  exists("shock_grid")
)

Z_raw <- as.matrix(Z_crisis)

if (nrow(Z_raw) == length(shock_grid)) {
  Z <- t(Z_raw)
} else {
  Z <- Z_raw
}

T_len <- length(time_vals)
S_len <- length(shock_grid)

stopifnot(
  nrow(Z) == T_len,
  ncol(Z) == S_len
)

belief_velocity <- matrix(0, nrow = T_len, ncol = S_len)

for (i in 2:(T_len - 1)) {
  belief_velocity[i, ] <- (Z[i + 1, ] - Z[i - 1, ]) / 2
}

belief_velocity[1, ]     <- Z[2, ] - Z[1, ]
belief_velocity[T_len, ] <- Z[T_len, ] - Z[T_len - 1, ]

gaussian_kernel <- function(n, sigma = 1.2) {
  x <- seq(-floor(n/2), floor(n/2))
  g <- exp(-x^2 / (2 * sigma^2))
  g / sum(g)
}

kernel <- gaussian_kernel(7)

smooth_velocity <- belief_velocity

for (j in 1:S_len) {
  smooth_velocity[, j] <- stats::filter(
    belief_velocity[, j],
    kernel,
    sides = 2
  )
}

smooth_velocity[is.na(smooth_velocity)] <- 0


# Belief Velocity Surface (Crisis Regime)
plot_ly(
  x = time_vals,
  y = shock_grid,
  z = smooth_velocity,
  type = "surface",
  colorscale = "Turbo"
) %>%
  layout(
    title = "Belief Velocity Surface (Crisis Regime)",
    scene = list(
      xaxis = list(title = "Time"),
      yaxis = list(title = "Shock Magnitude (σ units)"),
      zaxis = list(title = "Belief Velocity ∂P/∂t"),
      camera = list(
        eye = list(x = 1.8, y = -1.6, z = 0.9)
      )
    )
  )


library(plotly)

stopifnot(
  exists("p_crisis"),
  exists("smooth_velocity"),
  exists("shock_vals"),
  exists("time_vals")
)

phase_df <- data.frame(
  belief = as.vector(p_crisis),
  velocity = as.vector(smooth_velocity),
  shock = rep(shock_vals, each = length(time_vals)),
  time = rep(time_vals, times = length(shock_vals))
)

phase_df <- phase_df[is.finite(phase_df$velocity), ]


# Crisis Regime Phase Portrait — Belief Flow
plot_ly(
  phase_df,
  x = ~belief,
  y = ~velocity,
  type = "scattergl",
  mode = "markers",
  marker = list(
    size = 3,
    color = ~shock,
    colorscale = "Inferno",
    showscale = TRUE,
    line = list(width = 0)
  )
) %>%
  layout(
    title = "Crisis Regime Phase Portrait — Belief Flow",
    paper_bgcolor = "black",
    plot_bgcolor = "black",
    xaxis = list(
      title = "Crisis Belief P(t)",
      color = "white",
      gridcolor = "rgba(255,255,255,0.05)"
    ),
    yaxis = list(
      title = "Belief Velocity ∂P/∂t",
      color = "white",
      gridcolor = "rgba(255,255,255,0.05)"
    )
  )


library(dplyr)
library(plotly)

phase_df2 <- phase_df %>%
  mutate(
    abs_velocity = abs(velocity)
  )

attractors <- phase_df2 %>%
  filter(abs_velocity < quantile(abs_velocity, 0.05))

instability <- phase_df2 %>%
  filter(abs_velocity > quantile(abs_velocity, 0.95))


# Crisis Regime Dynamics — Attractors & Instability
plot_ly() %>%
  add_trace(
    data = phase_df2,
    x = ~belief,
    y = ~velocity,
    type = "scattergl",
    mode = "markers",
    marker = list(
      size = 2,
      color = "rgba(255,255,255,0.15)"
    ),
    name = "Belief Flow"
  ) %>%
  add_trace(
    data = attractors,
    x = ~belief,
    y = ~velocity,
    type = "scattergl",
    mode = "markers",
    marker = list(
      size = 3,
      color = "cyan"
    ),
    name = "Regime Attractors"
  ) %>%
  add_trace(
    data = instability,
    x = ~belief,
    y = ~velocity,
    type = "scattergl",
    mode = "markers",
    marker = list(
      size = 3,
      color = "red"
    ),
    name = "Crisis Ignition Zones"
  ) %>%
  layout(
    title = "Crisis Regime Dynamics — Attractors & Instability",
    paper_bgcolor = "black",
    plot_bgcolor = "black",
    xaxis = list(
      title = "Crisis Belief P(t)",
      color = "white",
      gridcolor = "rgba(255,255,255,0.05)"
    ),
    yaxis = list(
      title = "Belief Velocity ∂P/∂t",
      color = "white",
      gridcolor = "rgba(255,255,255,0.05)"
    ),
    legend = list(
      font = list(color = "white")
    )
  )
