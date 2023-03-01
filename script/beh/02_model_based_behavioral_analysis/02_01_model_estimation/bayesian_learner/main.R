library(cmdstanr)
library(posterior)
library(bayesplot)
library(tidyverse)

check_cmdstan_toolchain()

ab_stanfile <- "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/script/beh/02_model_based_behavioral_analysis/02_01_model_estimation/bayesian_learner/stan_src/bayesian_learner_ab.stan"
sr_stanfile <- "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/script/beh/02_model_based_behavioral_analysis/02_01_model_estimation/bayesian_learner/stan_src/bayesian_learner_sr_1k1v_neg_v.stan"

ab_learner <- cmdstan_model(ab_stanfile)
sr_learner <- cmdstan_model(sr_stanfile)

output_dir_ab <- "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/bayesian_learner/single_sub/ab/"
output_dir_sr <- "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/bayesian_learner/single_sub/sr/"

##### Estimate Model

# Load data
raw_data <- read.csv("/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv")

# Estimate each sub
sub_num_list <- unique(raw_data$sub_num)

for (i in sub_num_list) {
  single_sub_table <- filter(raw_data, sub_num == i)

  N <- nrow(single_sub_table)
  
  # model1 ab
  y            <- single_sub_table$congruency_num
  data_list_ab <- list(N = N, y = y)

  file_save_path_ab <- paste0(output_dir_ab, "sub_", as.character(i))
  dir.create(file_save_path_ab)
  fit1 <- ab_learner$sample(
    data = data_list_ab,
    chains = 4,
    parallel_chains = 4,
    refresh = 500,
    output_dir = file_save_path_ab
  )

  # model2 sr
  corr_react    <- single_sub_table$corr_resp_num
  space_loc     <- single_sub_table$stim_loc_num
  data_list_sr  <- list(N = N, corr_react = corr_react, space_loc = space_loc)

  file_save_path_sr <- paste0(output_dir_sr, "sub_", as.character(i))
  dir.create(file_save_path_sr)
  fit2 <- sr_learner$sample(
    data = data_list_sr,
    chains = 4,
    parallel_chains = 4,
    refresh = 500,
    output_dir = file_save_path_sr
  )
}
