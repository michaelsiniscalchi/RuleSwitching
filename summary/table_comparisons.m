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
[dataStruct, stats] = addComparison(...
    dataStruct,B.all,{"lickRates","preCue",["diff_sound","diff_actionL","diff_actionR"]},'ranova'); %Report mean & sem
dataStruct = addComparison(...
    dataStruct,B.all,{"lickRates","postCue",["diff_sound","diff_actionL","diff_actionR"]},'ranova'); %Report mean & sem


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
disp();


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function [data_struct, stats] = addComparison( data_struct, stats_struct, comp_spec, test_stat )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'comp_spec', A cell array specifying hierarchy of fields containing variables for comparison.

%% Fixed parameters
alpha = 0.5; %Alpha, threshold parameter for hypothesis testing

%% Extract Data for Comparisons

% Follow structure to specified terminal fields
fields = []; 
for i = 1:numel(comp_spec)
    nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
    if length(comp_spec{i})==1                               %Individual fieldnames specified as char
        copyField = repmat(comp_spec{i},nCopies,1);   %Copy new fieldname for each existing higher-order field
        fields = [fields,copyField];
    else 
        copyField = repmat(comp_spec{i},1,nCopies);   %Duplicate new fields for each existing row, eg, ['a','a','a';'b','b','b']
        copyField = reshape(copyField',numel(copyField),1); %Transpose and reshape to column vector, eg, ['a';'a';'a';'b';'b';'b']
        fields = repmat(fields,numel(comp_spec{i}),1);       %Copy higher-order fields for each subordinate field specified
        fields = [fields, copyField];                     %Append new set of fieldnames
    end
end

% Extract specified data from 'stats'
len = length(data_struct);
for i = 1:size(fields,1)
    %Reduce struct to specified terminal field if present
    s = stats_struct;
    for j = 1:size(fields,2)
        if isfield(s,fields(i,j))
            s = s.(fields(i,j));
        end
    end
    %Aggregate data from each terminal field 
    if isfield(s,'data')
        data{i,1} = s.data; %Must be column vector
        group{i,1} = i*ones(size(s.data));
    end
end
group = cell2mat(group); %Column vector as factor for column data (>1 comparison)

%% Perform hypothesis tests

% Initialize output fields as variables
diff = [];
stats_str = [];
comparison = comp_spec{cellfun(@length,comp_spec)>1}; %The unique cell containing multiple fields
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
        data = cell2mat(data); %'data' must be column array of cells each containing a single column vector
        [p,tbl,stats] = anova1(data,group,displayopt);
        df_grp = num2str(numel(stats.n)-1);
        df_err = num2str(stats.df);
        F = num2str(tbl{2,strcmp(tbl(1,:),'F')});
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
    case 'kruskalwallis' %For across cell-types **Independence**
        data = cell2mat(data);
        [p,~,stats] = kruskalwallis(data,group,displayopt);
    case 'friedman' %For across block-types **Repeated Measures**
        M = cell2mat(data);
        [p,tbl,stats] = friedman(M,1,displayopt); %Second arg, 'reps' is replicates per subject; assume independence between rows
    case 'ranova' %For across block-types **Repeated Measures**        
        expNum = string((1:N)');
        between = table(expNum); %Between subject effect: session number
        for i = 1:numel(data)
            between.(comparison(i)) = data{i};
        end
        within = table(comparison','VariableNames',{'Comparison'});
        modelSpec = strcat(comparison(1),'-',comparison(end),' ~ 1'); %*NOTE: completely within subject design
        stats = fitrm(between,modelSpec,'WithinDesign',within); %Here, 'stats' is a RepeatedMeasuresModel
        tbl = ranova(stats);
        p = num2str(tbl.pValue(1,:));
        df_grp = num2str(tbl.DF(1));
        df_err = num2str(tbl.DF(2));
        F = num2str(tbl.F(1,:));
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
        %tbl = multcompare(rm,'Comparison'); %Return rm as 'stats'...remember proper syntax for this multcompare
end

%Append additional fields from 'dataStruct'
varName = strjoin([comp_spec{cellfun(@length,comp_spec)==1}],'_'); 

if any(strcmp(comparison,"SST"))
    comparison = "Cell types";
elseif any(strcmp(comparison,"diff_actionL"))
    comparison = "Block types";
else, comparison = strjoin(comparison);
end

d = struct('varName',varName,'comparison',comparison,'diff',num2str(diff),'p',num2str(p),'N',num2str(N),'testName',test_stat,'stats',stats_str);
data_struct(len+1,1) = d;


%Restrict to populated rows 
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);

%%
% %Post-hoc Multiple comparisons
% if p<alpha && numel(data)>2
%     c = multcompare(stats);
%     idx = c(:,end)<alpha;
% end
