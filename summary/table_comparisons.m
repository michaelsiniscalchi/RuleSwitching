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

%% DESCRIPTIVE STATS: BEHAVIOR

% *** Collapsed across all Rules/Cell Types ***

% Licks/s pre- vs post-cue
% dataStruct = addComparison(...
%     dataStruct, B.all, {"lickRates", ["preCue","postCue"],"completed"}, 'ttest'); %Report mean & sem
% dataStruct = addComparison(dataStruct,B.all,{"lickRates",["preCue","postCue"],"completed"},'ttest'); %Report mean & sem
% dataStruct = addComparison(dataStruct,B.all,{"lickRates",["preCue","postCue"],"completed"},'ranksum'); %Report mean & sem
% 
% dataStruct = addComparison(dataStruct,B,{cellTypes, "lickRates","preCue","completed"},'kruskalwallis'); %Report mean & sem
% dataStruct = addComparison(dataStruct,B,{cellTypes, "lickRates","preCue","completed"},'anova1'); %Report mean & sem

% Difference in Left vs Right Lick Rate across Block Types
dataStruct = addComparison(...
    dataStruct,B.all,{"lickRates","postCue",["diff_sound","diff_actionL","diff_actionR"]},'ranova'); %Report mean & sem
% dataStruct = addComparison(...
%     dataStruct,B.all,{"lickRates","postCue",["diff_sound","diff_actionL","diff_actionR"]},'friedman'); %Report mean & sem

%% RETURN DATA STRUCTURE AS TABLE

T = dataStruct;
% T = rmfield(T,["data","expID"]);
% T = struct2table(T);
% disp(T);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function [data_struct, mult_comp] = addComparison( data_struct, stats, comp_spec, test_stat, alpha )

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
    s = stats;
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
        diff = median(data{1}-data{2});
        stats_str = ['W = ' num2str(stats.signedrank)]; %W statistic
    case 'ttest' %Across rule types or pre/post-cue 
        [~,p,~,stats] = ttest(data{1},data{2});
        diff = mean(data{1}-data{2});
        stats_str = ['t(' num2str(stats.df) ')=' num2str(stats.tstat)];
    case 'ranksum'
        [p,~,stats] = ranksum(data{1},data{2});
        stats_str = ['W = ' num2str(stats.ranksum)]; %W statistic (if U is required, more calculation necessary...)
    case 'ttest2' 
        [~,p] = ttest2(data{1},data{2});
        diff = mean(data{1})-mean(data{2});
        stats_str = ["diff =" num2str(diff)];
    case 'anova1' %For across cell-types **Independence**
        data = cell2mat(data); %'data' must be column array of cells each containing a single column vector
        group = cell2mat(group); %Same for 'group'
        [p,tbl,stats] = anova1(data,group,displayopt);
        df_grp = num2str(numel(stats.n)-1);
        df_err = num2str(stats.df);
        F = num2str(tbl{2,strcmp(tbl(1,:),'F')});
        stats_str = ['F(' df_grp ',' df_err ')=' F]; %Critical value
    case 'kruskalwallis' %For across cell-types **Independence**
        [p,~,stats] = kruskalwallis(data,group,displayopt);
    case 'friedman' %For across block-types **Repeated Measures**
        M = cell2mat(data');
        [p,tbl,stats] = friedman(M,1,displayopt); %Second arg, 'reps' is replicates per subject; assume independence between rows
    case 'ranova' %For across block-types **Repeated Measures**        
        expNum = string((1:N)');
        between = table(expNum); %Between subject effect: session number
        for i = 1:numel(data)
            between.(comparison(i)) = data{i};
        end
        within = table(comparison','VariableNames',{'Comparison'});
        modelSpec = strcat(comparison(1),'-',comparison(end),' ~ 1');
        rm = fitrm(between,modelSpec,'WithinDesign',within);
        tbl = ranova(rm);
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
elseif any(strcmp(comparison,"actionL"))
    comparison = "Block types";
else, comparison = strjoin(comparison);
end

d = struct('varName',varName,'comparison',comparison,'diff',diff,'p',p,'N',N,'testName',test_stat,'stats',stats_str);
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
