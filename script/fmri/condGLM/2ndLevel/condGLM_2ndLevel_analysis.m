% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/Users/dddd1007/Library/CloudStorage/Dropbox/Work/博士工作/研究数据/Project4_EEG_Vollatility_to_Control/script/fmri/condGLM/2ndLevel/condGLM_2ndLevel_analysis.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
