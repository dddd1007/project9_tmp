library(here)
library(tidyverse)
all_data <- here("data", "input", "all_data_with_params.csv") %>%
    read_csv()

bin_num <- 3

result_list <- list()
count_num <- 1
for (i in unique(all_data$sub_num)) {
    for (prop_i in c("MC", "MI")) {
        for (volatile_i in c("s", "v")) {
          for (congruency_i in c("con", "inc")) {
            single_sub_data <- filter(
              all_data,
              sub_num == i,
              prop == prop_i,
              volatile == volatile_i,
              congruency == congruency_i
            ) %>%
              select(sub_num:stim_resp.corr) %>%
              arrange(stim_resp.rt) %>%
              na.omit()
            single_cafs <- single_sub_data %>%
              mutate(part = cut(stim_resp.rt,
                breaks = bin_num,
                labels = 1:bin_num
              )) %>%
              group_by(part) %>%
              summarise(
                Accuracy = mean(stim_resp.corr, na.rm = TRUE),
                mean_RT = mean(stim_resp.rt, na.rm = TRUE)
              ) %>%
              ungroup()
            result_list[[count_num]] <- cbind(single_cafs,
              prop = prop_i,
              volatile = volatile_i,
              congruency = congruency_i,
              sub_num = i
            )
            count_num <- count_num + 1
          }
        }
    }
}

cafs_data <- bind_rows(result_list, .id = "column_label")
cafs_plot <- cafs_data %>%
    group_by(prop, volatile, part, congruency) %>%
    summarise(Accuracy = mean(Accuracy),
              mean_rt  = mean(mean_RT)) %>%
    ggplot(aes(x = mean_rt, y = Accuracy, color = congruency)) +
        geom_point() +
        geom_line() +
        facet_wrap(prop ~ volatile)
cafs_plot
