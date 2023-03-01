function ling_Movement_Check                                                %
addpath(pwd);                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ONSET VEKTOREN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pdfdir = '/Data/Xiaxk/project3_Volatality_to_PC/fmri_analysis/data/Results/DataDiagnostics/';

subjects= {'sub9'};
 

runs  = {'session1', 'session2', 'session3', 'session4', 'session5', 'session6'},; 
Volums =[417	417	417	418	417	418];
project = 'cl';

datapfad='/Data/Xiaxk/project3_Volatality_to_PC/fmri_analysis/data/';                                              % Datenpfad 

nrsub=length(subjects);

for subnr=1:nrsub
    
    
    spm_defaults
    global defaults
    subnr;
    SPM=[];
    
    disp(sprintf('EVALUATING SUBJECT DATA!!'));
          
    results_path=fullfile(datapfad, 'Results', subjects{subnr});
        
    cd(results_path);
    cd('./Results_Dispersion_Instruction');                                             %Pfad der Results
    load SPM;
    
    imgfiles = SPM.xY.P;
    
    Results_file = fullfile(results_path, sprintf('%s%s',subjects{subnr}, ['_imgfiles_' project '.txt']));
    fid = fopen(Results_file,'w');
    
    
    nline = 0;
    for nrun=1:length(runs)
                
        if nrun > 1        
            nline = nline + Volums(nrun-1);
        
        end       
        
        fprintf(fid,'================%s_%s "%s", %4.0f-%0.0f-%0.0f %0.0f:%0.0f:%0.0f============\n',subjects{subnr},pwd, runs{nrun}, clock);       
        
        for ip=1:5
            fprintf(fid,'%s\n',SPM.xY.P(nline+ip,:));
        end;
        
        fprintf(fid,'\n');
    end;           
        
    fclose(fid);
    
    
    % design (user specified covariates)
    %---------------------------------------------------------------------------
    fg = spm_figure('Findwin','Graphics');
    if isempty(fg),
        fg=spm_figure('Create','Graphics');
        if isempty(fg),
            error('Cant create graphics window');
        end;
    else
        spm_figure('Clear','Graphics');
    end;
    psname = [subjects{subnr} '_*.ps'];
    
    %print head movements parameters
    
    for nrun=1:length(runs)
        datapath_o = fullfile(datapfad, subjects{subnr}, 'Orig', runs{nrun});
        fn2 = spm_select('FPList',datapath_o,'^rp_.*\.txt$');
        [r1,r2,r3,r4,r5,r6] = textread(fn2,'%f%f%f%f%f%f');
        [pathstr,name,ext,versn] = fileparts(fn2);
        plot_movements([r1,r2,r3,r4,r5,r6], subjects{subnr}, 1, pathstr,project);
    end;
    
    %print check reg results
    for nrun=1:length(runs)
        
        datapath_o_n = fullfile(datapfad, subjects{subnr}, 'Normalised', runs{nrun});
        
        images=[''];
        images(1,:)=spm_select('FPList',datapath_o_n, '.*00005-00005.*\.nii$');
        
        ling_spm_check_registration(images, subjects{subnr},datapath_o_n, project);
        
    end;
    
    movefile(psname, pdfdir, 'f');
    movefile(Results_file, pdfdir, 'f');
    cd(datapfad);
    
end;


function plot_movements(P,sub,session,file, project)

fg=spm_figure('FindWin','Graphics');
if ~isempty(fg),
	if length(P)<2, return; end;
    Params = P;

	% display results
	% translation and rotation over time series
	%-------------------------------------------------------------------
	spm_figure('Clear','Graphics');
	ax=axes('Position',[0.1 0.70 0.8 0.2],'Parent',fg,'Visible','off');
	set(get(ax,'Title'),'String',sprintf('Image realignment %s\n%s', sub,file), 'FontSize',16,'FontWeight','Bold','Visible','on');
	x     =  0.1;
	y     =  0.1;

	ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
	plot(Params(:,1:3),'Parent',ax)
	s = ['x translation';'y translation';'z translation'];
	%text([2 2 2], Params(2, 1:3), s, 'Fontsize',10,'Parent',ax)
	legend(ax, s, 0)
	set(get(ax,'Title'),'String','translation','FontSize',16,'FontWeight','Bold');
	set(get(ax,'Xlabel'),'String','image');
	set(get(ax,'Ylabel'),'String','mm');


	ax=axes('Position',[0.1 0.33 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
	plot(Params(:,4:6)*180/pi,'Parent',ax)
	s = ['pitch';'roll ';'yaw  '];
	%text([2 2 2], Params(2, 4:6)*180/pi, s, 'Fontsize',10,'Parent',ax)
	legend(ax, s, 0)
	set(get(ax,'Title'),'String','rotation','FontSize',16,'FontWeight','Bold');
	set(get(ax,'Xlabel'),'String','image');
	set(get(ax,'Ylabel'),'String','degrees');

	% print realigment parameters
	ling_spm_print([sub '_head_movements_' project]);
end
return;

function ling_spm_check_registration(images,sub,file, project)

if nargin==0,
	images = spm_select([1 15],'image','Select images');
	ling_spm_check_registration(images);
elseif nargin==4,
	fg = spm_figure('Findwin','Graphics');
	if isempty(fg),
		fg=spm_figure('Create','Graphics');
		if isempty(fg),
			error('Cant create graphics window');
		end;
    else
		spm_figure('Clear','Graphics');
	end;
	
	single_T1=fullfile(spm('Dir'), 'canonical', 'single_subj_T1.nii');
	if length(single_T1) > size(images,2)
		c_space = repmat(' ', size(images,1), length(single_T1)-size(images,2));
		images = [images c_space];
	elseif length(single_T1) < size(images,2)
		c_space = repmat(' ', 1, size(images,2)-length(single_T1));
		single_T1 = [single_T1 c_space];
	end;
	images=[images;single_T1];
	
	if ischar(images), images=spm_vol(images); end;
    
    ax=axes('Position',[0.1 0.72 0.8 0.2],'Parent',fg,'Visible','off');	
	%ax=axes('Position',[0.1 0.65 0.8 0.2],'Parent',fg,'XGrid','on','YGrid','on');
    
	spm_orthviews('Reset');
	mn = length(images);
	n  = round(mn^0.4);
	m  = ceil(mn/n);
	w  = 1/n;
	h  = 1/m;
	ds = (w+h)*0.02;
	for ij=1:mn,
		i  = 1-h*(floor((ij-1)/n)+1);
		j  = w*rem(ij-1,n);
		handle(ij) = spm_orthviews('Image', images(ij),...
			[j+ds/2 i+ds/2 w-ds h-ds]);
		if ij==1, spm_orthviews('Space'); end;
		spm_orthviews('AddContext',handle(ij));
	end;
    
    % up
    spm_orthviews('Reposition',[1 -18 82 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nSuperior', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
    %down
    spm_orthviews('Reposition',[4 -25 -52 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nInferior', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
    %left
    spm_orthviews('Reposition',[-68 -25 -2 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nLeft', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
    %right
    spm_orthviews('Reposition',[68 -25 -2 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nRight', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
    %anterior
    spm_orthviews('Reposition',[5 72 3 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nAnterior', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
    %posterior
    spm_orthviews('Reposition',[0 -105 2 ]);
    set(get(ax,'Title'),'String',sprintf('Check Reg %s\n%s\nPosterior', sub, file), 'FontSize',16,'FontWeight','Bold','Visible','on');
    ling_spm_print([sub '_check_reg_' project]);
    
else
	error('Incorrect Usage');
end;