library(tidyverse)
library(here)
data_loc <- here("data","output","model_estimation","bayesian_learner")
sub_data <- read.csv(here("data","input","behavioral_data","all_data.csv"))

sub_num_list <- sort(unique(sub_data$sub_num))

## AB
data_loc_ab <- paste0(data_loc, "/single_sub/ab/extracted_data/")
all_ab_data_list <- list()
count_num <- 1
for (i in sub_num_list) {
    data_file <- read.csv(paste0(data_loc_ab, "sub_", i, "_ab_learner.csv"))
    all_ab_data_list[[count_num]] <- cbind(sub_num = i, data_file)
    count_num <- count_num + 1
}

all_ab_data_result <- bind_rows(all_ab_data_list, .id = "column_label")
all_ab_data_result <- mutate(all_ab_data_result, PE = 1 - r_selected)
colnames(all_ab_data_result) <- paste("ab", colnames(all_ab_data_result), sep = "_")

## SR
data_loc_sr <- paste0(data_loc, "/single_sub/sr/extracted_data/")
all_sr_data_list <- list()
count_num <- 1
for (i in sub_num_list) {
    data_file <- read.csv(paste0(data_loc_sr, "sub_", i, "_sr_learner.csv"))
    all_sr_data_list[[count_num]] <- cbind(sub_num = i, data_file)
    count_num <- count_num + 1
}

all_sr_data_result <- bind_rows(all_sr_data_list, .id = "column_label")
all_sr_data_result <- mutate(all_sr_data_result, PE = 1 - r_selected)
colnames(all_sr_data_result) <- paste("sr", colnames(all_sr_data_result), sep = "_")

## combine two data sets
all_bl_data <- cbind(all_ab_data_result, all_sr_data_result)
write.csv(all_bl_data, here("data","output","model_estimation","bayesian_learner","all_bl_data.csv"))