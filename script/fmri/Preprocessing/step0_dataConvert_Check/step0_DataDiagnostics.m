function [td, globals, slicediff, imgs] = tsdiffana(imgs, vf, fg, pflags)
% wrapper and plotter for timediff function
% 
% imgs    - string list of images
% vf      - non zero if difference images required
% fg      - figure to plot results (spm figure default)
% pflags  - plot flags - 0 or more of 'r'  - plot realignment params

clear, clc
global defaults; spm_defaults;

homefolder = '/Data/Xiaxk/project3_Volatality_to_PC/fmri_analysis/';
resultsdir = '/Data/Xiaxk/project3_Volatality_to_PC/fmri_analysis/data/Results/DataDiagnostics/';
project = 'SPL';

datapath        = [homefolder filesep 'data' filesep ];  % Root-directory
paths           = {'Orig'};
runs            = {'session1', 'session2', 'session3', 'session4', 'session5', 'session6'};
subjects        = {'sub1';'sub2';'sub3';'sub4';'sub5';'sub6';'sub7';'sub8';'sub9';'sub10';'sub11';'sub12';'sub13';'sub14';'sub15';'sub16';'sub17';'sub18';'sub19';'sub20';'sub21';'sub22';'sub23';'sub24';'sub25';'sub26';'sub27';'sub28';'sub29';'sub30';'sub31';'sub32';'sub33';'sub34';'sub35';'sub36'};

for nsub=1:length(subjects)
     for np=1:length(paths)
        for nrun=1:length(runs)
            
            [imgs, Dirs] = spm_select('FPList',[datapath subjects{nsub} filesep paths{np} filesep runs{nrun}],'^f.*\.nii$');
            
            vf = 0; noplot = 0;fg = []; pflags = '';
            
            [p f e] = fileparts(imgs(1,:));
            if vf
                flags = 'mv';
            else
                flags = 'm';
            end
            
            [td globals slicediff] = timediff(imgs,flags);
            tdfn = fullfile(p,'timediff.mat');
            save(tdfn, 'imgs', 'td', 'globals', 'slicediff');
            
            tsdiffplot(tdfn,fg, pflags);
            ling_spm_print([subjects{nsub} '_DataAiagnostics_' project]);
            
        end;
    end;
    
    movefile([subjects{nsub} '_DataAiagnostics_' project '.ps'], resultsdir, 'f');
    
end;

fprintf(1, 'Done\n');


