library(tidyverse)
library(here)

#--- Build a basic function to extract each file
extract_data <- function(file){
    raw_data <- read.csv(file)
    foo <- raw_data %>%
        dplyr::filter(is.na(practice_trials.thisN)) %>%
        dplyr::select(corr_resp, congruency, stim_resp.corr, stim_resp.rt, prop, volatile, sub_num) %>%
        dplyr::filter(!is.na(corr_resp))

    replace_list <- c()
    for (i in seq_len(nrow(foo))) {
        if (is.na(foo[i, "prop"])) {
            replace_list <- c(replace_list, i)
        } else {
            foo[replace_list, "prop"] <- foo$prop[i]
            replace_list <- c()
        }
    }
    replace_list <- c()
    for (i in seq_len(nrow(foo))) {
        if (is.na(foo[i, "volatile"])) {
            replace_list <- c(replace_list, i)
        } else {
            foo[replace_list, "volatile"] <- foo$volatile[i]
            replace_list <- c()
        }
    }
    filterd_data <- foo %>%
        dplyr::filter(!is.na(congruency), !is.na(corr_resp))
    return(cbind(filterd_data,
                 trial = 1:960,
                 run_num = sort(rep(1:6, 160))))
}

#--- Import file list
file_list <- list.files(here("data", "input", "behavioral_data"), pattern = ".*.csv", full.names = TRUE)

#--- Extract each csv file
all_data_list <- list()
count_num <- 1
for (i in file_list) {
    print(i)
    tmp_table <- extract_data(i)
    all_data_list[[count_num]] <- cbind(tmp_table)
    count_num <- count_num + 1
}
all_data <- bind_rows(all_data_list, .id = "column_label") %>%
    rename(rt = stim_resp.rt, corr = stim_resp.corr)
