# Measuring Core Inflation in Mongolia

Undergraduate honors thesis in economics, Vanderbilt University.
Author: Garid Mendbayar. Advisor: Kathleen McKiernan.

## How to reproduce the results
1. Open `Core inflation.Rproj` in RStudio.
2. Run `renv::restore()` to install the exact package versions used (recorded in `renv.lock`).
3. Run `source("run_all.R")`. By default (`skip_slow <- TRUE`), the slow steps (MCMC samplers,
   robustness re-estimations, and real-time vintages) are skipped and their saved outputs are used.
   Set `skip_slow <- FALSE` to rerun everything (several hours).

Package and R versions used are also saved in `output/session_info.txt`.

## Folders
| Folder | Contents |
|---|---|
| `Kalman filtering/` | Local level, UC-SV, and fat-tailed trend models |
| `DFM/` | Dynamic factor model |
| `exclusion/` | Exclusion-based measures, official basket weights, extension back to 2006 |
| `SVAR/` | Quah-Vahey SVAR, linking of GDP and CPI across base years, commodity-price extension |
| `evaluation/` | Comparison of measures, real-time forecast evaluation (2017 and 2012 windows), Taylor rule and reaction functions |
| `trimmed mean/` | Archived: an earlier measure dropped from the project (not part of `run_all.R`) |
| `data/raw/` | Original downloaded files (never edited) |
| `data/` (other folders) | Intermediate outputs, organized by analysis |
| `output/` | Figures, tables, and `session_info.txt` |

## Data sources
| File | Source | Downloaded |
|---|---|---|
| `data/raw/nso_cpi_groups_2026-09-28.xlsx` | National Statistics Office of Mongolia (1212.mn), national CPI by group, monthly | 2026-09-28 |
| `data/raw/nso_cpi_divisions_all_bases_2026-10-06.xlsx` | National Statistics Office of Mongolia (1212.mn), CPI by division, 2015, 2020 and 2023 bases | 2026-10-06 |
| `data/raw/nso_gdp_quarterly_all_bases_2026-10-05.xlsx` | National Statistics Office of Mongolia (1212.mn), quarterly real GDP, 2005, 2010 and 2015 prices (May 2026 release) | 2026-10-05 |
| `data/raw/bom_policy_rate_2026-10-06.xlsx` | Bank of Mongolia, policy rate decisions | 2026-10-06 |
| `data/raw/bom_mnt_usd_2026-10-06.xlsx` | Bank of Mongolia, official MNT/USD exchange rate, daily | 2026-10-06 |
| `data/raw/fred_copper_2026-10-06.csv` | FRED, series PCOPPUSDM (IMF Primary Commodity Prices) | 2026-10-06 |
| `data/raw/fred_brent_2026-10-06.csv` | FRED, series POILBREUSDM (IMF Primary Commodity Prices) | 2026-10-06 |
| `data/trimmed_mean/inflation-rate.xlsx` | Bank of Mongolia, published inflation: national headline, Ulaanbaatar, and core, monthly | 2026-09-16 |
| `data/trimmed_mean/cpi_weights.xlsx` | National Statistics Office of Mongolia, 2023 CPI basket weights. The division weights in `exclusion/` (`w_off`) are copied from this file. | 2026-08-31 |

The Bank of Mongolia's inflation targets by year (used in `evaluation/`) are taken from its Monetary
Policy Guidelines, Inflation Reports, and public statements; sources are listed in the code comments
and in the thesis.

## Notes
- Random seeds are set wherever results depend on simulation (bootstrap, MCMC, simulated critical values).
- Real-time vintages re-estimate each model using only data available at each forecast date.
- `data/trimmed_mean/inflation-rate.xlsx` is read by `Kalman filtering/02_fit_local_level.Rmd`
  and is an active input, despite its folder.
- The GDP data are the NSO release of May 2026; update `gdp_file` in `SVAR/01_svar_data.Rmd`
  when newer data arrive.
- Archived files, not used by `run_all.R`: `data/trimmed_mean/avg_prices.xlsx` and the weekly
  Ulaanbaatar price file (inputs to an earlier trimmed-mean measure); `data/raw/unemp.xlsx` ([date]),
  `data/cleaned/`, and `output/tables/fevd_*.csv` (from an earlier GDP-unemployment SVAR).