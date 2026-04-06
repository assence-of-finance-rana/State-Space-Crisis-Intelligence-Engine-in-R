# Mathematical Framework

This document outlines the mathematical and statistical foundations of the **Regime-Switching Crisis Surface Engine**.

---

## 1. Log Return Transformation

The raw price process is transformed into continuously compounded returns.

\[
r_t = \ln\left(\frac{P_t}{P_{t-1}}\right)
\]

Where:

- \( P_t \) = asset price at time \( t \)
- \( P_{t-1} \) = asset price at previous time step

This transformation stabilizes scale and makes the return series additive over time.

---

## 2. Rolling Volatility

Local market instability is measured using rolling standard deviation.

\[
\sigma_t = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(r_i-\bar{r})^2}
\]

Where:

- \( n \) = rolling window size
- \( \bar{r} \) = rolling mean return

This captures volatility clustering across latent regimes.

---

## 3. Kernel Density Estimation (KDE)

Empirical return density is estimated non-parametrically.

\[
f(x)=\frac{1}{nh}\sum_{i=1}^{n}K\left(\frac{x-x_i}{h}\right)
\]

Where:

- \( K \) = kernel function
- \( h \) = bandwidth parameter

Used to compare empirical returns with Gaussian assumptions.

---

## 4. Quantile Deviation

Deviation from the Gaussian model is measured as:

\[
D(p)=Q_{emp}(p)-Q_{norm}(p)
\]

Where:

- \( Q_{emp}(p) \) = empirical quantile
- \( Q_{norm}(p) \) = Gaussian quantile

This highlights fat tails and downside asymmetry.

---

## 5. Latent Regime Probability

The market is modeled across hidden states.

\[
P(S_t = k \mid \mathcal{F}_{t-1})
\]

Where:

- \( S_t \) = latent state at time \( t \)
- \( k \in \{Calm, Stress, Crisis\} \)

This forms the probabilistic regime inference layer.

---

## 6. Crisis Shock Surface

The 3D crisis surface is defined as:

\[
C(t,z)=P(\text{Crisis} \mid z,t)
\]

Where:

- \( t \) = time
- \( z \) = standardized shock magnitude

This surface maps crisis probability under stress.

---

## 7. Belief Velocity

Dynamic instability is modeled as:

\[
\frac{\partial P_t}{\partial t}
\]

This measures the speed of crisis belief transition.

Large positive values indicate rapid escalation zones.