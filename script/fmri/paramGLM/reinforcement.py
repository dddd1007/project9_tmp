# 配置基本环境
import xia_fmri_workflow
from pathlib import Path
import pandas as pd
from joblib import Parallel, delayed

# 读取被试数据
all_data = pd.read_csv("/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/all_data_with_params.csv")
# 被试基本信息
session_num = 6

# 数据位置
root_dir = "/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/fmri_data/nii"
output_dir = "/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/output/fmri/"

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
cont1 = ["PE", 'T', condition_names,   [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                        0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
contrast_list = [cont1]

# batch analysis
sub_num_list = all_data['sub_num'].unique()
inputs = sub_num_list[(sub_num_list != 41)]

def bl_processInput(sub_num):
    estimate_result = xia_fmri_workflow.workflow_param_glm_1stlevel(root_dir, sub_num, session_num, params_name, all_data, output_dir, "rl")
    contrast_result = xia_fmri_workflow.workflow_contrast(estimate_result, contrast_list)

results = Parallel(n_jobs=5)(delayed(bl_processInput)(sub_num) for sub_num in inputs)
