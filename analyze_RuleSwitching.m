%---------------------------------------------------------------------------------------------------
% analyze_RuleSwitchingSession
%
% PURPOSE: To analyze individual sessions from a two-choice auditory rule switching task.
%
% AUTHOR: MJ Siniscalchi, 190701
%
% NOTES:    
%           * If neuropil (background) masks are not generated after cell selection in cellROI.m,
%               use the script get_neuropilMasks_script to generate them post-hoc 
%               (much faster than doing it through the GUI...).
%
% TODO:
%       -Complete the experiment table: include #cells, #trials, #blocks
%       -Include number of excluded cells in summary_stats: for each cell type, {total, %total, %bySession}
%
%---------------------------------------------------------------------------------------------------

clearvars;

% Set MATLAB path and get experiment-specific parameters
[dirs, expData] = expData_RuleSwitching(pathlist_RuleSwitching);
%[dirs, expData] = expData_RuleSwitching_DEVO(pathlist_RuleSwitching); %For processing/troubleshooting subsets

% Set parameters for analysis
[calculate, summarize, figures, mat_file, params] = params_RuleSwitching(dirs,expData);
expData = get_imgPaths(expData,calculate); %Append additional paths for imaging data if required by 'calculate'

% Generate directory structure
create_dirs(dirs.results,dirs.summary,dirs.figures);

% Tabulate experimental data for easy reference %***WIP TO FINISH SOON***
expTable = table((1:numel(expData))',{expData.sub_dir}',{expData.cellType}',... %***FUTURE: function expTable = tabulate_expData(expTable,dirs,expData,'') and record more info
    'VariableNames',{'Index','Experiment_ID','Cell_Type'});

% Begin logging processes
diary(fullfile(dirs.results,['procLog' datestr(datetime,'yymmdd')])); 
diary on;
disp(datetime);

%% ANALYZE BEHAVIOR
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
        blocks = getBlockData(sessionData, trialData ); %***DOES NOT NEED VAR SESSIONDATA...MODIFY
        % Generate logical masks for specific trial types
        trials = getTrialMasks(sessionData, trialData, blocks);
        % Get performance data for each rule block (hitrate, persev error rate, etc.)
        blocks = getPerfData(trialData, trials, blocks);
        %Save processed data
        create_dirs(fileparts(mat_file.behavior(i))); %Create save directory
        save(mat_file.behavior(i),'logData','sessionData','trialData','trials','blocks');
    end
    close(f);
    clearvars -except data_dir dirs expData calculate summarize do_plot mat_file params;
end

%% CHECK DATA CONSISTENCY AND INITIALIZE FILE FOR COMBINED IMAGING-BEHAVIOR DATA

% Get image header information generated during acquisition
if calculate.stack_info     %Get header info and tag struct from original TIFs
    for i = 1:numel(expData)
        stackInfo = get_stackInfo(expData(i).raw_path); %Generated during mvt correction or post-hoc with the script 'get_stackInfo.m'
        save(mat_file.stack_info(i),'-STRUCT','stackInfo'); %Save stack info from ScanImage
    end
end

if calculate.combined_data
    % Validation check
    [err_msg,err_data] = check_consistencyImgBeh(dirs,mat_file,expData); %Truncate imaging or behavioral data if necessary and provide info
    save(mat_file.validation,'-STRUCT','err_data'); %Save validation results
    for i = 1:numel(expData)
        %Load behavioral data and imaging info
        behData = load(mat_file.behavior(i),...
            'logData','sessionData','trialData','blocks','trials');
        stackInfo = load(mat_file.stack_info(i));
        %Reconcile and save combined data
        data = get_combinedData(behData,stackInfo);
        if ~exist(mat_file.img_beh(i),'file')
            save(mat_file.img_beh(i),'-STRUCT','data'); %Save combined imaging and behavioral data
        else, save(mat_file.img_beh(i),'-STRUCT','data','-append');
        end
    end
end

%% ANALYZE CELLULAR FLUORESCENCE

