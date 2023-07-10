rm(list = ls())
library(tidyverse)
#--- Build a basic function to extract each file
extract_data <- function(file) {
    raw_data <- read.csv(file)
    foo <- raw_data %>%
        dplyr::filter(is.na(practice_trials.thisN)) %>%
        dplyr::select(
            sub_num, run, block, volatile, prop, congruency, stim_image_loc, corr_resp, stim_resp.rt,
            stim_resp.corr, one_key_resp.started, one_key_resp.rt, stim_image.started, group
        ) %>%
        dplyr::filter(!is.na(corr_resp)) %>%
        dplyr::mutate(run_begin_time = one_key_resp.started + one_key_resp.rt)

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

    add_onset_list <- list()
    for (run_num in 1:6) {
        tmp_table <- filter(foo, run == run_num)
        tmp_table$run_begin_time[2:nrow(tmp_table)] <- tmp_table$run_begin_time[1]
        add_onset_list[[run_num]] <- mutate(tmp_table, onset = ((stim_image.started - run_begin_time) / 1.5))
    }
    foo <- bind_rows(add_onset_list, .id = "run_num")

    filterd_data <- foo %>%
        dplyr::filter(!is.na(congruency), !is.na(corr_resp))

    filterd_data$stim <- str_extract(filterd_data$stim_image_loc, "[bt]o.*") %>% str_remove(".png")
    return(cbind(filterd_data,
        trial = seq_len(nrow(filterd_data))
    ))
}

#--- Import packages and file list
library(here)
library(writexl)
file_list <- list.files("/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/behavioral_data/single_sub_data",
    pattern = ".*.csv", full.names = TRUE
)

#--- Extract each csv file
all_data_list <- list()
count_num <- 1
for (i in file_list) {
    print(i)
    tmp_table <- extract_data(i)
    if (tmp_table$sub_num[1] <= 17 | tmp_table$sub_num[1] >= 35) {
        tmp_table$rule <- "TR-LL"
    } else {
        tmp_table$rule <- "TL-LR"
    }
    all_data_list[[count_num]] <- tmp_table
    count_num <- count_num + 1
}

all_data <- bind_rows(all_data_list) %>%
    select(!stim_image_loc) %>%
    tidyr::separate(stim, c("stim_loc", "stim_text"), "-")

write_xlsx(all_data, "/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.xlsx")
write_csv(all_data, "/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv")
