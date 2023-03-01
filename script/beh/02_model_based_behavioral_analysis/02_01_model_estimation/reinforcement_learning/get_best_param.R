library(tidyverse)
cate_list <- c("ab_no_v", "ab_v", "sr_no_v", "sr_v")
base_data_path = "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning/single_sub"
save_data_path = "/Users/dddd1007/ResearchData/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning"

for (cate_i in cate_list) {
    files_loc <- file.path(base_data_path, cate_i)
    files_list <- dir(files_loc, pattern = ".csv", full.names = TRUE)
    result_list <- list()
    count <- 1
    for (file_i in files_list) {
        sorted_single_sub_data <- read.csv(file_i) %>%
                                  arrange(desc(loglikelihood))
        result_list[[count]] <- sorted_single_sub_data[1,]
        count <- count + 1
    }
    result_table <- bind_rows(result_list, .id = "column_label") %>%
                    select(!column_label) %>%
                    arrange(sub_num) %>%
                    cbind(model_type = cate_i)
    file_path <- paste0(save_data_path, "/optim_para_", cate_i, ".csv")
    write.csv(result_table, file_path)
}
