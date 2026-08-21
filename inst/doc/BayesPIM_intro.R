## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval = FALSE-------------------------------------------------------------
# library(BayesPIM)
# 
# # Generate data under the PIM of Klausch et al. (2026)
# set.seed(2025)
# dat <- gen_data(
#   kappa   = 0.7,          # Test sensitivity
#   n       = 1e3,          # Sample size
#   theta   = 0.2,          # Baseline prevalence when all covariates are zero
#   p       = 1,            # Number of continuous covariates
#   p_discrete = 1,         # Add one Bernoulli(0.5) covariate
#   beta_t  = c(0.2, 0.2),  # True incidence slopes
#   beta_g  = c(0.2, 0.2),  # True prevalence slopes
#   mu_t    = 5,            # True incidence intercept
#   sigma_t = 0.2,          # True incidence AFT scale
#   dist    = "weibull",    # Incidence distribution
#   v_min   = 20,           # Minimum time between screening moments
#   v_max   = 30,           # Maximum time between screening moments
#   mean_rc = 80,           # Mean time to right censoring (exponential)
#   prob_r  = 1             # Probability that a baseline test is done
# )

## ----eval = FALSE-------------------------------------------------------------
# head(dat$v_obs)

## ----eval = FALSE-------------------------------------------------------------
# v <- dat$v_obs
# prevalent <- vapply(v, function(x) length(x) == 1L, logical(1))
# censored  <- vapply(v, function(x) length(x) > 1L && is.infinite(x[length(x)]), logical(1))
# c(prevalent = sum(prevalent),
#   incident  = sum(!prevalent & !censored),
#   censored  = sum(censored))

## ----eval = FALSE-------------------------------------------------------------
# mod_slice <- bayespim(
#   v_obs = dat$v_obs,
#   x_t = dat$x,
#   x_g = dat$x,
#   r = dat$r,
#   kappa = 0.7,
#   update_kappa = FALSE,
#   ndraws = 1e3,
#   warmup = 5e2,
#   save_every = 1,
#   standardize_covariates = TRUE,
#   chains = 4,
#   seed_chains = 1:4,
#   min_effss = 800,
#   update_till_converge = FALSE,
#   sampler = "slice_collapsed",
#   dist = "weibull"
# )

## ----eval = FALSE-------------------------------------------------------------
# mod_slice$runtime

## ----eval = FALSE-------------------------------------------------------------
# mod_slice_update <- bayespim(
#   prev_run = mod_slice,
#   ndraws_update = 2e3,
#   min_effss = 800
# )

## ----eval = FALSE-------------------------------------------------------------
# mod_weibull <- bayespim(
#   v_obs = dat$v_obs,
#   x_t = dat$x,
#   x_g = dat$x,
#   r = dat$r,
#   kappa = 0.7,
#   update_kappa = FALSE,
#   ndraws = 1e3,
#   warmup = 5e2,
#   save_every = 1,
#   standardize_covariates = TRUE,
#   chains = 4,
#   seed_chains = 1:4,
#   min_effss = 800,
#   update_till_converge = TRUE,
#   ndraws_update = 1e3,
#   sampler = "slice_collapsed",
#   dist = "weibull"
# )

## ----eval = FALSE-------------------------------------------------------------
# mod_weibull$runtime

## ----eval = FALSE-------------------------------------------------------------
# # Exponential model (Weibull with sigma fixed at 1)
# mod_exp <- bayespim(
#   v_obs = dat$v_obs, x_t = dat$x, x_g = dat$x, r = dat$r,
#   kappa = 0.7, update_kappa = FALSE,
#   ndraws = 1e3, warmup = 5e2, chains = 4, seed_chains = 5:8,
#   update_till_converge = TRUE, ndraws_update = 1e3,
#   sampler = "slice_collapsed", dist = "weibull",
#   fix_sigma = TRUE, sig_prior = 1
# )

## ----eval = FALSE-------------------------------------------------------------
# # Generalized-gamma model (Weibull is a special case)
# mod_gg <- bayespim(
#   v_obs = dat$v_obs, x_t = dat$x, x_g = dat$x, r = dat$r,
#   kappa = 0.7, update_kappa = FALSE,
#   ndraws = 2e3, warmup = 1e3, chains = 4, seed_chains = 9:12,
#   update_till_converge = TRUE, ndraws_update = 2e3,
#   sampler = "slice_collapsed", dist = "gengamma"
# )

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2025)
# get_ic(mod_weibull, samples = 1e3)

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2025)
# get_ic(mod_exp, samples = 1e3)

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2025)
# get_ic(mod_gg, samples = 1e3)

