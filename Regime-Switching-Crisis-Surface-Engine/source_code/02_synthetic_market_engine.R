set.seed(42)

T <- 3000

regimes <- data.frame(
  regime = c("Calm", "Stress", "Crisis"),
  mu     = c(0.0006, -0.0004, 0.0000),
  sigma  = c(0.008,  0.020,   0.045)
)

P <- matrix(
  c(0.95, 0.04, 0.01,
    0.05, 0.90, 0.05,
    0.10, 0.20, 0.70),
  nrow = 3,
  byrow = TRUE
)

regime_path <- numeric(T)
regime_path[1] <- 1

for (t in 2:T) {
  regime_path[t] <- sample(
    1:3,
    size = 1,
    prob = P[regime_path[t - 1], ]
  )
}

returns_syn <- sapply(1:T, function(t) {
  rnorm(
    1,
    mean = regimes$mu[regime_path[t]],
    sd   = regimes$sigma[regime_path[t]]
  )
})

synthetic_market <- data.frame(
  Time   = 1:T,
  Regime = factor(regime_path, labels = regimes$regime),
  Return = returns_syn
)

head(synthetic_market)
table(synthetic_market$Regime)


library(dplyr)
library(ggplot2)

synthetic_vol <- synthetic_market %>%
  mutate(
    RollingVol = zoo::rollapply(
      Return,
      width = 50,
      FUN = sd,
      fill = NA,
      align = "right"
    ),
    RegimeNum = as.numeric(Regime)
  )


# Volatility Geometry across Time and Regimes
ggplot(synthetic_vol, aes(x = Time, y = RegimeNum, fill = RollingVol)) +
  geom_tile() +
  scale_fill_viridis_c(option = "inferno", na.value = "white") +
  scale_y_continuous(
    breaks = 1:3,
    labels = levels(synthetic_vol$Regime)
  ) +
  labs(
    title = "Volatility Geometry of a Regime-Switching Market",
    subtitle = "Rolling volatility across latent market states",
    x = "Time",
    y = "Market Regime",
    fill = "Volatility"
  ) +
  theme_minimal(base_size = 13)


library(dplyr)
library(zoo)
library(ggplot2)

tail_surface <- synthetic_market %>%
  group_by(Regime) %>%
  mutate(
    TailRisk = zoo::rollapply(
      Return,
      width = 100,
      FUN = function(x) mean(x < quantile(x, 0.05)),
      fill = NA,
      align = "right"
    ),
    RegimeNum = as.numeric(Regime)
  ) %>%
  ungroup()


# Tail-Risk Geometry of a Regime-Switching Market
ggplot(tail_surface, aes(x = Time, y = RegimeNum, fill = TailRisk)) +
  geom_tile() +
  scale_fill_viridis_c(option = "magma", na.value = "white") +
  scale_y_continuous(
    breaks = 1:3,
    labels = levels(tail_surface$Regime)
  ) +
  labs(
    title = "Tail-Risk Geometry of a Regime-Switching Market",
    subtitle = "Probability of extreme downside events across regimes",
    x = "Time",
    y = "Market Regime",
    fill = "Downside Tail Probability"
  ) +
  theme_minimal(base_size = 13)

install.packages("ggridges")