if calculate.fluorescence
    tic; %Reset timer
    disp(['Processing cellular fluorescence data. ' int2str(numel(expData)) ' sessions total.']);
    f = waitbar(0,'');
    for i = 1:numel(expData)
        %Display waitbar
        msg = ['Session ' num2str(i) '/' num2str(numel(expData)) '...'];
        waitbar(i/numel(expData),f,msg);
        
        % Load behavioral data and metadata from image stacks
        load(mat_file.img_beh(i),'stackInfo','trialData','trials','blocks'); %Load saved data
        
        if calculate.cellF
            %Get cellular and neuropil fluorescence excluding overlapping regions and n-pixel frame
            roi_path = fullfile(dirs.data,expData(i).sub_dir,expData(i).roi_dir);
            %[stack, cells] = get_fluoData(roi_path,expData(i).reg_path,expData(i).mat_path,stackInfo); %Second arg, reg_path set to [] to indicate matfiles already saved.
            [stack, cells] = get_fluoData(roi_path,[],expData(i).mat_path,stackInfo);
            [cells, masks] = calc_cellF(stack, cells, params.fluo.exclBorderWidth);
            save(mat_file.cell_fluo(i),'-struct','cells'); %Save to dff.mat
            save(mat_file.cell_fluo(i),'masks','-append'); %Save to dff.mat
            clearvars stack cells masks;
        end
        
        % Calculate dF/F trace for each cell
        if calculate.dFF
            cells = load(mat_file.cell_fluo(i),'cellF','npF','cellID'); %calc_dFF() will transfer any other loaded variables to struct 'dFF'
            cells = calc_dFF(cells, stackInfo, trialData.startTimes,0); %expData(i).npCorrFactor set to zero for prelim analysis
            save(mat_file.img_beh(i),'-struct','cells','-append');
            clearvars cells
        end
        
        % Align dF/F traces to specified behavioral event
        if calculate.align_signals
            cells = load(mat_file.img_beh(i),'dFF','t');
            trialDFF = alignCellFluo(cells,trialData,params.align);
            save(mat_file.img_beh(i),'trialDFF','-append');
            clearvars cells
        end
        
        % Event-related cellular fluorescence
        if calculate.trial_average_dFF %Trial averaged dF/F with bootstrapped CI
            load(mat_file.img_beh(i),'trialDFF','trials','cellID');
            bootAvg = calc_trialAvgFluo(trialDFF, trials, params.bootAvg);
            if ~exist(mat_file.results(i),'file')
                save(mat_file.results(i),'bootAvg','cellID'); %Save
            else, save(mat_file.results(i),'bootAvg','cellID','-append');
            end
        end
               
        % Decode choice, outcome, and rule from single-units
        if calculate.decode_single_units
            load(mat_file.img_beh(i),'trialDFF','trials');
            decode = calc_selectivity(trialDFF,trials,params.decode);
            save(mat_file.results(i),'decode','-append');
        end
        
        % Rule transition analysis     
        if calculate.transitions
            %Calculate trial-by-trial similarity to activity assoc. w. prior and current rule
            S = load(mat_file.results(i),'decode'); 
            img_beh = load(mat_file.img_beh(i),'trialDFF','trials','blocks','cellID','sessionID');
            transitions = calc_transitionResults(img_beh,S.decode,params.transitions);
            save(mat_file.results(i),'transitions','-append');
        end
        %clearvars stackInfo trialData trials blocks roi_path cellF_mat dff_mat
    end
    close(f);
    disp(['Total time needed for cellular fluorescence analyses: ' num2str(toc) 'sec.']); 
%05 hrs for cellF
%29 hrs for dF/F for all sessions
%18 hrs for ROC analysis

end

%% SUMMARY

%***FUTURE: Save reference table

% Behavior
if summarize.behavior
    fieldNames = {'sessionData','trialData','trials','blocks','cellType'};
    B = initSummaryStruct(mat_file.behavior,[],fieldNames,expData); %Initialize data structure
    behavior = summary_behavior(B, params.behavior); %Aggregate results
    save(mat_file.summary.behavior,'-struct','behavior');
