function T = table_descriptiveStats( stats )

%statsTable = struct('behavior',table(),'imaging',[],'cellFluo',[]);

%T.VariableNames = {'VarName','Mean','SEM','Median','IQR','N'}
% {Varname cellType ruleType }
% eg, stats.behavior.SST.trials2crit.sound
%% Descriptive Stats: Behavior
B = stats.behavior;
S = struct('VarName',[],'cellType',[],'ruleType',[],...
    'mean',[],'sem',[],'median',[],'IQR',[],'sum',[],'N',[]);

% Collapsed across all Rules/Cell Types

% Number of trials completed per session
%stats.behavior.SST.trialsCompleted
% S = addRow( S, 'trialsCompleted', cellType, ruleType, stats ); %eg, addRow( S, 'trials2crit', 'each', 'each', stats )
S = addRow( S, stats.behavior.SST.trialsCompleted);
% Number of blocks completed per session

% Licks/s in 2 s pre- vs post-cue

% For each Cell Type
% diff. licks/s in 2 s pre- vs post-cue

% For each Block Type:
%
% -licks/s pre- & post-cue
% -Hit & perseverative error rates in two trials surrounding rule switch (estimate from 'perfcurve')


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function S = addRow( S, stats )

%varargin for cellTypes and/or ruleTypes 
varname = inputname(2);
disp(varname);