function [ calculate, summarize, figures, mat_file, params ] = params_RuleSwitching(dirs,expData)

%% CALCULATE OR RE-CALCULATE RESULTS
calculate.behavior              = false;
calculate.stack_info            = false;
calculate.combined_data         = false;  %Combine relevant behavioral and imaging data in one MAT file ; truncate if necessary
calculate.cellF                 = false; %Extract cellf and neuropilf from ROIs, excluding overlapping regions and extremes of the FOV
calculate.dFF                   = false; %Calculate dF/F, with optional neuropil subtraction
calculate.align_signals         = false; %Interpolate dF/F and align to behavioral events
calculate.trial_average_dFF     = false; %dF/F averaged over specified subsets of trials
calculate.decode_single_units   = false; %ROC/Selectivity for choice, outcome and rule
calculate.transitions           = false; %Changes in dF/F over each block; %*NOT USED for paper

calculate.fluorescence = false;
if any([calculate.cellF, calculate.dFF, calculate.align_signals, calculate.trial_average_dFF,...
		calculate.decode_single_units, calculate.transitions])
	calculate.fluorescence = true;
end

%% SUMMARIZE RESULTS
summarize.behavior              = false;
summarize.imaging               = false;
summarize.selectivity           = false;
summarize.transitions           = false; %*NOT USED for paper

summarize.stats                     = false; %Descriptive stats; needed for all summary plots
summarize.table_experiments         = false;
summarize.table_descriptive_stats   = false;
summarize.table_comparative_stats   = false;

%% PLOT RESULTS

% Behavior
figures.raw_behavior                    = false;
figures.lick_density                    = false;
% Imaging 
figures.FOV_mean_projection             = false;
figures.timeseries                      = false; %Plot all timeseries for each session
% Combined
figures.trial_average_dFF               = true;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)
figures.time_average_dFF                = false;  %Overlay traces for distinct choices, outcomes, and rules (CO&R)
figures.decode_single_units             = false;
figures.heatmap_modulation_idx          = false;  %Heatmap of selectivity idxs for COR for each session
figures.transitions                     = false; 
% Summary
figures.summary_behavior                = false;  %Summary of descriptive stats, eg, nTrials and {trials2crit, pErr, oErr} for each rule
figures.summary_task_related_activity   = false;
figures.summary_modulation_heatmap      = false; %Heatmap for each celltype, all sessions, one figure each for CO&R
figures.summary_modulation				= false; %Box/line plots of grouped selectivity results for comparison
figures.summary_transitions             = false;

% Validation
figures.validation_ITIs                 = false;
figures.validation_ROIs                 = false;
figures.validation_alignment            = false;

%% PATHS TO SAVED DATA
%By experiment
mat_file.behavior       = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'behavior.mat');
mat_file.stack_info     = @(idx) fullfile(dirs.data,expData(idx).sub_dir,'stack_info.mat');
mat_file.cell_fluo      = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'cell_fluo.mat');
mat_file.img_beh        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'img_beh.mat');
mat_file.results        = @(idx) fullfile(dirs.results,expData(idx).sub_dir,'results.mat');
%Aggregated
mat_file.summary.behavior       = fullfile(dirs.summary,'behavior.mat');
mat_file.summary.imaging        = fullfile(dirs.summary,'imaging.mat');
mat_file.summary.selectivity    = fullfile(dirs.summary,'selectivity.mat');
mat_file.summary.transitions    = fullfile(dirs.summary,'transitions.mat');
mat_file.stats                  = fullfile(dirs.summary,'summary_stats.mat');
mat_file.validation             = fullfile(dirs.summary,'validation.mat');
%Figure Data
mat_file.figData.fovProj        = fullfile(dirs.figures,'FOV mean projections','figData.mat'); %Directory created in code block for figure

%% HYPERPARAMETERS FOR ANALYSIS

% Behavior
params.behavior.timeWindow = [-2 5]; 
params.behavior.binWidth = 0.1; %In seconds; for lick density plots
params.behavior.preCueBinWidth = 2; %In seconds; for lick density plots

% Cellular fluorescence calculations
params.fluo.exclBorderWidth     = 5; %For calc_cellF: n-pixel border of FOV to be excluded from analysis

