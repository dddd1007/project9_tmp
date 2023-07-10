library(cmdstanr)
library(tidyverse)
library(here)

read_loc <- here("data", "output", "model_estimation", "bayesian_learner", "single_sub")
save_loc <- here("data", "output", "model_estimation", "bayesian_learner", "single_sub")
sub_data <- read.csv(here("data", "input", "behavioral_data", "all_data.csv"))

for (single_sub_num in unique(sub_data$sub_num)) {
    ######### SR ############
    print(paste0("====== Extract SR data from subject ", single_sub_num, " ======"))
    # 读取单个被试的数据
    csv_files <- dir(paste0(read_loc, "/sr/sub_", single_sub_num),
        pattern = ".csv", full.names = TRUE
    )
    single_sub_data <- filter(sub_data, sub_num == single_sub_num)
    stan_data_list <- list()
    for (i in seq_len(length(csv_files))) {
        stan_data_list[[i]] <- read_csv(csv_files[i],
            comment = "#",
            num_threads = readr_threads()
        )
    }

    stan_data <- bind_rows(stan_data_list, .id = "column_label")

    # 分条件将数据读取并求均值

    # r_l 指刺激物空间位置在左侧时，右手按键的概率
    rlr_data <- select(stan_data, starts_with("r_l"))
    rlr_mean <- apply(rlr_data, 2, mean)
    rlr_mean <- c(0.5, rlr_mean) # stan 的估计结果为当前试次更新后的, 因此需要向后推一个试次
    rll_mean <- 1 - rlr_mean

    # r_r 指刺激物空间位置在右侧时，右手按键的概率
    rrr_data <- select(stan_data, starts_with("r_r"))
    rrr_mean <- apply(rrr_data, 2, mean)
    rrr_mean <- c(0.5, rrr_mean)
    rrl_mean <- 1 - rrr_mean

    # 获取 v 的列表
    v_data <- select(stan_data, starts_with("v"))
    v_mean <- apply(v_data, 2, mean)

    # 根据被试应当正确的行为选出对应的 r

    r_selected <- vector(mode = "numeric", length = nrow(single_sub_data))
    for (i in seq_len(nrow(single_sub_data))) {
        tmp <- single_sub_data[i, ]
        if (tmp$stim_loc == "top" && tmp$corr_resp_num == 0) {
            r_selected[i] <- rll_mean[i]
        } else if (tmp$stim_loc == "top" && tmp$corr_resp_num == 1) {
            r_selected[i] <- rlr_mean[i]
        } else if (tmp$stim_loc == "bottom" && tmp$corr_resp_num == 0) {
            r_selected[i] <- rrl_mean[i]
        } else if (tmp$stim_loc == "bottom" && tmp$corr_resp_num == 1) {
            r_selected[i] <- rrr_mean[i]
        }
    }
    #####
    result <- data.frame(
        ll = rll_mean[1:(length(rll_mean) - 1)],
        lr = rlr_mean[1:(length(rlr_mean) - 1)],
        rl = rrl_mean[1:(length(rrl_mean) - 1)],
        rr = rrr_mean[1:(length(rrr_mean) - 1)],
        v = v_mean, r_selected = r_selected
    )
    result_filename <- paste0(save_loc, "/sr/extracted_data/sub_", single_sub_num, "_sr_learner.csv")
    write_csv(result, result_filename)

    ########## AB ############
    print(paste0("====== Extract AB data from subject ", single_sub_num, " ======"))
    # 读取单个被试的数据
    csv_files <- dir(paste0(read_loc, "/ab/sub_", single_sub_num),
        pattern = ".csv", full.names = TRUE
    )
    single_sub_data <- filter(sub_data, sub_num == single_sub_num)
    stan_data_list <- list()
    for (i in seq_len(length(csv_files))) {
        stan_data_list[[i]] <- read_csv(csv_files[i],
            comment = "#",
            num_threads = readr_threads()
        )
    }
    stan_data <- bind_rows(stan_data_list, .id = "column_label")
    r_con_data <- select(stan_data, starts_with("r"))
    r_con_mean <- apply(r_con_data, 2, mean)
    r_inc_mean <- 1 - r_con_mean
    # con/inc 向量实际上为更新后的数值, 代表对下个试次的估计, 故应在前补 0.5
    r_con_mean <- c(0.5, r_con_mean)
    r_inc_mean <- c(0.5, r_inc_mean)

    v_data <- select(stan_data, starts_with("v"))
    v_mean <- apply(v_data, 2, mean)

    # 根据被试的行为选出对应的 r

    r_selected <- vector(mode = "numeric", length = nrow(single_sub_data))
    for (i in seq_len(nrow(single_sub_data))) {
        tmp <- single_sub_data[i, ]
        if (tmp$congruency == "con") {
            r_selected[i] <- r_con_mean[i]
        } else if (tmp$congruency == "inc") {
            r_selected[i] <- r_inc_mean[i]
        }
    }

    result <- data.frame(
        r_con = r_con_mean[1:(length(r_con_mean) - 1)],
        r_inc = r_inc_mean[1:(length(r_con_mean) - 1)],
        v = v_mean, r_selected = r_selected
    )
    result_filename <- paste0(save_loc, "/ab/extracted_data/sub_", single_sub_num, "_ab_learner.csv")
    print(paste0("Save data to ", result_filename))
    write_csv(result, result_filename)
}
