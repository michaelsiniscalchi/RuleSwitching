function T = table_descriptiveStats( stats )

%statsTable = struct('behavior',table(),'imaging',[],'cellFluo',[]);

%T.VariableNames = {'VarName','Mean','SEM','Median','IQR','N'}

%% Descriptive Stats: Behavior
B = stats.behavior;

% Collapsed across all Rules/Cell Types

% Number of trials completed per session
S = addRow( S, '', stats );

% Number of blocks completed per session

% Licks/s in 2 s pre- vs post-cue

% For each Cell Type
% diff. licks/s in 2 s pre- vs post-cue

% For each Block Type:
%
% -licks/s pre- & post-cue
% -Hit & perseverative error rates in two trials surrounding rule switch (estimate from 'perfcurve')


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function S = addRow( S, VarName, stats )

%varargin for cellTypes and/or ruleTypes 
%Flag for 