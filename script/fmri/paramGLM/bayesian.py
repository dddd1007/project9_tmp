import os
from pathlib import Path
from nipype.interfaces.spm import Level1Design, EstimateModel, EstimateContrast
from nipype.algorithms.modelgen import SpecifySPMModel

# 设定基本参数
import pandas as pd
all_data = pd.read_csv("/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/input/all_data_with_params.csv")

# condition names
condition_names = ["run_1", "", "run_1xcongruency_num^1", "", "run_1xbl_sr_v^1", "", "run_1xbl_sr_PE^1", "", "run_error_1", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_2", "", "run_2xcongruency_num^1", "", "run_2xbl_sr_v^1", "", "run_2xbl_sr_PE^1", "", "run_error_2", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_3", "", "run_3xcongruency_num^1", "", "run_3xbl_sr_v^1", "", "run_3xbl_sr_PE^1", "", "run_error_3", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_4", "", "run_4xcongruency_num^1", "", "run_4xbl_sr_v^1", "", "run_4xbl_sr_PE^1", "", "run_error_4", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_5", "", "run_5xcongruency_num^1", "", "run_5xbl_sr_v^1", "", "run_5xbl_sr_PE^1", "", "run_error_5", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_6", "", "run_6xcongruency_num^1", "", "run_6xbl_sr_v^1", "", "run_6xbl_sr_PE^1", "", "run_error_6", "", "X", "Y", "Z", "x_r", "y_r", "z_r"]
cont1 = ["-V", 'T', condition_names,   [0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
cont2 = ["PE", 'T', condition_names,   [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
contrast_list = [cont1, cont2]
sub_num_list = pd.unique(all_data['sub_num'])
session_num = 6
params_name = ['congruency_num', 'bl_sr_v', 'bl_sr_PE'] # There must be a list

# Dirs
root_dir = '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/input/fmri_data/nii'
output_dir = '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/paramGLM/bl/1stLevel'

# Helper functions

def nii_selector(root_dir, sub_num, session_num, all_sub_dataframe, data_type="Smooth_8mm"):
    import os
    import glob
    session_list = ["session" + str(i)
                    for i in range(1, session_num+1)]
    sub_name = "sub"+str(sub_num)
    # print(file_path)
    nii_list = []
    realignment_para_file_list = []
    for s in session_list:
        file_path = os.path.join(root_dir, sub_name, data_type, s)
        Orig_path = os.path.join(root_dir, sub_name, 'Orig', s)
        nii_list.append(sorted(glob.glob(file_path + "/*.nii")))
        realignment_para_file_list.append(glob.glob(Orig_path + "/rp_*.txt"))

    single_sub_data = all_sub_dataframe[all_sub_dataframe.sub_num == sub_num]
    return (nii_list, realignment_para_file_list, single_sub_data, sub_name)

def head_movement_regressor_generator(single_realignment_para_file):
    import numpy as np
    if type(single_realignment_para_file) is list:
        single_realignment_para_file = single_realignment_para_file[0]
    relignment_params = np.loadtxt(single_realignment_para_file)
    head_movement_regressor = relignment_params.T.tolist()
    return head_movement_regressor

def parametric_condition_generator(single_sub_data, params_name, realignment_para_file_list ,duration=0, centering = True):
    from nipype.interfaces.base import Bunch
    import numpy as np
    run_num = set(single_sub_data.run)
    subject_info = []
    for i in run_num:
        tmp_table = single_sub_data[single_sub_data.run == i]

        tmp_table_right = tmp_table[tmp_table['stim_resp.corr'] == 1]
        tmp_table_wrong = tmp_table[tmp_table['stim_resp.corr'] != 1]

        pmod_names = []
        pmod_params = []
        pmod_poly = []
        for param in params_name:
            param_value = tmp_table_right[param].values.tolist()
            demean_value = param_value - np.mean(param_value)
            centered_value = demean_value / np.max(demean_value)
            if centering == True:
                # Doing the mean centering
                pmod_params.append(centered_value.tolist())
            elif centering == False:
                pmod_params.append(param_value)
            pmod_names.append(param)
            pmod_poly.append(1)

        error_onsets = tmp_table_wrong.onset.values.tolist()
        if len(error_onsets) == 0:
            error_onsets = [405]

        tmp_Bunch = Bunch(conditions=["run_"+str(i), "run_error_"+str(i)],
                          onsets=[tmp_table_right.onset.values.tolist(), error_onsets],
                          durations=[[duration], [duration]],
                          pmod=[Bunch(name=pmod_names, poly=pmod_poly, param=pmod_params), None],
                          regressor_names = ['X', 'Y', 'Z', 'x_r', 'y_r', 'z_r'],
                          regressors = head_movement_regressor_generator(realignment_para_file_list[i-1]))
        subject_info.append(tmp_Bunch)

    return subject_info

###
### Doing Analysis
###

for sub_num in sub_num_list:
    if sub_num < 34:
        continue
    print("===\n========= Subject number: " + str(sub_num) + " =========\n===")

    file_dir = os.path.join(output_dir, "sub" + str(sub_num))
    Path(file_dir).mkdir(parents=True, exist_ok=True)
    os.chdir(file_dir)

    print("=== Generating the model ===")
    nii_list, realignment_para_file_list, single_sub_data, sub_name = nii_selector(root_dir, sub_num, session_num, all_data)
    subject_info = parametric_condition_generator(single_sub_data, params_name, realignment_para_file_list, centering=False)
    gen_model = SpecifySPMModel(concatenate_runs=False,
                                input_units='scans',
                                output_units='scans',
                                time_repetition=2,
                                high_pass_filter_cutoff=128,
                                subject_info = subject_info,
                                functional_runs = nii_list)
    spmModel = gen_model.run()

    design_model = Level1Design(bases={'hrf': {'derivs': [1, 0]}},
                                timing_units='scans',
                                interscan_interval=2,
                                microtime_resolution=32,
                                microtime_onset=1,
                                session_info = spmModel.outputs.session_info,
                                spm_mat_dir = file_dir)

    firstLevelModel = design_model.run()

    print("=== Estimating the model ===")
    estimator = EstimateModel(estimation_method={'Classical': 1},
                                spm_mat_file = firstLevelModel.outputs.spm_mat_file)
    estimateResult = estimator.run()

    print("=== Making the contrasts ===")
    level1conest = EstimateContrast(beta_images = estimateResult.outputs.beta_images,
                                    residual_image = estimateResult.outputs.residual_image,
                                    spm_mat_file = estimateResult.outputs.spm_mat_file,
                                    contrasts = contrast_list)
    contrastResult = level1conest.run()
