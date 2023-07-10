% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/Users/dddd1007/Library/CloudStorage/Dropbox/Work/phd work/research/project9_fmri_spatial_stroopscript/fmri/condGLM/condGLM_2ndLevel_TopLeft_analysis_job.m',
           '/Users/dddd1007/Library/CloudStorage/Dropbox/Work/phd work/research/project9_fmri_spatial_stroopscript/fmri/condGLM/condGLM_2ndLevel_TopRight_analysis_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