% Interpolation and alignment
params.align.trigTimes  = 'cueTimes';
params.align.interdt    = 0.05; %Query intervals for interpolation in seconds (must be <0.5x original dt; preferably much smaller.)
params.align.window     = params.behavior.timeWindow; %Also used for bootavg, etc.

% Trial averaging
params.bootAvg.window           = params.behavior.timeWindow;
params.bootAvg.dsFactor         = 5; %Downsample from interpolated rate of 1/params.interdt
params.bootAvg.nReps            = 1000; %Number of bootstrap replicates
params.bootAvg.CI               = 95; %Confidence interval as decimal
[~ ,params.bootAvg.trialSpec]   = list_trialSpecs('bootAvg');
	
% ------- Single-unit decoding -------
% params.decode.decode_type     = ...
%     {'choice_sound','choice_action','prior_choice','prior_choice_action',...
%     'outcome','prior_outcome','rule_SL','rule_SR'}; %MUST have same number of elements as rows in trialSpec. Eg, = {'choice','outcome','rule_SL','rule_SR'}
% params.decode.trialSpec       = params.bootAvg.trialSpec; %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)

[p.decodeType, p.trialSpec]    = list_trialSpecs('bootAvg'); %Spec for each trial subset for comparison (conjunction of N fields from 'trials' structure.)
p.dsFactor        = params.bootAvg.dsFactor; %Downsample from interpolated rate of 1/params.interdt
p.nReps           = params.bootAvg.nReps; %Number of bootstrap replicates
p.nShuffle        = 1000; %Number of shuffled replicates
p.CI              = 95; %params.bootAvg.CI; %Confidence interval as percentage
p.sig_method      = 'shuffle';  %Method for determining chance-level: 'bootstrap' or 'shuffle'
p.sig_duration    = 1;  %Number of consecutive seconds exceeding chance-level
p.t0              = 0; %params.behavior.timeWindow(1);  %Use eg params.behavior.timeWindow(1), or 0 for trigger time
params.decode = p;
clearvars p;

% Transition analyses
params.transitions.window           = params.behavior.timeWindow; %Time to be considered within trial
params.transitions.nTrialsPreSwitch = 10; %Number of trials from origin and destination rules to average for comparison with transition trial(i)
params.transitions.cell_subset      = 'all'; %'significant' or 'all'; denotes whether only significantly rule-modulated cells are used
params.transitions.CI               = params.bootAvg.CI; %Threshold for significant modulation; include only significantly modulated cells
params.transitions.sig_method       = params.decode.sig_method;  %Method for determining chance-level: 'bootstrap' or 'shuffle'
params.transitions.sig_duration     = params.decode.sig_duration;  %Number of consecutive seconds exceeding chance-level
params.transitions.stat             = 'Rho'; %Statistic to use as similarity measure: {'R','Rho','Cs'}
params.transitions.nBins            = 10; %Number of bins for aggregating evolution of activity vectors

%% SUMMARY STATISTICS
params.stats.analysis_names = {'behavior','imaging','selectivity'};

%% FIGURES: COLOR PALETTE FROM CBREWER
% Color palette from cbrewer()
c = cbrewer('qual','Paired',10);
colors = {'red',c(6,:),'red2',c(5,:),'blue',c(2,:),'blue2',c(1,:),'green',c(4,:),'green2',c(3,:),...
    'purple',c(10,:),'purple2',c(9,:),'orange',c(8,:),'orange2',c(7,:)};
% Add additional colors from Set1 & Pastel1
c = cbrewer('qual','Set1',9);
c2 = cbrewer('qual','Pastel1',9);
colors = [colors {'pink',c(8,:),'pink2',c2(8,:),'gray',c(9,:),'gray2',[0.7,0.7,0.7],'black',[0,0,0]}];
cbrew = struct(colors{:}); %Merge palettes
clearvars colors

%Define color codes for cell types, etc.
cellColors = {'SST',cbrew.orange,'SST2',cbrew.orange2,'VIP',cbrew.green,'VIP2',cbrew.green2,...
    'PV',cbrew.purple,'PV2',cbrew.purple2,'PYR',cbrew.blue,'PYR2',cbrew.blue2}; 
choiceColors = {'left',cbrew.red,'left2',cbrew.red2,'right',cbrew.blue,'right2',cbrew.blue2}; %{Sound,Action}
ruleColors = {'sound',cbrew.black,'sound2',cbrew.gray,'action',cbrew.purple,'action2',cbrew.purple2,...
    'actionL',cbrew.red,'actionL2',cbrew.red2,'actionR',cbrew.blue,'actionR2',cbrew.blue2}; %{Sound,Action}
