aapl_raw <- read_csv("AAPL_MONTHLY.csv")
glimpse(aapl_raw)

aapl <- aapl_raw %>%
  mutate(
    Date = dmy(Date)
  )

glimpse(aapl)

aapl <- aapl %>%
  arrange(Date)

aapl <- aapl %>%
  select(
    Date,
    Open,
    High,
    Low,
    Close,
    `Adj Close`,
    Volume
  )

aapl <- aapl %>%
  mutate(
    Return = log(`Adj Close` / lag(`Adj Close`))
  )


# AAPL Monthly Log Returns
ggplot(aapl, aes(x = Date, y = Return)) +
  geom_line(color = "firebrick", linewidth = 0.9) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.6) +
  labs(
    title = "AAPL Monthly Log Returns",
    x = "Date", 
    y = "Log Return"
  ) +
  theme_minimal()


mu_hat    <- mean(aapl$Return, na.rm = TRUE)
sigma_hat <- sd(aapl$Return, na.rm = TRUE)


# Empirical Return Distribution vs Gaussian
ggplot(aapl, aes(x = Return)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 15,
    fill = "#2C3E50",
    alpha = 0.75,
    color = "white"
  ) +
  geom_density(
    color = "#E74C3C",
    linewidth = 1.2
  ) +
  stat_function(
    fun = dnorm,
    args = list(mean = mu_hat, sd = sigma_hat),
    color = "#1ABC9C",
    linewidth = 1.2,
    linetype = "dashed"
  ) +
  labs(
    title = "Empirical Return Distribution vs Gaussian Assumption",
    subtitle = "Histogram + KDE (Empirical) + Normal Overlay",
    x = "Log Return",
    y = "Density"
  ) +
  theme_minimal(base_size = 13)


returns <- na.omit(aapl$Return)

p <- seq(0.01, 0.99, by = 0.01)

q_emp <- quantile(returns, probs = p)

q_gauss <- qnorm(p, mean = mean(returns), sd = sd(returns))

q_dev <- q_emp - q_gauss

q_df <- data.frame(
  Probability = p,
  Quantile_Deviation = q_dev
)


# Quantile Deviation from Gaussian Assumption
ggplot(q_df, aes(x = Probability, y = Quantile_Deviation)) +
  geom_line(color = "#8E44AD", linewidth = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.6) +
  labs(
    title = "Quantile Deviation from Gaussian Assumption",
    subtitle = "Empirical Quantiles − Normal Quantiles",
    x = "Probability Level",
    y = "Quantile Deviation"
  ) +
  theme_minimal(base_size = 13)


set.seed(42)

returns <- na.omit(aapl$Return)

B <- 500

boot_samples <- replicate(
  B,
  sample(returns, replace = TRUE)
)

boot_df <- as.data.frame(boot_samples) %>%
  pivot_longer(cols = everything(), values_to = "Return")


# Bootstrap Distribution Fan
ggplot(boot_df, aes(x = Return, group = name)) +
  geom_density(alpha = 0.05, color = "#1F618D") +
  labs(
    title = "Bootstrap Distribution Fan",
    subtitle = "Sampling uncertainty of empirical return distribution",
    x = "Log Return",
    y = "Density"
  ) +
  theme_minimal(base_size = 13)

