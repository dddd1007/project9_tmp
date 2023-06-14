import pandas as pd
import numpy as np

model_names = [
    "rl_sr_vola_dep",
    "rl_ab_vola_dep",
    "rl_sr_vola_indep",
    "rl_ab_vola_indep",
]
raw_data = pd.read_csv(
    "/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/input/behavioral_data/all_data.csv"
)
file_read_path = "/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/model_estimation/reinforcement_learning/single_sub"
file_save_path = "/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/model_estimation/reinforcement_learning/optim_params"
sub_list = np.unique(raw_data["sub_num"])

for model_name_i in model_names:
    model_result_df = pd.DataFrame()
    for sub_num_i in sub_list:
        sub_i_data = pd.read_csv(
            file_read_path + "/sub_" + str(sub_num_i) + "_" + model_name_i + ".csv"
        )
        max_llf_index = sub_i_data["llf"].idxmax()
        max_llf_row = sub_i_data.loc[max_llf_index]
        max_llf_row["sub_num"] = sub_num_i
        model_result_df = pd.concat([model_result_df, max_llf_row], axis=1)
    result_df = model_result_df.T.reset_index(drop=True)
    result_df.to_csv(file_save_path + "/" + model_name_i + ".csv", index=False)
