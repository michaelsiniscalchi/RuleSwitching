%%% analyze_RuleSwitchingSession
%
%PURPOSE: To analyze individual sessions from a two-choice auditory rule switching task.
%
%AUTHOR: MJ Siniscalchi, 190701
%
%--------------------------------------------------------------------------

clearvars;

% Set paths to analysis code
[data_dir,~,~] = pathlist_RuleSwitching;
% Assign data directories and get experiment-spec parameters
%[dirs, expData] = expData_RuleSwitching(data_dir); 
[dirs, expData] = expData_RuleSwitching_DEVO(data_dir);
% Set parameters for analysis
[calculate, do_plot, mat_file, params] = params_RuleSwitching;
% Generate directory structure
create_dirs(dirs.results,dirs.summary,dirs.figures);
% Tabulate experimental data for easy reference
%***FUTURE: function tabulate_expData() and record more info
expTable = table((1:numel(expData))',{expData.sub_dir}',... 
    'VariableNames',{'Index','Experiment_ID'});

%***DEVO
% expData = expData(1:5);

%% Analyze Behavior
if calculate.behavior
    f = waitbar(0);
    for i = 1:numel(expData)
        msg = ['Processing logfile ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        % Parse logfile
        logData = parseLogfile(fullfile(dirs.data,expData(i).sub_dir),expData(i).logfile);
        % Get stimulus, response, and outcome data from each trial
        [sessionData, trialData] = getSessionData(logData);
        % Get data from each rule block
        blocks = getBlockData(sessionData, trialData );
        % Generate logical masks for specific trial types
        trials = getTrialMasks(sessionData, trialData, blocks);
        % Get performance data for each rule block (hitrate, persev error rate, etc.)
        blocks = getPerfData( blocks, trials );
        
        %Save processed data
        save_path = fullfile(dirs.results,expData(i).sub_dir);
        create_dirs(save_path);
        save(fullfile(save_path,mat_file.behavior),...
            'logData','sessionData','trialData','blocks','trials');
    end
    close(f);
    clearvars -except data_dir dirs expData calculate do_plot mat_file params;
end

%% Check data consistency and initialize results file

% Get image header information generated during acquisition
if calculate.stack_info     %Get header info and tag struct from original TIFs
    for i = 1:numel(expData)
        stackInfo = get_stackInfo(expData(i).raw_path); %Generated during mvt correction or post-hoc with the script 'get_stackInfo.m'
        save(fullfile(dirs.data,expData(i).sub_dir,mat_file.stack_info),... 
            '-STRUCT','stackInfo'); %Save stack info from ScanImage
    end
end

if calculate.cellF || calculate.dFF
    % Validation check
    err_msg = check_consistencyImgBeh(dirs,mat_file,expData); %Truncate imaging or behavioral data if necessary and provide info
    for i = 1:numel(expData)
        %Load behavioral data and imaging info
        behData = load(fullfile(dirs.results,expData(i).sub_dir,mat_file.behavior),...
            'logData','sessionData','trialData','blocks','trials');
        stackInfo = load(fullfile(dirs.data,expData(i).sub_dir,mat_file.stack_info));
        %Reconcile and save combined data
        data = get_combinedData(behData,stackInfo);
        save(fullfile(dirs.results,expData(i).sub_dir,mat_file.fluorescence),... 
            '-STRUCT','data'); %Save stack info from ScanImage
    end
end

%% Analyze cellular fluorescence
for i = 1:numel(expData)
    
    disp(['Processing cellular fluorescence data; session ' int2str(i) ' out of ' int2str(numel(expData)) '.']);

    % Subdirectories and MAT files to save results and figures
    save_path = fullfile(dirs.results,expData(i).sub_dir);       %Results directory
    create_dirs(save_path);
    
    % Paths to MAT files containing fluorescence data (***TODO: replace eg roi_path with eg 'fpath.roi' and use function to get them
    roi_path = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir); %Directory containing all ROIs from current session
    dff_mat = fullfile(save_path,mat_file.fluorescence);
    
    if calculate.cellF
        %Get cellular and neuropil fluorescence excluding overlapping regions and n-pixel frame
        [stack, cells] = get_fluoData(roi_path,[],expData(i).mat_path); %Second arg, reg_path set to [] to indicate matfiles already saved.
        [cells, masks] = calc_cellF(stack, cells, params.exclBorderWidth);
        save(dff_mat,'-STRUCT','cells'); %Save to dff.mat
        save(dff_mat,'masks','-append'); %Save to dff.mat
        clearvars stack;
    end
    
    if calculate.dFF
        load(fullfile(dirs.results,expData(i).sub_dir,mat_file.behavior),...
        'sessionData','trialData','trials','blocks'); %Load saved behavioral data
  
        %Calculate dF/F trace for each cell
        if ~exist('cells','var') % ie if calcCellF = false
            cells = load(dff_mat);
        end       
        cells = calc_dFF(cells, stackInfo, trialData.startTimes,...
            sessionData.timeLastEvent, expData(i).npCorrFactor);
        
        save(dff_mat,'-STRUCT','cells');
        clearvars cells;
    end
end

%% Summary
%Save reference table

%% Figures

% Visualize raw behavioral data
if do_plot.behavior
    for i = 1:numel(expData)
        save_dir = fullfile(dirs.figures,'Raw behavior');
        create_dirs(save_dir); %Create dir for these figures
        load(fullfile(dirs.results,expData(i).sub_dir,mat_file.behavior)); %Load saved behavioral data
        
        tlabel = [sessionData.subject{:},' - ',sessionData.dateTime{1}]; %Title
        fig = plot_flexBehByTrial(trialData,trials,tlabel,[params.window(1) params.window(end)]); %Generate plot
        
        savefig(fig,fullfile(save_dir,expData(i).sub_dir)); %Save as FIG
        saveas(fig,fullfile(save_dir,[expData(i).sub_dir '.png'])); %Save as PNG
        close(fig);
    end
end

% Generate Mean Projection Image for each Field-of-View
if do_plot.FOV_mean_projection
    save_dir = fullfile(dirs.figures,'FOV mean projections');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures
    for i = 1:numel(expData)
        fig = fig_meanProj(expData(i).mat_path); 
        savefig(fig,fullfile(save_dir,expData(i).sub_dir)); %Save as FIG
        saveas(fig,fullfile(save_dir,[expData(i).sub_dir '.png'])); %Save as PNG
        close(fig);
    end
end

% Plot all timeseries from each experiment
if do_plot.all_timeseries
    save_dir = fullfile(dirs.figures,'Cellular fluorescence');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures
    for i = 1:numel(expData)
        %Load data
        cells = load(fullfile(dirs.results,expData(i).sub_dir,mat_file.fluorescence));
        load(fullfile(dirs.results,expData(i).sub_dir,mat_file.behavior),'trialData','blocks');
        %Generate fig and save
        fig = fig_plotAllTimeseries(cells,trialData,blocks); 
        savefig(fig,fullfile(save_dir,expData(i).sub_dir)); %Save as FIG
        saveas(fig,fullfile(save_dir,[expData(i).sub_dir '.png'])); %Save as PNG
        close(fig);    
    end
end

% Plot trial-averaged dF/F: Sound(L/R), Action(L/R), Left(S/A), Right(S/A)
if do_plot.single_units
    for i = 1:numel(expData)
        save_dir = fullfile(dirs.figures,'Cellular fluorescence',expData(i).sub_dir);   %Figures directory: single units
        create_dirs(save_dir); %Create dir for these figures
        
    end
end


