# Shared functions for the state-space models (used by 04 onwards)

# Draw a local level path given its variances (verified against StructTS in 03)
sample_local_level <- function(y, obs_var, step_var, init_mean, init_var, draw = TRUE) {
  n        <- length(y)
  obs_var  <- rep_len(obs_var, n)
  step_var <- rep_len(step_var, n - 1)
  
  H          <- bandSparse(n, k = c(0, -1), diagonals = list(rep(1, n), rep(-1, n - 1)))
  prior_prec <- Diagonal(x = 1 / c(init_var, step_var))
  obs_prec   <- Diagonal(x = 1 / obs_var)
  
  K <- forceSymmetric(t(H) %*% prior_prec %*% H + obs_prec)
  b <- t(H) %*% prior_prec %*% c(init_mean, rep(0, n - 1)) + obs_prec %*% y
  
  path_mean <- as.vector(solve(K, b))
  if (!draw) return(path_mean)
  path_mean + as.vector(solve(chol(K), rnorm(n)))
}

# ---- UC-SV (used in 03) -----------------------------------------------------

# Kim-Shephard-Chib (1998): 7 normals approximating the log chi-square distribution
ksc_p <- c(0.00730, 0.10556, 0.00002, 0.04395, 0.34001, 0.24566, 0.25750)
ksc_m <- c(-10.12999, -3.97281, -8.56686, 2.77786, 0.61942, 1.79518, -1.08819) - 1.2704
ksc_v <- c(5.79596, 2.61369, 5.17950, 0.16735, 0.64009, 0.34023, 1.26261)

# Draw a log-volatility path given residuals
sample_log_vol <- function(resid, h, gamma, init_mean, init_var) {
  ystar <- log(resid^2 + 1e-4)
  dens  <- sapply(1:7, function(j) ksc_p[j] * dnorm(ystar, h + ksc_m[j], sqrt(ksc_v[j])))
  comp  <- apply(dens, 1, function(d) sample(7, 1, prob = d))
  sample_local_level(ystar - ksc_m[comp], obs_var = ksc_v[comp], step_var = gamma,
                     init_mean = init_mean, init_var = init_var)
}

# Full UC-SV Gibbs sampler
run_ucsv <- function(y, tau_start, gamma, n_burn = 5000, n_keep = 10000, thin = 5, seed = 2026) {
  n   <- length(y)
  tau <- tau_start
  h   <- rep(log(var(y - tau)), n)
  g   <- rep(log(var(diff(tau))), n - 1)
  h0  <- h[1]; g0 <- g[1]
  tau_draws <- matrix(NA, n_keep, n)
  h_draws   <- matrix(NA, n_keep, n)
  g_draws   <- matrix(NA, n_keep, n - 1)
  set.seed(seed)
  for (i in 1:(n_burn + n_keep * thin)) {
    tau <- sample_local_level(y, obs_var = exp(h), step_var = exp(g),
                              init_mean = y[1], init_var = 1e6)
    h   <- sample_log_vol(y - tau,   h, gamma, init_mean = h0, init_var = 10)
    g   <- sample_log_vol(diff(tau), g, gamma, init_mean = g0, init_var = 10)
    if (i > n_burn && (i - n_burn) %% thin == 0) {
      k <- (i - n_burn) / thin
      tau_draws[k, ] <- tau; h_draws[k, ] <- h; g_draws[k, ] <- g
    }
    if (i %% 10000 == 0) message("iteration ", i)
  }
  list(tau = tau_draws, h = h_draws, g = g_draws)
}

# ---- Fat-tailed model (used in 04) ------------------------------------------

sample_lambda <- function(resid, noise_var, nu) {
  1 / rgamma(length(resid), shape = (nu + 1) / 2, rate = (nu + resid^2 / noise_var) / 2)
}

sample_nu <- function(lambda, nu_grid = c(seq(2.1, 10, by = 0.1), 11:60)) {
  logpost <- sapply(nu_grid, function(nu)
    sum(dgamma(1 / lambda, shape = nu / 2, rate = nu / 2, log = TRUE) - 2 * log(lambda)))
  sample(nu_grid, 1, prob = exp(logpost - max(logpost)))
}

run_fat_tails <- function(y, sig2_eta_start, sig2_eps_start,
                          n_burn = 5000, n_keep = 10000, thin = 5, seed = 2026,
                          a0 = 2, b0 = 1) {
  n <- length(y)
  sig2_eta <- sig2_eta_start; sig2_eps <- sig2_eps_start
  lambda <- rep(1, n); nu <- 10
  tau_draws    <- matrix(NA, n_keep, n)
  lambda_draws <- matrix(NA, n_keep, n)
  par_draws    <- matrix(NA, n_keep, 3, dimnames = list(NULL, c("sig2_eta", "sig2_eps", "nu")))
  set.seed(seed)
  for (i in 1:(n_burn + n_keep * thin)) {
    tau      <- sample_local_level(y, obs_var = sig2_eta * lambda, step_var = sig2_eps,
                                   init_mean = y[1], init_var = 1e6)
    e        <- y - tau
    lambda   <- sample_lambda(e, sig2_eta, nu)
    sig2_eta <- 1 / rgamma(1, a0 + n / 2,       b0 + sum(e^2 / lambda) / 2)
    sig2_eps <- 1 / rgamma(1, a0 + (n - 1) / 2, b0 + sum(diff(tau)^2) / 2)
    nu       <- sample_nu(lambda)
    if (i > n_burn && (i - n_burn) %% thin == 0) {
      k <- (i - n_burn) / thin
      tau_draws[k, ] <- tau; lambda_draws[k, ] <- lambda
      par_draws[k, ] <- c(sig2_eta, sig2_eps, nu)
    }
    if (i %% 10000 == 0) message("iteration ", i)
  }
  list(tau = tau_draws, lambda = lambda_draws, par = par_draws)
}
