% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub1_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub2_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub3_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub4_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub5_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub6_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub7_job.m',
    '/Users/dddd1007/research/project9_fmri_spatial_stroop/script/fmri/condGLM/single_sub/condGLM_1stLevel_contrast_sub8_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
