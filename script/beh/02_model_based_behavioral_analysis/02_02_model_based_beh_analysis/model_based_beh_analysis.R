library(tidyverse)
library(here)

# 0. 读取包含模型估计参数的数据

paramed_data <- read_csv(here("data", "input", "all_data_with_params.csv"))
head(paramed_data)

# 1. 查看模型在不同条件下的估计参数

# volatile in BL
paramed_data %>%
    group_by(volatile) %>%
    summarise(mean = mean(bl_sr_v))

# Alpha in RL
rl_params <- read.csv("/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning/optim_para_sr_v.csv")
rl_params %>%
    summarise(alpha_s = mean(alpha_s), alpha_v = mean(alpha_v))

# 2. 比较不同模型在预测行为上的性能

formula_bl_sr <- "stim_resp.rt ~ 1 + bl_sr_PE + congruency_num + corr_resp_num + run + block"
formula_bl_ab <- "stim_resp.rt ~ 1 + bl_ab_PE + congruency_num + corr_resp_num + run + block"
formula_rl_sr <- "stim_resp.rt ~ 1 + rl_sr_v_pe + congruency_num + corr_resp_num + run + block"
formula_rl_ab <- "stim_resp.rt ~ 1 + rl_ab_v_pe + congruency_num + corr_resp_num + run + block"

subject_count <- length(unique(paramed_data$sub_num))

aic_array <- array(NA, dim = c(subject_count, 5))
bic_array <- array(NA, dim = c(subject_count, 5))
loglik_array <- array(NA, dim = c(subject_count, 5))
count_num <- 1

for (i in unique(paramed_data$sub_num)) {
  single_sub_data <- paramed_data %>%
    filter(sub_num == i)

  # evaluate models
  bl_sr_model <- lm(formula_bl_sr, data = single_sub_data)
  bl_ab_model <- lm(formula_bl_ab, data = single_sub_data)
  rl_sr_model <- lm(formula_rl_sr, data = single_sub_data)
  rl_ab_model <- lm(formula_rl_ab, data = single_sub_data)

  # save aic, bic, loglik
  aic_array[count_num, ] <- c(AIC(bl_sr_model), AIC(bl_ab_model), AIC(rl_sr_model), AIC(rl_ab_model), i)
  bic_array[count_num, ] <- c(BIC(bl_sr_model), BIC(bl_ab_model), BIC(rl_sr_model), BIC(rl_ab_model), i)
  loglik_array[count_num, ] <- c(logLik(bl_sr_model), logLik(bl_ab_model), logLik(rl_sr_model), logLik(rl_ab_model), i)

  count_num <- count_num + 1
}

# Add column names
aic_result <- as.data.frame(aic_array)
bic_result <- as.data.frame(bic_array)
loglik_result <- as.data.frame(loglik_array)
colnames(aic_result) <- c("bl_sr", "bl_ab", "rl_sr", "rl_ab", "sub_num")
colnames(bic_result) <- c("bl_sr", "bl_ab", "rl_sr", "rl_ab", "sub_num")
colnames(loglik_result) <- c("bl_sr", "bl_ab", "rl_sr", "rl_ab", "sub_num")

# 查看不同模型的 AIC, BIC, loglik 的差异
mean_aic <- aic_result %>%
  apply(., 2, mean)
mean_bic <- bic_result %>%
  apply(., 2, mean)
mean_loglik <- loglik_result %>%
  apply(., 2, mean)

