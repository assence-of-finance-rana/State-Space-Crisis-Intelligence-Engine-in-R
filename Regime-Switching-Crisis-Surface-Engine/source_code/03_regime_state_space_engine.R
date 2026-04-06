
# Regime-Switching State-Space Engine

set.seed(42)

# Time length
T <- 3000

# Define regimes
regimes <- data.frame(
  name = c("Calm", "Stress", "Crisis"),
  mu   = c(0.0005, -0.0005, -0.002),
  sigma = c(0.01, 0.025, 0.05)
)

# Transition matrix
P <- matrix(
  c(0.95, 0.04, 0.01,
    0.05, 0.90, 0.05,
    0.10, 0.30, 0.60),
  nrow = 3, byrow = TRUE
)

# Simulate hidden regime path
regime_path <- numeric(T)
regime_path[1] <- 1

for (t in 2:T) {
  regime_path[t] <- sample(
    1:3, size = 1, prob = P[regime_path[t - 1], ]
  )
}

# Generate returns conditional on regime
returns <- rnorm(
  T,
  mean = regimes$mu[regime_path],
  sd   = regimes$sigma[regime_path]
)

# Assemble state-space object
state_space <- data.frame(
  time = 1:T,
  regime = factor(regime_path, labels = regimes$name),
  return = returns
)

table(state_space$regime)
head(state_space)
