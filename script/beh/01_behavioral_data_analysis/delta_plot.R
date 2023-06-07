all_data_without_outlier

total_result_list <- array(0, dim = c(3,4,length(unique(all_data_without_outlier$sub_num))))
for (i in unique(all_data_without_outlier$sub_num)){
    print(paste0("============ Begin to process the data of one subject ", i, " ============"))
    foo <- all_data_without_outlier %>%
        filter(sub_num == i) %>%
        select(stim_resp.rt, congruency, prop, volatile, trial, sub_num) %>%
        pivot_wider(names_from = c(prop, congruency, volatile), values_from = stim_resp.rt)
    S_MC_inc_data <- sort(na.omit(foo$MC_inc_s))
    S_MI_inc_data <- sort(na.omit(foo$MI_inc_s))
    S_MC_con_data <- sort(na.omit(foo$MC_con_s))
    S_MC_inc_data <- sort(na.omit(foo$MC_inc_s))
    V_MC_inc_data <- sort(na.omit(foo$MC_inc_v))
    V_MI_inc_data <- sort(na.omit(foo$MI_inc_v))
    V_MC_con_data <- sort(na.omit(foo$MC_con_v))
    V_MC_inc_data <- sort(na.omit(foo$MC_inc_v))

    quantile_S_MC_inc <- quantile(S_MC_inc_data, probs = c(1,2,3)/3)
    quantile_S_MI_inc <- quantile(S_MI_inc_data, probs = c(1,2,3)/3)
    quantile_S_MC_con <- quantile(S_MC_con_data, probs = c(1,2,3)/3)
    quantile_S_MC_inc <- quantile(S_MC_inc_data, probs = c(1,2,3)/3)
    quantile_V_MC_inc <- quantile(V_MC_inc_data, probs = c(1,2,3)/3)
    quantile_V_MI_inc <- quantile(V_MI_inc_data, probs = c(1,2,3)/3)
    quantile_V_MC_con <- quantile(V_MC_con_data, probs = c(1,2,3)/3)
    quantile_V_MC_inc <- quantile(V_MC_inc_data, probs = c(1,2,3)/3)

    simon_S_MC <- c(mean(S_MC_inc_data[S_MC_inc_data <= quantile_S_MC_inc[1]]) - 
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[1]]),
                    mean(S_MC_inc_data[S_MC_inc_data <= quantile_S_MC_inc[2] & S_MC_inc_data > quantile_S_MC_inc[1]]) - 
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[2] & S_MC_con_data > quantile_S_MC_con[1]]),
                    mean(S_MC_inc_data[S_MC_inc_data <= quantile_S_MC_inc[3] & S_MC_inc_data > quantile_S_MC_inc[2]]) -
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[3] & S_MC_con_data > quantile_S_MC_con[2]]))
    simon_S_MI <- c(mean(S_MI_inc_data[S_MI_inc_data <= quantile_S_MI_inc[1]]) -
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[1]]),
                    mean(S_MI_inc_data[S_MI_inc_data <= quantile_S_MI_inc[2] & S_MI_inc_data > quantile_S_MI_inc[1]]) -
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[2] & S_MC_con_data > quantile_S_MC_con[1]]),
                    mean(S_MI_inc_data[S_MI_inc_data <= quantile_S_MI_inc[3] & S_MI_inc_data > quantile_S_MI_inc[2]]) -
                        mean(S_MC_con_data[S_MC_con_data <= quantile_S_MC_con[3] & S_MC_con_data > quantile_S_MC_con[2]]))
    simon_V_MC <- c(mean(V_MC_inc_data[V_MC_inc_data <= quantile_V_MC_inc[1]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[1]]),
                    mean(V_MC_inc_data[V_MC_inc_data <= quantile_V_MC_inc[2] & V_MC_inc_data > quantile_V_MC_inc[1]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[2] & V_MC_con_data > quantile_V_MC_con[1]]),
                    mean(V_MC_inc_data[V_MC_inc_data <= quantile_V_MC_inc[3] & V_MC_inc_data > quantile_V_MC_inc[2]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[3] & V_MC_con_data > quantile_V_MC_con[2]]))
    simon_V_MI <- c(mean(V_MI_inc_data[V_MI_inc_data <= quantile_V_MI_inc[1]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[1]]),
                    mean(V_MI_inc_data[V_MI_inc_data <= quantile_V_MI_inc[2] & V_MI_inc_data > quantile_V_MI_inc[1]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[2] & V_MC_con_data > quantile_V_MC_con[1]]),
                    mean(V_MI_inc_data[V_MI_inc_data <= quantile_V_MI_inc[3] & V_MI_inc_data > quantile_V_MI_inc[2]]) -
                        mean(V_MC_con_data[V_MC_con_data <= quantile_V_MC_con[3] & V_MC_con_data > quantile_V_MC_con[2]]))
    single_sub_matrix <- cbind(simon_S_MC, simon_S_MI, simon_V_MC, simon_V_MI)
    total_result_list[, , i] <- single_sub_matrix
}

delta_table <- apply(total_result_list, 1:2, mean)
colnames(delta_table) <- c("S_MC", "S_MI", "V_MC", "V_MI")
delta_table <- cbind(delta_table, part = 1:3)
delta_plot <- delta_table %>%
    as_tibble() %>%
    pivot_longer(cols = c("S_MC", "S_MI", "V_MC", "V_MI"), 
                 names_to = "condition", 
                 values_to = "Simon_effect") %>%
    separate(condition, c("volatile", "prop"), sep = "_") %>%
    ggplot(aes(x = part, y = Simon_effect, color = prop)) +
    facet_grid(. ~ volatile) +
    geom_point() +
    geom_line()