outcomeColors = {'hit',cbrew.green,'hit2',cbrew.green2,'err',cbrew.pink,'err2',cbrew.pink2,...
    'pErr',cbrew.pink,'pErr2',cbrew.pink2,'oErr',cbrew.pink,'oErr2',cbrew.pink2,...
    'miss',cbrew.gray,'miss2',cbrew.gray2};
dataColors = {'data',cbrew.black,'data2',cbrew.gray};
colors = struct(cellColors{:}, choiceColors{:}, ruleColors{:}, outcomeColors{:}, dataColors{:});

%% GLOBAL SETTINGS
params.figs.all.colors = colors;

%% FIGURE: MEAN PROJECTION FROM EACH FIELD-OF-VIEW
params.figs.fovProj.calcProj        = false; %Calculate or re-calculate projection from substacks for each trial (time consuming).
params.figs.fovProj.blackLevel      = 30; %As percentile 20
params.figs.fovProj.whiteLevel      = 99.7; %As percentile 99.7
c = [zeros(256,1) linspace(0,1,256)' zeros(256,1)];
params.figs.fovProj.colormap        = c;
params.figs.fovProj.overlay_ROIs    = true; %Overlay outlines of ROIs
params.figs.fovProj.overlay_npMasks = false; %Overlay outlines of neuropil masks
% params.figs.fovProj.expIDs          = [];
params.figs.fovProj.expIDs = {...
    '171109 M51 RuleSwitching';...
    '181010 M57 RuleSwitching';...
    '171104 M42 RuleSwitching';...
    '180831 M55 RuleSwitching'};

% For plotting only selected cells
% params.figs.fovProj.cellIDs{numel(expData)} = []; %Initialize
params.figs.fovProj.cellIDs(restrictExpIdx({expData.sub_dir},params.figs.fovProj.expIDs)) = {... % One cell per session, containing cellIDs
    {'007','014','018','021'};...
    {'002','004','007','013'};
    {'004','013','017','018'};
    {'005','007','014','030'}};

%% FIGURE: RAW BEHAVIOR
params.figs.behavior.window = params.behavior.timeWindow; 
params.figs.behavior.colors = struct('red',cbrew.red,'blue',cbrew.blue,'green',cbrew.green);

%% FIGURE: LICK DENSITY IN VARIED TRIAL CONDITIONS
params.figs.lickDensity.timeWindow = params.behavior.timeWindow; %For lick density plots
params.figs.lickDensity.binWidth = params.behavior.binWidth; 
params.figs.lickDensity.colors = {cbrew.red, cbrew.blue}; %Revise with params.figs.all.colors

%% FIGURE: CELLULAR FLUORESCENCE TIMESERIES FOR ALL NEURONS
p = params.figs.all; %Global figure settings: colors structure, etc.
[p.expIDs, p.cellIDs] = list_exampleCells('timeseries');
% p.expIDs           = [];
% p.cellIDs          = [];
p.trialMarkers     = false;
p.trigTimes        = 'cueTimes'; %'cueTimes' or 'responseTimes'
p.ylabel_cellIDs   = true;
p.spacing          = 10; %Spacing between traces in SD 
p.FaceAlpha        = 0.2; %Transparency for rule patches
p.LineWidth        = 0.5; %LineWidth for dF/F
p.Color            = struct('red',cbrew.red, 'blue', cbrew.blue); %Revise with params.figs.all.colors

params.figs.timeseries = p;
clearvars p;
%% FIGURE: TRIAL-AVERAGED CELLULAR FLUORESCENCE

% -------Trial Averaging: choice, outcome, and rule-------------------------------------------------
[p.expIDs, p.cellIDs] = list_exampleCells('bootAvg');
% params.figs.bootAvg.expIDs     = [];
% params.figs.bootAvg.cellIDs    = [];
[~, p.trialSpec]    = list_trialSpecs('bootAvg');
p.panels = list_panelSpecs('bootAvg',params);

p.xLabel          = 'Time from sound cue (s)';  % XLabel
p.yLabel          = 'Cellular Fluorescence (dF/F)';
p.verboseLegend   = false;

params.figs.bootAvg = p;
clearvars p

%% FIGURE: TIME-AVERAGED CELLULAR FLUORESCENCE (CO-PLOT SPECIFIED CELLS)

% -------Trial Averaging: All trials performed-------------------------------------------------
params.figs.timeAvg = params.figs.timeseries;
%params.figs.timeAvg.expIDs              = [];
params.figs.timeAvg.cellIDs             = [];
params.figs.timeAvg.colors              = colors; %Choice: left/hit/sound vs right/hit/sound
params.figs.timeAvg.verboseLegend       = false;
params.figs.timeAvg.panels              = [];
params.figs.timeAvg.panels.title        = 'All Trials Performed';
params.figs.timeAvg.panels.lineStyle    = {'-'};

%% FIGURE: MODULATION INDEX: CHOICE, OUTCOME, AND RULE

% Single-unit plots
p                       = params.figs.all; %Get global colors, etc.
p.fig_type              = 'singleUnit';
[p.decodeType, p.trialSpec]    = list_trialSpecs('bootAvg');
p.panels = list_panelSpecs('decode_single_units',params); %Get variables and plotting params for each figure panel
[p.expIDs,p.cellIDs]    = list_exampleCells('bootAvg'); %Same cells used for trial average and decode
% p.expIDs = []
% p.cellIDs = [];
p.shading               = params.decode.sig_method; %'shuffle' or 'bootstrap'
p.CI                    = params.decode.CI; 

params.figs.decode_single_units = p;
clearvars p ax;

% Heatmaps
params.figs.mod_heatmap.fig_type        = 'heatmap';
params.figs.mod_heatmap.xLabel          = 'Time from sound cue (s)';  % XLabel
params.figs.mod_heatmap.yLabel          = 'Cell ID (sorted)';
params.figs.mod_heatmap.datatips        = true;  %Draw line with datatips for cell/exp ID

params.figs.mod_heatmap.choice_sound.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_sound.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.choice_action.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.choice_action.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.prior_choice.cmap     = flipud(cbrewer('div', 'RdBu', 256));  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)
params.figs.mod_heatmap.prior_choice.color    = c(4,:);  %[colormap]=cbrewer(ctype, cname, ncol, interp_method)