end

% Imaging
if summarize.imaging
    fieldNames = {'sessionID','cellID','exclude','blocks'};
    S = initSummaryStruct(mat_file.img_beh,[],fieldNames,expData); %Initialize data structure
    imaging = summary_imaging(S, params.fluo); %Aggregate results
    save(mat_file.summary.imaging,'-struct','imaging');
end

% Selectivity
if summarize.selectivity
    %Initialize structure
    for i=1:numel(params.decode.decode_type)
        selectivity.(params.decode.decode_type{i}) = struct();
    end
    %Aggregate results
    for i = 1:numel(expData)
        S = load(mat_file.results(i),'decode','cellID');
        selectivity = summary_selectivity(...
            selectivity, S.decode, expData(i).cellType, i, S.cellID, params.decode); %summary = summary_selectivity( summary, decode, cell_type, exp_ID, cell_ID, params )
    end
    selectivity.t = S.decode.t; %Copy time vector from 'decode'
    save(mat_file.summary.selectivity,'-struct','selectivity');
end

% Transition analysis
if summarize.transitions
    fieldNames = {'sessionID','cellType','cellID','type','similarity','aggregate',...
        'behChangePt1','behChangePt2','nTrials','params'};
    T = initSummaryStruct(mat_file.results,'transitions',fieldNames,expData); % S = initSummaryStruct( matFile, resultName, fieldNames, expData );
    transitions = summary_transitions(T);
    save(mat_file.summary.transitions,'-struct','transitions');
end

% Summary Statistics and Results Table
if summarize.stats
    %Initialize file
    analysis_name = params.stats.analysis_names;
    if ~exist(mat_file.stats,'file')
        for i = 1:numel(analysis_name)
            stats.(analysis_name{i}) = struct();
        end
        save(mat_file.stats,'-struct','stats');
    end
    
    %Load summary data from each analysis and calculate stats
    stats = load(mat_file.stats);
    for i = 1:numel(analysis_name)
        summary = load(mat_file.summary.(analysis_name{i}));
        stats = summary_stats(stats,summary,analysis_name{i});
    end
    save(mat_file.stats,'-struct','stats');
end

if summarize.comparisons

end

% Stop logging processes
diary off;

%% SUMMARY TABLES
if figures.table_experiments
    % SessionID, CellType, #Cells, #Trials, #Blocks
    stats = load(mat_file.stats,'behavior','imaging','tabular');
    tables.summary = table_expData(expData,stats);
    save(mat_file.stats,'tabular','-append');
end

if figures.table_descriptive_stats
    stats = load(mat_file.stats);
    tables.stats = table_descriptiveStats(stats);
    save(mat_file.stats,'tabular','-append');
end

if figures.table_comparative_stats    
    stats = load(mat_file.stats);
    tables.comparisons = table_comparisons(stats);
    save(mat_file.stats,'tabular','-append');
end
%% FIGURES - BEHAVIOR
% Visualize raw behavioral data
%***Condense this section with current system
if figures.raw_behavior
    save_dir = fullfile(dirs.figures,'Raw behavior');
    create_dirs(save_dir); %Create dir for these figures
    for i = 1:numel(expData)
        B = load(fullfile(mat_file.behavior(i))); %Load saved behavioral data
        fig = plot_flexBehByTrial(...
            B.trialData, B.trials, expData(i).sub_dir, params.figs.behavior); %Generate plot
        save_multiplePlots(fig,save_dir); %save as FIG and PNG
        clearvars figs;
    end
end

if figures.lick_density
    save_dir = fullfile(dirs.figures,'Lick density');
    create_dirs(save_dir); %Create dir for these figures
    for i = 1:numel(expData)
        load(fullfile(mat_file.behavior(i))); %Load saved behavioral data
        fig = fig_lickDensity(trialData,trials,expData(i).sub_dir,params.figs.lickDensity); %Generate plot
        save_multiplePlots(fig,save_dir); %save as FIG and PNG
        clearvars figs;
    end
