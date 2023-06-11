# pylint: disable=invalid-name
import pandas as pd
import numpy as np
from rl_models import (
    batch_calc_log_likelihood_vola_dep,
    batch_calc_log_likelihood_vola_indep,
)


def char_to_num(char_vector, rule):
    """
    Convert a character vector to a numeric vector based on a given rule.

    Parameters:
    char_vector (pandas.Series): A Pandas Series containing the character vector to be converted.
    rule (dict): A dictionary containing the conversion rule, where the keys are the characters to be converted
                 and the values are the corresponding numeric values.

    Returns:
    pandas.Series: A new Pandas Series containing the converted numeric vector.
    """
    # create a copy of the input vector
    num_vector = char_vector.copy()

    # apply the conversion rule to each element of the vector
    for char, num in rule.items():
        num_vector[char_vector == char] = num

    # convert the resulting vector to numeric type
    num_vector = pd.to_numeric(num_vector)

    return num_vector


# import the data
raw_data = pd.read_csv(
    "/Volumes/XXK-DISK/project9_fmri_spatial_stroop/data/input/behavioral_data/all_data.csv"
)

# set the parameters
file_save_path = "/Volumes/XXK-DISK/project9_fmri_spatial_stroop/data/output/model_estimation/reinforcement_learning/single_sub"
sub_list = np.unique(raw_data["sub_num"])

# estimate the reinforcement learning model for each subject

# for sub in sub_list:
sub_num_i = 9
sub_data = raw_data[raw_data["sub_num"] == sub_num_i]

# select the vector which will used to estimate the model
stim_loc_vector = sub_data["stim_loc"]
stim_text_vector = sub_data["stim_text"]
corr_resp_vector = sub_data["corr_resp"]
congruency_vector = sub_data["congruency"]
volatility_vector = sub_data["volatile"]

# convert the charactor vector to numeric vector
stim_loc_vector = char_to_num(stim_loc_vector, {"top": 0, "bottom": 1})
stim_text_vector = char_to_num(stim_text_vector, {"shang": 0, "xia": 1})
corr_resp_vector = char_to_num(corr_resp_vector, {1: 0, 4: 1})
congruency_vector = char_to_num(congruency_vector, {"con": 0, "inc": 1})
volatility_vector = char_to_num(volatility_vector, {"s": 0, "v": 1})

# begin model estimation

input_data = pd.DataFrame(
    {
        "stim_loc": stim_loc_vector,
        "stim_text": stim_text_vector,
        "corr_resp": corr_resp_vector,
        "congruency": congruency_vector,
        "volatility": volatility_vector,
    }
)

model_name = "rl_sr_vola_dep"
rl_sr_vola_dep_result = batch_calc_log_likelihood_vola_dep(
    model_name, input_data
)
rl_sr_vola_dep_result.to_csv(
    file_save_path + "/sub_" + str(sub_num_i) + "_" + ".csv",
    index=False,
)

model_name = "rl_ab_vola_dep"
rl_ab_vola_dep_result = batch_calc_log_likelihood_vola_dep(
    model_name, input_data
)
rl_ab_vola_dep_result.to_csv(
    file_save_path + "/sub_" + str(sub_num_i) + "_" + ".csv",
    index=False,
)

model_name = "rl_sr_vola_indep"
rl_sr_vola_indep_result = batch_calc_log_likelihood_vola_indep(
    model_name, input_data
)
rl_sr_vola_indep_result.to_csv(
    file_save_path + "/sub_" + str(sub_num_i) + "_" + model_name + ".csv", index=False
)

model_name = "rl_ab_vola_indep"
rl_ab_vola_indep_result = batch_calc_log_likelihood_vola_indep(
    model_name, input_data
)
rl_ab_vola_indep_result.to_csv(
    file_save_path + "/sub_" + str(sub_num_i) + "_" + model_name + ".csv", index=False
)
