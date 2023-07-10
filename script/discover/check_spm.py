## 导入必要的包和函数
import pandas as pd
import numpy as np

sys.path.append('/Users/dddd1007/.local/lib/python3.10/site-packages/xia_fmri_workflow')
from check_spmDotMat import read_spm

# 检查单被试的数据正确性
# 读取数据
spm_data = read_spm("/Volumes/Research Data/project9_fmri_spatial_stroop/data/output/fmri/condGLM/reverse_control/1stLevel/sub10/SPM.mat")
spm_data = spm_data['SPM'][0]