end
%% FIGURES - IMAGING
% Generate Mean Projection Image for each field-of-view
if figures.FOV_mean_projection
    save_dir = fullfile(dirs.figures,'FOV mean projections');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures
    expIdx = restrictExpIdx({expData.sub_dir},params.figs.fovProj.expIDs); %Restrict to specific sessions, if desired
    
    % Calculate or re-calculate mean projection from substacks
    figData = getFigData(dirs,expData,expIdx,mat_file,'FOV_mean_projections',params);
          
    % Generate figures: mean projection with optional ROI and/or neuropil masks
    figs = gobjects(numel(expIdx),1); %Initialize figures
    for i = 1:numel(expIdx)
        figs(i) = fig_meanProj(figData, expIdx(i), params.figs.fovProj); %***WIP***
        figs(i).Name = expData(expIdx(i)).sub_dir;
    end
    save_multiplePlots(figs,save_dir,'svg'); %Save figure
end

% Plot all timeseries from each experiment
if figures.timeseries
    %Initialize graphics array and create directories 
    expIdx = restrictExpIdx({expData.sub_dir},params.figs.timeseries.expIDs); %Restrict to specific sessions, if desired 
    save_dir = fullfile(dirs.figures,'Cellular fluorescence');   %Figures directory: cellular fluorescence
    create_dirs(save_dir); %Create dir for these figures 
    figs = gobjects(numel(expIdx),1); %Initialize figures
    %Generate figures
    for i = 1:numel(expIdx)
        imgBeh = load(mat_file.img_beh(expIdx(i)),'sessionID','dFF','t','trials','trialData','blocks','cellID'); %Load data
        figs(i) = fig_plotAllTimeseries(imgBeh,params.figs.timeseries);         %Generate fig
    end
    %Save batch as FIG, PNG, and SVG
    save_multiplePlots(figs,save_dir,'svg');
    clearvars figs;
end

%% FIGURES - SINGLE UNIT ANALYSES

% Plot trial-averaged dF/F: Sound(L/R), Action(L/R), Left(S/A), Right(S/A)
if figures.trial_average_dFF
    for i = 1:numel(expData)
        %Load data
        load(mat_file.results(i),'bootAvg');
        cells = load(mat_file.img_beh(i),'cellID','blocks');
        save_dir = fullfile(dirs.figures,'Cellular fluorescence',expData(i).sub_dir);   %Figures directory: single units
        create_dirs(save_dir); %Create dir for these figures
        
        %Save figure for each cell plotting all combinations of choice x outcome
        if figures.trial_average_dFF
            figs = plot_trialAvgDFF(bootAvg,cells,params.figs.bootAvg);
            save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
        end
        clearvars figs
     end
end

% Plot ROC analyses: one figure each for choice, outcome, and rule
if figures.decode_single_units
    for i = 1:numel(expData)
        %Load data
        load(mat_file.results(i),'decode');
        cells = load(mat_file.img_beh(i),'cellID');
        %Figures directory
        save_dir = fullfile(dirs.figures,'Single-unit modulation',expData(i).sub_dir);
        create_dirs(save_dir); %Create dir for these figures
        %Figure with ROC analysis and selectivity traces
        sessionID = [expData(i).sub_dir(1:end-14) ' ' expData(i).cellType];
        figs = fig_singleUnit_ROC(decode,cells,params.figs.decode_single_units);
        save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
        clearvars figs
    end
end

