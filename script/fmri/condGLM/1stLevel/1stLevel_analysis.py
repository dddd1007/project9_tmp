#####
##### 常规数据处理 ( 41被试需要单独处理 ) ######
#####

# 配置基本环境
import os
import re
import xia_fmri_workflow
from pathlib import Path
import pandas as pd
import scipy.io
from joblib import Parallel, delayed
import multiprocessing
num_cores = 6

# 读取被试数据
all_data = pd.read_csv("/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/input/all_data_with_params.csv")
all_data['PC_factor'] = all_data[['volatile', 'prop', 'congruency']].apply(lambda row: '_'.join(row.astype(str)), axis=1)

# 被试基本信息
sub_num_list = pd.unique(all_data['sub_num'])
sub_num_list = sub_num_list[sub_num_list != 41]
session_num = 6

# 数据位置
root_dir = "/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/input/fmri_data/nii"
output_dir = "/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/"

##
## PC effect
##

for sub_num in sub_num_list:
    estimate_result = xia_fmri_workflow.workflow_condition_glm_1stlevel(root_dir, sub_num, session_num, factors_name, all_data, output_dir)

##
## PE for Bayesian model
##
# Set the basic params
params_name = ['congruency_num', 'bl_sr_v', 'bl_sr_PE']
# make the contrast matrix
condition_names = ["run_1", "", "run_1xcongruency_num^1", "", "run_1xbl_sr_v^1", "",
                   "run_1xbl_sr_PE^1", "", "run_error_1", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_2", "", "run_2xcongruency_num^1", "", "run_2xbl_sr_v^1", "",
                   "run_2xbl_sr_PE^1", "", "run_error_2", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_3", "", "run_3xcongruency_num^1", "", "run_3xbl_sr_v^1", "",
                   "run_3xbl_sr_PE^1", "", "run_error_3", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_4", "", "run_4xcongruency_num^1", "", "run_4xbl_sr_v^1", "",
                   "run_4xbl_sr_PE^1", "", "run_error_4", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_5", "", "run_5xcongruency_num^1", "", "run_5xbl_sr_v^1", "",
                   "run_5xbl_sr_PE^1", "", "run_error_5", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_6", "", "run_6xcongruency_num^1", "", "run_6xbl_sr_v^1", "",
                   "run_6xbl_sr_PE^1", "", "run_error_6", "", "X", "Y", "Z", "x_r", "y_r", "z_r"]
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
# batch analysis
inputs = sub_num_list
def bl_processInput(sub_num):
    estimate_result = xia_fmri_workflow.workflow_param_glm_1stlevel(root_dir, sub_num, session_num, params_name, all_data, output_dir, "bl")
    contrast_result = xia_fmri_workflow.workflow_contrast(estimate_result, contrast_list)

results = Parallel(n_jobs=num_cores)(delayed(bl_processInpu)(sub_num) for sub_num in inputs)

##
## PE for reinforcement learning model
##

# Set the basic params
params_name = ['congruency_num', 'rl_sr_v_pe']
# make the contrast matrix
condition_names = ["run_1", "", "run_1xcongruency_num^1", "", "run_1xrl_sr_v_pe^1", "",
                   "run_error_1", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_2", "", "run_2xcongruency_num^1", "", "run_2xrl_sr_v_pe^1", "",
                   "run_error_2", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_3", "", "run_3xcongruency_num^1", "", "run_3xrl_sr_v_pe^1", "",
                   "run_error_3", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_4", "", "run_4xcongruency_num^1", "", "run_4xrl_sr_v_pe^1", "",
                   "run_error_4", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_5", "", "run_5xcongruency_num^1", "", "run_5xrl_sr_v_pe^1", "",
                   "run_error_5", "", "X", "Y", "Z", "x_r", "y_r", "z_r",
                   "run_6", "", "run_6xcongruency_num^1", "", "run_6xrl_sr_v_pe^1", "",
                   "run_error_6", "", "X", "Y", "Z", "x_r", "y_r", "z_r"]
cont1 = ["-V", 'T', condition_names,   [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
contrast_list = [cont1]

# batch analysis
sub_num_list = pd.unique(all_data['sub_num'])
inputs = sub_num_list[(sub_num_list >= 34) & (sub_num_list != 41)]
def rl_processInput(sub_num):
    estimate_result = xia_fmri_workflow.workflow_param_glm_1stlevel(root_dir, sub_num, session_num, params_name, all_data, output_dir, "rl")
    contrast_result = xia_fmri_workflow.workflow_contrast(estimate_result, contrast_list)

results = Parallel(n_jobs=num_cores)(delayed(rl_processInput)(sub_num) for sub_num in inputs)

#####
##### 被试41的单独处理
#####
