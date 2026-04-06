Sys.which("make")
install.packages(c(
  "matrixStats",
  "Rcpp",
  "RcppArmadillo",
  "mvtnorm",
  "expm",
  "pracma",
  "cubature",
  "coda",
  "ggplot2",
  "viridis",
  "plotly",
  "data.table",
  "tidyr",
  "dplyr"
))


library(matrixStats)
library(Rcpp)
library(RcppArmadillo)
library(mvtnorm)
library(expm)
library(pracma)
library(cubature)
library(coda)
library(ggplot2)
library(plotly)
library(data.table)
library(tidyr)
library(dplyr)

rm(list = ls())
gc()

set.seed(42)

regimes <- data.frame(
  id    = 1:3,
  name  = c("Calm", "Stress", "Crisis"),
  mu    = c( 0.0006, -0.0005, -0.0020),
  sigma = c( 0.0060,  0.0150,  0.0400),
  nu    = c(12, 6, 3)
)

print(regimes)

Pi <- matrix(
  c(
    0.94, 0.05, 0.01,
    0.10, 0.80, 0.10,
    0.05, 0.20, 0.75
  ),
  nrow = 3,
  byrow = TRUE
)

colnames(Pi) <- regimes$name
rownames(Pi) <- regimes$name

Pi
rowSums(Pi)
eigen(Pi)$values


T <- 3000
S <- integer(T)

S[1] <- 1

for (t in 2:T) {
  S[t] <- sample(
    x = 1:3,
    size = 1,
    prob = Pi[S[t-1], ]
  )
}

table(S)

returns <- numeric(T)

for (t in 1:T) {
  k <- S[t]
  returns[t] <- regimes$mu[k] +
    regimes$sigma[k] * rt(1, df = regimes$nu[k])
}

summary(returns)

state_space <- data.frame(
  time   = 1:T,
  regime = factor(S, labels = regimes$name),
  return = returns
)

head(state_space)


K <- nrow(regimes)

alpha <- matrix(NA, nrow = T, ncol = K)
colnames(alpha) <- regimes$name

alpha[1, ] <- rep(1 / K, K)


t_likelihood <- function(x, mu, sigma, nu) {
  dt((x - mu) / sigma, df = nu) / sigma
}


for (t in 2:T) {
  
  alpha_pred <- as.numeric(alpha[t-1, ] %*% Pi)
  
  L <- numeric(K)
  for (k in 1:K) {
    L[k] <- t_likelihood(
      x     = returns[t],
      mu    = regimes$mu[k],
      sigma = regimes$sigma[k],
      nu    = regimes$nu[k]
    )
  }
  
  alpha[t, ] <- alpha_pred * L
  alpha[t, ] <- alpha[t, ] / sum(alpha[t, ])
}

summary(rowSums(alpha))
summary(alpha[, "Calm"])
summary(alpha[, "Stress"])
summary(alpha[, "Crisis"])


regime_prob <- data.frame(
  time   = 1:T,
  alpha
)

head(regime_prob)


entropy <- function(p) {
  p <- p[p > 0]
  -sum(p * log(p))
}

regime_prob$entropy <- apply(
  regime_prob[, regimes$name],
  1,
  entropy
)

summary(regime_prob$entropy)


belief_velocity <- matrix(NA, nrow = T, ncol = K)
colnames(belief_velocity) <- regimes$name

for (k in 1:K) {
  belief_velocity[, k] <- c(NA, diff(regime_prob[[regimes$name[k]]]))
}

belief_velocity <- as.data.frame(belief_velocity)
regime_prob <- cbind(regime_prob, belief_velocity)

summary(belief_velocity$Crisis)


memory_window <- 50

for (k in regimes$name) {
  regime_prob[[paste0(k, "_mem")]] <-
    zoo::rollmean(regime_prob[[k]],
                  k = memory_window,
                  fill = NA,
                  align = "right")
}


shock_grid <- seq(-5, 5, length.out = 200)

shock_df <- expand.grid(
  time  = seq(1, T, by = 10),
  shock = shock_grid
)


shock_response <- function(p, shock, regimes) {
  
  L <- numeric(nrow(regimes))
  
  for (k in 1:nrow(regimes)) {
    L[k] <- dt(
      (shock * regimes$sigma[k]) / regimes$sigma[k],
      df = regimes$nu[k]
    )
  }
  
  post <- p * L
  post / sum(post)
}


surface_data <- list()

for (i in seq(100, T, by = 50)) {
  
  p0 <- as.numeric(regime_prob[i, regimes$name])
  
  S <- sapply(shock_grid, shock_response,
              p = p0,
              regimes = regimes)
  
  surface_data[[as.character(i)]] <- data.frame(
    time   = i,
    shock  = shock_grid,
    Calm   = S[1, ],
    Stress = S[2, ],
    Crisis = S[3, ]
  )
}

surface_data <- do.call(rbind, surface_data)

library(plotly)

time_vals  <- sort(unique(surface_data$time))
shock_vals <- sort(unique(surface_data$shock))

Z_crisis <- matrix(
  surface_data$Crisis,
  nrow = length(shock_vals),
  ncol = length(time_vals),
  byrow = FALSE
)

dim(Z_crisis)


# Raw Crisis Probability Surface
p_crisis <- plot_ly(
  x = time_vals,
  y = shock_vals,
  z = Z_crisis,
  type = "surface"
)

p_crisis


# Enhanced Crisis Shock Impact Surface
p_crisis <- plot_ly(
  x = time_vals,
  y = shock_vals,
  z = Z_crisis,
  type = "surface",
  colorscale = "Viridis"
) %>%
  layout(
    title = "Regime–Tail Shock Impact Surface (Crisis)",
    scene = list(
      xaxis = list(title = "Time"),
      yaxis = list(title = "Shock Magnitude (σ units)"),
      zaxis = list(title = "Crisis Probability"),
      camera = list(
        eye = list(x = 1.7, y = -1.7, z = 0.9)
      )
    )
  )

p_crisis

