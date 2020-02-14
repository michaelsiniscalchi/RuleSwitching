function [ T, dataStruct ] = table_comparisons( stats )

%% DEFINE AND INITIALIZE COMMON VARIABLES
dataStruct = struct('varName',[],'comparison',[],'diff',[],'p',[],'N',[],'testName',[],'stats',[]); %String 'stats' for F(df), t(df), W, etc.

cellTypes = ["SST", "VIP", "PV", "PYR"]'; %Column vectors
ruleTypes = ["sound", "action"]';
outcomeTypes = ["hit","pErr","oErr","miss"]';

B = stats.behavior;
I = stats.imaging;
S = stats.selectivity;

% NOTES:    '{}' in first cell of var_spec reserved for 'cellTypes'.
%           '{}' in last cell of var_spec reserved for 'ruleTypes'.

%% FORMAL COMPARISONS: BEHAVIOR

% *** Collapsed across all Rules/Cell Types ***

% Mean Licks/s pre- vs post-cue
dataStruct = addComparison(...
    dataStruct, B.all, {"lickRates", ["preCue","postCue"],"completed"}, 'ttest'); %Report mean & sem

% Mean Licks/s post-cue for hit vs error trials
dataStruct = addComparison(...
    dataStruct, B.all, {"lickRates","postCue",["hit","err"]}, 'ttest'); %Report mean & sem; **also examined pre-cue - very small (~0.1 Hz sig diff)

% Mean Licks/s pre-cue for sound vs action trials (No overall increase in anticipatory licking)
dataStruct = addComparison(...
    dataStruct, B.all, {"lickRates","preCue",["sound","action"]}, 'ttest'); %Report mean & sem

% Mean Licks/s pre- & post-cue for left vs right ports (Very mild overall Right-bias)
dataStruct = addComparison(...
    dataStruct, B.all, {"lickRates","preCue",["lickL","lickR"]}, 'ttest'); %Report mean & sem
dataStruct = addComparison(...
    dataStruct, B.all, {"lickRates","postCue",["lickL","lickR"]}, 'ttest'); %Report mean & sem

% Difference in Left vs Right Lick Rate across Block Types, Post-Cue (Clear differential response to cues across block types)
wsFactors = ["Cue","BlockType"];
[dataStruct, ~] = addComparison(dataStruct,B.all,...
    {"lickDiffs","preCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
[dataStruct, stats] = addComparison(dataStruct,B.all,...
    {"lickDiffs","postCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
multComp.lickDiffs = multcompare(stats,'BlockType');



%% FORMAL COMPARISONS: MODULATION

% Choice selectivity: Proportion Selective & Mean Magnitude
[dataStruct, stats] = addComparison(...
    dataStruct,S,{"choice_sound",cellTypes,"pSig"},'anova1'); %Report mean & sem
% c = multcompare(stats);
% idx = c(:,end)<0.05;
dataStruct = addComparison(...
    dataStruct,S,{"choice_sound",cellTypes,"selMag"},'anova1'); %Report mean & sem






%% RETURN DATA STRUCTURE AS TABLE

T = dataStruct;
T = struct2table(T);
disp(T);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function [data_struct, stats] = addComparison( data_struct, stats_struct, comp_spec, test_stat, wsFactors )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'comp_spec', A cell array specifying hierarchy of fields containing variables for comparison.

%% Fixed parameters
alpha = 0.5; %Alpha, threshold parameter for hypothesis testing

%% Extract Data for Descriptive Stats or Comparisons
[ data, group ] = getStatsData( stats_struct, comp_spec);

%% Perform hypothesis tests

% Initialize output fields as variables
diff = [];
stats_str = [];
comparison = comp_spec{cellfun(@length,comp_spec)>1}; %For 1-way comparisons, the unique cell containing multiple fields
N = cellfun(@length,data');
if numel(unique(N))==1
    N = unique(N);
end

% Perform specified statistical test
displayopt = 'on'; %***For DEVO
switch test_stat
    case 'signrank' %Across rule types or pre/post-cue 
        [p,~,stats] = signrank(data{1},data{2});
        diff = median(data{2}-data{1});
        stats_str = ['W = ' num2str(stats.signedrank)]; %W statistic
    case 'ttest' %Across rule types or pre/post-cue 
        [~,p,~,stats] = ttest(data{1},data{2});
        diff = mean(data{2}-data{1});
        stats_str = ['t(' num2str(stats.df) ')=' num2str(abs(stats.tstat))];
    case 'ranksum'
        [p,~,stats] = ranksum(data{1},data{2});
        stats_str = ['W = ' num2str(stats.ranksum)]; %W statistic (if U is required, more calculation necessary...)
    case 'ttest2' 
        [~,p] = ttest2(data{1},data{2});
        diff = mean(data{1})-mean(data{2});
    case 'anova1' %For across cell-types **Independence**
        %Construct grouping & data vectors
        grp = [];
        for i = 1:numel(data)
            grp = [grp; repmat(group(i),numel(data{i}),1)]; %#ok<AGROW>
        end
        data = cell2mat(data); %'data' must be column array of cells each containing a single column vector
        %Do 1-way ANOVA
        [p, tbl, stats] = anova1(data, grp, displayopt);
        df_grp = num2str(numel(stats.n)-1);
        df_err = num2str(stats.df);
        F = num2str(tbl{2,strcmp(tbl(1,:),'F')});
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
    case 'kruskalwallis' %For across cell-types **Independence**
        data = cell2mat(data);
        [p,~,stats] = kruskalwallis(data,group,displayopt);
    case {'ranova'} %For across block-types: 1-way Repeated Measures ANOVA  
        %Between Subject Factors
        between = table(string((1:N)')); %Between subject effect: session number
        for i = 1:size(group,1)
                response(i) = strjoin(group(i,:),'_');
                between.(response(i)) = data{i}; %Response variables
        end
        modelSpec = strcat(response(1),'-',response(end),' ~ 1'); %*NOTE: completely within subject design tests intercept
        %Within Subject Factors
        within = table();
        for i = 1:size(group,2)
            within.(wsFactors{i}) = group(:,i);
        end
        withinModel = strcat(wsFactors{1},'*',wsFactors{end});
        %Fit Model and Perform Repeated Measures ANOVA
        stats = fitrm(between,modelSpec,'WithinDesign',within); %Here, 'stats' is a RepeatedMeasuresModel
        tbl = ranova(stats,'WithinModel',withinModel);
        p = num2str(tbl.pValue(1,:));
        df_grp = num2str(tbl.DF(1));
        df_err = num2str(tbl.DF(2));
        F = num2str(tbl.F(1,:));
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
end

%Append additional fields from 'dataStruct'
varName = strjoin([comp_spec{cellfun(@length,comp_spec)==1}],'_'); 

if any(strcmp(comparison,"SST"))
    comparison = "Cell types";
elseif exist('wsFactors','var')
    comparison = strjoin(wsFactors);
else, comparison = strjoin(comparison);
end

d = struct('varName',varName,'comparison',comparison,'diff',num2str(diff),'p',num2str(p),'N',num2str(N),'testName',test_stat,'stats',stats_str);
data_struct(length(data_struct)+1,1) = d;


%Restrict to populated rows 
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);

%%
% %Post-hoc Multiple comparisons
% if p<alpha && numel(data)>2
%     c = multcompare(stats);
%     idx = c(:,end)<alpha;
% end