% Heatmap of selectivity traces: one figure each for choice, outcome, and rule
if figures.heatmap_modulation_idx
    for i = 1:numel(expData)
        disp(['Generating modulation heatmaps for session ' num2str(i) '...']);
        %Load data
        load(mat_file.results(i),'decode','cellID');
        save_dir = fullfile(dirs.figures,'Single-unit modulation');   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        
        %Figure with heatmap for each behavioral variable (choice, outcome, & rule)
        sessionID = [expData(i).sub_dir(1:end-14) ' ' expData(i).cellType];
        figs(i) = fig_modulation_heatmap(decode,sessionID,cellID,params);
        
        %Figure with heatmap only for significantly modulated cells
        figs(numel(expData)+i) = fig_modulation_heatmap(decode,sessionID,cellID,params,'sig');
    end
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

%% FIGURES - TRANSITION ANALYSIS
if figures.transitions
    
    %Plot binned and aligned results
    figs = gobjects(numel(expData),1); %Initialize figures
    for i = 1:numel(expData)    
        load(mat_file.results(i),'transitions');
        save_dir = fullfile(dirs.figures,'Neural transitions','Binned',transitions.params.stat);   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        figs(i) = fig_transitions_binned(transitions, params.figs.transitions); 
    end
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
    
    %Plot all transitions in session, aligned to rule switches
    for i = 1:numel(expData)
        load(mat_file.results(i),'transitions');
        save_dir = fullfile(dirs.figures,'Neural transitions','Raw',transitions.params.stat);   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        figs = fig_transitions_individual( transitions, params.figs.transitions );
        
        save_multiplePlots(figs,save_dir); %save as FIG and PNG
        clearvars figs;
    end   
end

%% SUMMARY FIGURES

% Behavior: Descriptive Statistics
if figures.summary_behavior
    stats = load(mat_file.stats); %Load data
    save_dir = fullfile(dirs.figures,'Summary - behavioral statistics'); %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    
    cellType = {'SST','VIP','PV','PYR'};
    for i=1:numel(cellType)
        figs(i) = fig_summary_behavior_swarms(stats.behavior,cellType{i},params.figs.summary_behavior);
    end
     figs(numel(cellType)+1) =...
            fig_summary_behavior(stats.behavior,params.figs.summary_behavior);
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

% Lick Density Plots
if figures.summary_lick_density
    stats = load(mat_file.stats); %Load data
    save_dir = fullfile(dirs.figures,'Summary - lick density'); %Figures directory
    create_dirs(save_dir); %Create dir for these figures
 
    cellType = {'all','SST','VIP','PV','PYR'};
    for i = 1:numel(cellType)
        figs(i) = fig_summary_lick_density(stats.behavior,cellType{i},params.figs.lickDensity);
    end
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

% Periswitch performance curves
if figures.summary_periswitch_performance
    behavior = load(mat_file.summary.behavior); %Load data
    save_dir = fullfile(dirs.figures,'Summary - periswitch performance curves'); %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    
    cellType = {'all','SST','VIP','PV','PYR'};
    for i=1:numel(cellType)
        figs(i) = fig_summary_periswitch_performance(behavior,cellType{i},params.figs.perfCurve);
    end
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

% Heatmap of modulation indices for each cell type: one figure each for choice, outcome, and rule
if figures.summary_modulation_heatmap
    %Load data
    decode = load(mat_file.summary.selectivity,params.decode.decode_type{:});
    load(mat_file.summary.selectivity,'t');
    save_dir = fullfile(dirs.figures,'Summary - modulation heatmaps');   %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    
    %Heatmap for each behavioral variable (choice, outcome, & rule)
    decodeType = fieldnames(decode);
    for j = 1:numel(decodeType)
        disp(['Generating summary figure: modulation heatmap for ' decodeType{j} '...']);
        %***RENAME: fig_summary_modulation_heatmap()
        figs(j) = fig_summary_selectivity(...
            decode, decodeType{j}, t, params.figs.mod_heatmap);
        %Figure with heatmap only for significantly modulated cells
        figs(numel(decodeType)+j) = fig_summary_selectivity(...
            decode, decodeType{j}, t, params.figs.mod_heatmap, 'sig');
    end
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

