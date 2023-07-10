% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/fmri_data/sub17/contrast.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
