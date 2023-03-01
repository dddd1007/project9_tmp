clear, clc
global defaults; spm_get_defaults;
%spm('Defaults','FMRI');

homefolder = '/Users/dddd1007/Research/project9_fmri_spatial_stroop/data/input/fmri_data/nii';

datapath        = [homefolder filesep];  % Root-directory

paths           = {'Orig'; 'Normalised'; 'Smooth_8mm'};

subjects        = {'sub24','sub25','sub26','sub27','sub28'};

runs            = {'session1','session2','session3','session4','session5','session6'};
structurals     = {'3D'};
deleteDummies   = 4;

doDICOM =  0;

doDelete  = 1;
doRealign = 1;
doCoreg   = 1;
doNormalise = 1;
doWrite = 1;
doMove  = 1;
doSmooth =1;

for sub = 1:length(subjects)


    if doDICOM
        % ---------- DICOM conversion --------------------
        load SPM8_Parameters convert;
        jobs = convert;
        
        for ses =1:size(runs,2)
            jobs = convert;
            mkdir([datapath subjects{sub} filesep paths{1} filesep runs{ses}]);
            %[Files, Dirs] = spm_list_files([datapath subjects{sub} filesep 'DICOM' filesep runs{ses}],'*.*');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep 'DICOM' filesep runs{ses}],'^*.*\.*$');            
            Files = [repmat([datapath subjects{sub} filesep 'DICOM' filesep runs{ses} filesep],size(Files,1),1) Files];
            for file = 1:size(Files,1)
                jobs{1}.util{1}.dicom.data{file,1} = [Files(file,:)];
            end
            jobs{1}.util{1}.dicom.outdir = {[datapath subjects{sub} filesep paths{1} filesep runs{ses}]};

            spm_jobman('run',jobs)
        end

        mkdir([datapath subjects{sub} filesep structurals{1}]);
        [datapath subjects{sub} filesep 'DICOM' filesep structurals{1}]
        %[Files, Dirs] = spm_list_files([datapath subjects{sub} filesep 'DICOM' filesep structurals{1}],'*.*');
        [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep 'DICOM' filesep structurals{1}],'^*.*\.*$');
        Files = [repmat([datapath subjects{sub} filesep 'DICOM' filesep structurals{1} filesep],size(Files,1),1) Files];
        jobs{1}.util{1}.dicom.data = {};
        for file = 1:size(Files,1)
            jobs{1}.util{1}.dicom.data{file,1} = [Files(file,:)];
        end
        jobs{1}.util{1}.dicom.outdir = {[datapath subjects{sub} filesep structurals{1}]};
        spm_jobman('run',jobs)

    end


    if doDelete
        % ---------- Delete Dummys --------------------
        for ses =1:size(runs,2)
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{1} filesep runs{ses}],'f*.img');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{1} filesep runs{ses}],'^f.*\.nii$');
            Files = [repmat([datapath subjects{sub} filesep paths{1} filesep runs{ses} filesep],size(Files,1),1) Files];
            for ex = 1:deleteDummies
                delete(Files(ex,:))
                %delete([Files(ex,1:end-3) 'hdr'])
            end
        end
    end


    if doRealign
        % ---------- Realign --------------------
        load SPM8_Parameters realign;
        jobs = realign;
        
        jobs{1}.spatial{1}.realign{1}.estwrite.data = {};

        for ses =1:size(runs,2)
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{1} filesep runs{ses}],'f*.img');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{1} filesep runs{ses}],'^f.*\.nii$');
            Files = [repmat([datapath subjects{sub} filesep paths{1} filesep runs{ses} filesep],size(Files,1),1) Files];
            for file = 1:size(Files,1)
                jobs{1}.spatial{1}.realign{1}.estwrite.data{ses}{file,1} = [Files(file,:) ',1'];
            end
        end

        spm_jobman('run',jobs);

        mEPI = dir([datapath subjects{sub} filesep paths{1} filesep runs{1} filesep 'mean*.nii']);
        movefile([datapath subjects{sub} filesep paths{1} filesep runs{1} filesep mEPI.name],...
            [datapath subjects{sub} filesep paths{1} filesep subjects{sub} '_meanEPI.nii'])
        %movefile([datapath subjects{sub} filesep paths{1} filesep runs{1} filesep mEPI.name(1:end-3) 'hdr'],...
        %    [datapath subjects{sub} filesep paths{1} filesep subjects{sub} '_meanEPI.hdr'])


    end

    if doCoreg;
        % ---------- Coregister T1 -> meanEPI --------------------
        load SPM8_Parameters coregister;  
        jobs = coregister;
        
        %[source,Dirs] = spm_list_files([datapath subjects{sub} filesep structurals{1}],'s*.img');
        [source, Dirs] = spm_select('List',[datapath subjects{sub} filesep structurals{1}],'^s.*\.nii$');
        jobs{1}.spatial{1}.coreg{1}.estimate.source = {[datapath subjects{sub} filesep structurals{1} filesep source]};
        jobs{1}.spatial{1}.coreg{1}.estimate.ref    = {[datapath subjects{sub} filesep paths{1} filesep subjects{sub} '_meanEPI.nii']};

        spm_jobman('run',jobs)

        % ---------- Affine registration into MNI space --------------------
        load SPM8_Parameters coregisterToMNI; 
        jobs = coregisterToMNI;
        
        cnt = 1;
        %[source,Dirs] = spm_list_files([datapath subjects{sub} filesep structurals{1}],'s*.img');
        [source, Dirs] = spm_select('List',[datapath subjects{sub} filesep structurals{1}],'^s.*\.nii$');
        jobs{1}.spatial{1}.coreg{1}.estimate.source = {[datapath subjects{sub} filesep structurals{1} filesep source]};
        jobs{1}.spatial{1}.coreg{1}.estimate.ref    = defaults.old.preproc.tpm(1,:);
        for ses =1:size(runs,2)
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{1} filesep runs{ses}],'f*.img');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{1} filesep runs{ses}],'^f.*\.nii$');
            Files = [repmat([datapath subjects{sub} filesep paths{1} filesep runs{ses} filesep],size(Files,1),1) Files];
            for file = 1:size(Files,1)
                jobs{1}.spatial{1}.coreg{1}.estimate.other{cnt,1} = [Files(file,:) ',1']; cnt = cnt+1;
            end
        end
        jobs{1}.spatial{1}.coreg{1}.estimate.other{cnt,1} = [datapath subjects{sub} filesep paths{1} filesep subjects{sub} '_meanEPI.nii'];

        spm_jobman('run',jobs)
    end

    if doNormalise

        % ---------- Normalise using unified segmentation -----
        load SPM8_Parameters segment;
        jobs = segment;
        
        %[source,Dirs] = spm_list_files([datapath subjects{sub} filesep structurals{1}],'s*.img');
        [source, Dirs] = spm_select('List',[datapath subjects{sub} filesep structurals{1}],'^s.*\.nii$');
        jobs{1}.spatial{1}.preproc.opts.tpm{1} = defaults.old.preproc.tpm{1,:};
        jobs{1}.spatial{1}.preproc.opts.tpm{2} = defaults.old.preproc.tpm{2,:};
        jobs{1}.spatial{1}.preproc.opts.tpm{3} = defaults.old.preproc.tpm{3,:};
        jobs{1}.spatial{1}.preproc.data = {[datapath subjects{sub} filesep structurals{1} filesep source]};
        spm_jobman('run',jobs)
    end


    if doWrite
        
        % ---------- Normalise --------------------
        load SPM8_Parameters normalise;
        jobs = normalise; 
        
        cnt = 1;
        %[sourcemat,Dirsmat] = spm_list_files([datapath subjects{sub} filesep structurals{1}],'*_seg_sn.mat');
        [sourcemat, Dirsmat] = spm_select('List',[datapath subjects{sub} filesep structurals{1}],'^.*\_seg_sn.mat$');
        jobs{1}.spatial{1}.normalise{1}.write.subj.matname = {[datapath subjects{sub} filesep structurals{1} filesep sourcemat]};

        for ses =1:size(runs,2)
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{1} filesep runs{ses}],'f*.img');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{1} filesep runs{ses}],'^f.*\.nii$');
            Files = [repmat([datapath subjects{sub} filesep paths{1} filesep runs{ses} filesep],size(Files,1),1) Files];
            for file = 1:size(Files,1)
                jobs{1}.spatial{1}.normalise{1}.write.subj.resample{cnt,1} = [Files(file,:)]; cnt = cnt+1;
            end
        end
        %[source,Dirs] = spm_list_files([datapath subjects{sub} filesep structurals{1}],'s*.img');
        [source, Dirs] = spm_select('List',[datapath subjects{sub} filesep structurals{1}],'^s.*\.nii$');
        jobs{1}.spatial{1}.normalise{1}.write.subj.resample{cnt,1} = [datapath subjects{sub} filesep structurals{1} filesep source];
        jobs{1}.spatial{1}.normalise{1}.write.subj.resample{cnt+1,1} = [datapath subjects{sub} filesep paths{1} filesep subjects{sub} '_meanEPI.nii'];

        spm_jobman('run',jobs)

    end

    if doMove
        % ---------- Move normalised files --------------------
        for ses =1:size(runs,2)
            mkdir([datapath subjects{sub} filesep paths{2} filesep runs{ses}]);
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{1} filesep runs{ses}],'wf*.*');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{1} filesep runs{ses}],'^wf.*\.*$');
            for f = 1:size(Files,1)
                movefile([datapath subjects{sub} filesep paths{1} filesep runs{ses} filesep Files(f,:)],...
                    [datapath subjects{sub} filesep paths{2} filesep runs{ses} filesep Files(f,:)]);
            end
        end
        movefile([datapath subjects{sub} filesep paths{1} filesep 'w' subjects{sub} '_meanEPI.nii'],...
            [datapath subjects{sub} filesep paths{2} filesep 'w' subjects{sub} '_meanEPI.nii'])
        %movefile([datapath subjects{sub} filesep paths{1} filesep 'w' subjects{sub} '_meanEPI.hdr'],...
        %    [datapath subjects{sub} filesep paths{2} filesep 'w' subjects{sub} '_meanEPI.hdr'])

    end

    if doSmooth

        % ---------- Smooth --------------------
        load SPM8_Parameters smooth;
        jobs = smooth;
        
        cnt = 1;
        for ses =1:size(runs,2)
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{2} filesep runs{ses}],'wf*.img');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{2} filesep runs{ses}],'^wf.*\.nii$');
            Files = [repmat([datapath subjects{sub} filesep paths{2} filesep runs{ses} filesep],size(Files,1),1) Files];
            for file = 1:size(Files,1)
                jobs{1}.spatial{1}.smooth.data{cnt,1} = [Files(file,:) ',1']; cnt = cnt+1;
            end
        end
        spm_jobman('run',jobs)

        % ---------- Move smoothed files --------------------
        for ses =1:size(runs,2)
            mkdir([datapath subjects{sub} filesep paths{3} filesep runs{ses}]);
            %[Files,Dirs] = spm_list_files([datapath subjects{sub} filesep paths{2} filesep runs{ses}],'swf*.*');
            [Files, Dirs] = spm_select('List',[datapath subjects{sub} filesep paths{2} filesep runs{ses}],'^swf.*\.*$');
            for f = 1:size(Files,1)
                movefile([datapath subjects{sub} filesep paths{2} filesep runs{ses} filesep Files(f,:)],...
                    [datapath subjects{sub} filesep paths{3} filesep runs{ses} filesep Files(f,:)]);
            end
        end

    end

end

