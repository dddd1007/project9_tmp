#####
##### 常规数据处理 ( 41 被试需要单独处理 ) ######
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
##### 被试 41 的单独处理
#####
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0003.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0003.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1
    2
    2];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = {
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub9/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0004.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0004.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [2
    1
    1];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = {
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub9/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0005.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0005.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2
    1
    2];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = {
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub9/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0006.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0006.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [2
    2
    1];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(7).scans = {
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub9/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0007.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0007.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2
    2
    2];
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(8).scans = {
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub9/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub11/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub12/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub13/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub14/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub15/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub16/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub17/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub18/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub19/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub20/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub21/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub22/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub23/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub24/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub25/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub26/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub27/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub28/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub29/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub30/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub31/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub32/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub33/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub34/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub35/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub36/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub37/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub38/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub40/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub41/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub42/con_0008.nii,1'
    '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/data/output/fmri/condGLM/reverse_control/1stLevel/sub43/con_0008.nii,1'
    };
%%
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
