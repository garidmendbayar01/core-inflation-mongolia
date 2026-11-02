# run_all.R: reproduces every result in the thesis, in dependency order.
# Each file is rendered in a fresh environment, so it can only use what it loads itself.

library(here)

steps <- c(
  # 1. State-space measures
  "Kalman filtering/01_load_cpi.Rmd",
  "Kalman filtering/02_fit_local_level.Rmd",
  "Kalman filtering/03_uc_sv.Rmd",
  "Kalman filtering/04_fat_tails.Rmd",
  "Kalman filtering/05_robustness.Rmd",
  "Kalman filtering/06_results_tables.Rmd",
  # 2. Dynamic factor model
  "DFM/01_dfm_data.Rmd",
  "DFM/02_dfm_model.Rmd",
  # 3. Exclusion measures
  "exclusion/01_exclusion_measure.Rmd",
  "exclusion/02_extend_to_2006.Rmd",
  # 4. SVAR
  "SVAR/01_svar_data.Rmd",
  "SVAR/02_svar_model.Rmd",
  "SVAR/03_svar_external.Rmd",
  "SVAR/04_svar_gdp2015.Rmd",
  # 5. Evaluation
  "evaluation/01_compare_measures.Rmd",
  "evaluation/02_forecast_eval.Rmd",
  "evaluation/03_forecast_eval_2012.Rmd",
  "evaluation/04_taylor_rule.Rmd"
)

skip_slow <- FALSE    # TRUE skips the MCMC and real-time vintage steps (faster); FALSE reruns everything
slow      <- c("Kalman filtering/03_uc_sv.Rmd", "Kalman filtering/04_fat_tails.Rmd",
               "Kalman filtering/05_robustness.Rmd", "Kalman filtering/06_results_tables.Rmd",
               "evaluation/02_forecast_eval.Rmd", "evaluation/03_forecast_eval_2012.Rmd")
for (f in steps) {
  if (skip_slow && f %in% slow) { message("Skipping (slow): ", f); next }
  message("Running: ", f)
  xfun::Rscript_call(rmarkdown::render, list(here(f), quiet = TRUE))
}

writeLines(capture.output(sessionInfo()), here("output", "session_info.txt"))
message("Done. All outputs regenerated.")