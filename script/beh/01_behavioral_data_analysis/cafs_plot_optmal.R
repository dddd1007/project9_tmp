library(here)
library(tidyverse)

all_data <- here("data", "input", "all_data_with_params.csv") %>%
  read_csv()

bin_num <- 3

cafs_data <- all_data %>%
  group_by(sub_num, prop, volatile, congruency) %>%
  pmap(function(sub_num, prop, volatile, congruency) {
    single_sub_data <- filter(
      all_data,
      sub_num == !!sub_num,
      prop == !!prop,
      volatile == !!volatile,
      congruency == !!congruency
    ) %>%
      select(sub_num:stim_resp.corr) %>%
      arrange(stim_resp.rt) %>%
      na.omit()
    single_cafs <- single_sub_data %>%
      mutate(part = cut_interval(stim_resp.rt,
                                  n = bin_num,
                                  closed = "right")) %>%
      group_by(part) %>%
      summarise(across(c(stim_resp.corr, stim_resp.rt), mean, na.rm = TRUE), .names = "{col}_mean") %>%
      ungroup()
    cbind(single_cafs,
          prop = prop,
          volatile = volatile,
          congruency = congruency,
          sub_num = sub_num)
  }) %>%
  bind_rows(.id = "column_label")

cafs_plot <- cafs_data %>%
  group_by(prop, volatile, part, congruency) %>%
  summarise(across(c(Accuracy_mean, stim_resp.rt_mean), mean)) %>%
  ggplot(aes(x = stim_resp.rt_mean, y = Accuracy_mean, color = congruency)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(prop ~ volatile)

cafs_plot