params.figs.mod_heatmap.outcome.cmap    = cbrewer('div', 'PiYG', 256);
params.figs.mod_heatmap.outcome.color   = c(3,:);

params.figs.mod_heatmap.prior_outcome.cmap    = cbrewer('div', 'PiYG', 256);
params.figs.mod_heatmap.prior_outcome.color   = c(3,:);

params.figs.mod_heatmap.rule_SL.cmap    = [flipud(cbrewer('seq','Reds',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SL.color   = c(1,:);

params.figs.mod_heatmap.rule_SR.cmap    = [flipud(cbrewer('seq','Blues',128));cbrewer('seq','Greys',128)];
params.figs.mod_heatmap.rule_SR.color   = c(2,:);

%% FIGURE: NEURAL TRANSITIONS

params.figs.transitions.Color = {cbrew.black, cbrew.red, cbrew.gray};

%% SUMMARY FIGURE: BEHAVIORAL STATISTICS, LICK DENSITY AND DIFFERENTIAL LICK RATES
params.figs.summary_behavior.outcomes = {'hit','pErr','oErr','miss'};
params.figs.summary_behavior.timeWindow = params.behavior.timeWindow; %For lick density plots
params.figs.summary_behavior.binWidth = params.behavior.binWidth; 
params.figs.summary_behavior.colors = colors;
params.figs.summary_behavior.dotSize = 1;
params.figs.summary_behavior.boxWidth = [0.6, 0.3]; %For 1 & 2 boxes per group
params.figs.summary_behavior.lineWidth = 2;
params.figs.summary_behavior.lineStyle = {'-','-',':','-'}; %LineStyle for each outcome

%% SUMMARY FIGURE: MODULATION INDEX-----------------------------------------------

% ---Selectivity plots------------------------------------------------------------------------------

%Specify array 'f' containing variables and plotting params for each figure:
f(1).fig_name   = 'Mean_Selectivity_all';
f(1).var_name   = {'selIdx','selIdx_t'};
f(1).null_name  = {'nullIdx','nullIdx_t'};
f(1).yLims.choice = {[-0.2,0.3],[-0.1,0.15]}; %For box and line, respectively
f(1).yLims.outcome = {[-0.15,0.25],[-0.1,0.15]};
f(1).yLims.rule = {[-0.5,0.5],[-0.15,0.2]};

% f(2).fig_name   = 'Mean_Selectivity_sig';
% f(2).var_name   = {'sigIdx','sigIdx_t'};
% f(2).null_name  = {'nullIdx','nullIdx_t'};
% f(2).yLims.choice = {[],[]}; %For box and line, respectively
% f(2).yLims.outcome = {[],[]};
% f(2).yLims.rule = {[],[]};

f(2).fig_name   = 'Mean_Magnitude_all'; 
f(2).var_name   = {'selMag','selMag_t'};
f(2).null_name  = {'nullMag','nullMag_t'};
f(2).yLims.choice = {[0,0.3],[0,0.2]}; %For box and line, respectively
f(2).yLims.outcome = {[0,0.25],[0,0.2]};
f(2).yLims.rule = {[0,0.6],[0,0.2]};

f(3).fig_name   = 'Proportion_Selective';
f(3).var_name   = {'pSig', 'pSig_t'};
f(3).null_name  = {'pNull', 'pNull_t'};
f(3).yLims.choice = {[0,1],[0,0.6]}; %For box and line, respectively
f(3).yLims.outcome = {[0,1],[0,0.7]};
f(3).yLims.rule = {[0,1],[0,0.5]};

params.figs.summary_modulation.figs = f;

params.figs.summary_modulation.decodeTypes = params.decode.decodeType; %MUST have same number of elements as rows in trialSpec. Eg, = {'choice','outcome','rule_SL','rule_SR'}
params.figs.summary_modulation.titles =...
    {'Choice (sound)','Choice (action)','Prior choice (sound)','Prior choice (action)'...
    'Outcome','Prior outcome','Rule (left choice)','Rule (right choice)'};

%Appearance
params.figs.summary_modulation.dotSize  = 0.5;
params.figs.summary_modulation.lineWidth = 2;
params.figs.summary_modulation.boxWidth = 0.5; %Width of boxplot
params.figs.summary_modulation.colors = colors; %Struct contains, eg, colors.SST, colors.SST2, etc.
params.figs.summary_modulation.nullBound = 50; %Percent of distribution from eg, 9th-91st
params.figs.summary_modulation.hypothesisTest = "signrank"; %***Link to table_comparisons via params
params.figs.summary_modulation.alpha = 0.05; %***Link to table_comparisons via params

% ---Preference plot------------------------------------------------------------------------------
params.figs.summary_preference.decodeTypes  = params.figs.summary_modulation.decodeTypes;
params.figs.summary_preference.titles       = params.figs.summary_modulation.titles; %Titles (cell array)

%params.figs.summary_preference.dispersion = 'SEM'; %Bars with error bars
params.figs.summary_preference.dispersion = 'IQR'; %Boxes with whiskers

%Appearance
params.figs.summary_preference.lineWidth = 2;
params.figs.summary_preference.boxWidth = 0.25;
params.figs.summary_preference.boxColors = colors;
c = cbrewer('qual','Paired',10);
params.figs.summary_preference.colors = {c([8,4,10,2],:),c([7,3,9,1],:)}; %Swap order
params.figs.summary_preference.hypothesisTest = "signrank"; %***Link to table_comparisons via params
params.figs.summary_preference.alpha = 0.05; %***Link to table_comparisons via params

%% SUMMARY FIGURE: NEURAL TRANSITION ANALYSIS 

p(1).cellTypes      = {'SST','VIP','PV','PYR'};
p(1).transTypes     = {'actionR_sound','sound_actionL','actionL_sound','sound_actionR'}; %Order should be S-A-S-A for color order

p(2).cellTypes      = {'SST','VIP','PV','PYR'};
p(2).transTypes     = {'sound','action'}; 

p(3).cellTypes      = {'all'};
p(3).transTypes     = {'sound','action'};  

for i=1:numel(p)
p(i).stat = params.transitions.stat;
end

params.figs.summary_transitions = p;
clearvars p;

% Neurobehavioral switch
p.color = colors;
p.useChangePt = true; %Use behavioral changepouint analysis; use nTrials-20 if false
params.figs.summary_changePoints = p;
clearvars p;