% Summarize modulation by CO&R for all cell types
if figures.summary_modulation
    %Load data
    B = load(mat_file.stats,'selectivity');
    time = load(mat_file.summary.selectivity,'t'); time = time.t;
    save_dir = fullfile(dirs.figures,'Summary - modulation comparisons');   %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    %Generate figures
    mod_figs = fig_summary_modulation(B.selectivity,time,params.figs.summary_modulation);
    pref_fig = fig_summary_preference(B.selectivity,time,params.figs.summary_preference);
    %Save
    figs = [mod_figs; pref_fig];
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end

if figures.summary_transitions
    %Load data
    load(mat_file.stats,'transitions');
    save_dir = fullfile(dirs.figures,'Summary - Transition Analysis');   %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    
    %Generate figures
    for i = 1:numel(params.figs.summary_transitions)
        %Binned transitions
        figs(i) = fig_summary_transitions(transitions,params.figs.summary_transitions(i));
    end
    %Scatter: neurobehavioral change points
    figs(i+1) = fig_summary_changePoints(transitions,params.figs.summary_changePoints);
    
    %Save
    save_multiplePlots(figs,save_dir,'svg'); %save as FIG and PNG
    clearvars figs;
end


%% FIGURES: VALIDATION CHECK

if figures.validation_ITIs || figures.validation_ROIs || figures.validation_alignment
    %Setup figure directories
    save_dir = fullfile(dirs.figures,'Validation Checks');   %Figures directory
    create_dirs(save_dir); %Create dir for these figures
    
    if figures.validation_ITIs
        % Check correspondence between behavioral and imaging ITIs
        errData = load(mat_file.validation);          %Load data
        save_dir = fullfile(dirs.figures,'Validation Checks','ITIs');   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        figs = fig_validation_ITI(errData.diff_ITIs, errData.sessionID);
        save_multiplePlots(figs,save_dir); %save as FIG and PNG
        clearvars figs;
    end
    
    if figures.validation_ROIs %***WIP***
        % Validate alignment of fluorescence timeseries
        save_dir = fullfile(dirs.figures,'Validation Checks','Cell and Background Masks');   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        for i = 1:numel(expData)
            figs = fig_validation_ROIs();
            save_multiplePlots(figs,save_dir); %save as FIG and PNG
            clearvars figs;
        end
    end
 
    if figures.validation_alignment 
        % Validate alignment of fluorescence timeseries
        expIdx = 1:numel(expData);
        if ~isempty(params.figs.timeseries.expIDs)         %Restrict to specific sessions, if desired
            expIdx = find(ismember({expData.sub_dir}, params.figs.timeseries.expIDs));
        end
        %Initialize graphics array and create directories
        save_dir = fullfile(dirs.figures,'Validation Checks','Alignment');   %Figures directory
        create_dirs(save_dir); %Create dir for these figures
        figs = gobjects(numel(expIdx),1); %Initialize figures
        %Generate figures
        for i = 1:numel(expIdx)
            imgBeh = load(mat_file.img_beh(expIdx(i)),...
                'sessionID','dFF','t','trialDFF','trials','trialData','blocks','cellID'); %Load data
            figs(i) = fig_validation_alignment(imgBeh,params.figs.timeseries);         %Generate fig
        end
        %Save batch as FIG, PNG, and SVG
        save_multiplePlots(figs,save_dir,'svg');
        clearvars figs;
    end
    
end

%% Remaining validation checks:
%
%   1) fig_validation_overlayROIs()
%       Validate background masks by plotting all ROIs and masks for each session.       
%
%   2) fig_validation_alignment() 
%       Check alignment by plotting each aligned trace on the raw traces. ***DONE***
%           tested on '181003 M52 RuleSwitching' & '180831 M55 RuleSwitching' only
%   
%   3) Check uniformity of cellf-related processing, specifically for exclusion based on background F0. *DONE*
%
%   4) Do screenROIs_batch ASAP, and get help from Mark on screening for possible exclusions...

%% Remaining work on figures
%
% 200128 try to plot all bar graphs as beeswarms (except perhaps the preference plots - those could be compact boxplots) *DONE*