% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub35_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub36_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub37_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub38_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub40_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub41_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub42_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub43_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