## ----eval = FALSE-------------------------------------------------------------
# plot(mod_weibull, thinning = 5)

## ----mcmc-traceplot, echo = FALSE, out.width = "100%", fig.cap = "Trace and density plots for the incidence (latent-time) model parameters of the Weibull fit."----
knitr::include_graphics("figures/mcmc-traceplot.png")

## ----eval = FALSE-------------------------------------------------------------
# summary(mod_weibull)

## ----eval = FALSE-------------------------------------------------------------
# summary(trim_mcmc(mod_weibull$par, burnin = mod_weibull$warmup))

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2025)
# cif_pts <- ppCIF(mod_weibull, ppd_type = "percentiles", quant = c(0, 100, 200))
# cif_pts$mixture$med_cdf         # posterior median mixture CIF
# cif_pts$mixture$med_cdf_ci      # 2.5% and 97.5% posterior band
# cif_pts$nonprevalent$med_cdf    # posterior median non-prevalent CIF

## ----eval = FALSE-------------------------------------------------------------
# ppCIF(mod_weibull, ppd_type = "percentiles", quant = c(0, 100, 200),
#       fix_x_t = c(NA, 1))

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2026)
# cif <- ppCIF(mod_weibull, pst_samples = 1e3, ppd_type = "percentiles",
#              quant = seq(0, 300, length.out = 601))
# plot(cif, type = "both", xlim = c(0, 300))

## ----ppCIF-both, echo = FALSE, out.width = "100%", fig.cap = "Posterior predictive mixture CIF (left) and non-prevalent CIF (right) with 95% credible bands."----
knitr::include_graphics("figures/ppCIF_both.png")

## ----eval = FALSE-------------------------------------------------------------
# set.seed(2027)
# cif_x2_0 <- ppCIF(mod_weibull, fix_x_t = c(NA, 0), pst_samples = 1e3,
#                   ppd_type = "percentiles", quant = seq(0, 300, length.out = 601))
# set.seed(2028)
# cif_x2_1 <- ppCIF(mod_weibull, fix_x_t = c(NA, 1), pst_samples = 1e3,
#                   ppd_type = "percentiles", quant = seq(0, 300, length.out = 601))
# 
# plot(cif_x2_0, type = "nonprevalent", ci = FALSE, xlim = c(0, 300),
#      main = "Conditional non-prevalent CIF by baseline covariate")
# lines(cif_x2_1$quant, cif_x2_1$nonprevalent$med_cdf, col = "#D55E00", lwd = 2)
# legend("bottomright", bty = "n", lwd = 2, col = c("#0072B2", "#D55E00"),
#        legend = c("x2 = 0", "x2 = 1"))

## ----ppCIF-cond, echo = FALSE, out.width = "80%", fig.cap = "Conditional non-prevalent CIFs for the two levels of the discrete covariate, marginalizing over the continuous covariate."----
knitr::include_graphics("figures/ppCIF_conditional.png")

## ----eval = FALSE-------------------------------------------------------------
# mod_kappa <- bayespim(
#   v_obs = dat$v_obs, x_t = dat$x, x_g = dat$x, r = dat$r,
#   update_kappa = TRUE,
#   kappa_prior = c(0.7, 0.1),   # Beta prior with mean 0.7 and sd 0.1
#   ndraws = 1e3, warmup = 5e2, chains = 4, seed_chains = 1:4,
#   update_till_converge = TRUE, dist = "weibull"
# )

## ----eval = FALSE-------------------------------------------------------------
# mod_mh_ini <- bayespim(
#   v_obs = dat$v_obs, x_t = dat$x, x_g = dat$x, r = dat$r,
#   kappa = 0.7, update_kappa = FALSE,
#   ndraws = 1e3, warmup = 5e2, chains = 4, seed_chains = 1:4,
#   sampler = "mh", prop_sd = 0.005, dist = "weibull"
# )
# 
# search_sd <- search_prop_sd(m = mod_mh_ini)
# search_sd$prop_sd

