function fig = fig_summary_behavior_performance( behavior, cellType, params )

B = behavior.(cellType); %Extract cell-type specific data

%% SETUP PANELS FOR PLOTTING
titles = {'Trials to Crit.','Persev. Errors','Other Errors'};

setup_figprops([]);
fig = figure('Name',['Summary behavioral statistics - ' cellType]);
fig.Position = [400 400 800 500]; %BLWH
tiledlayout(1,3,'TileSpacing','none','Padding','none')
ax = gobjects(3,1);
c = params.colors;
colors = {[c.sound;c.sound2];[c.action;c.action2]};

%% PLOT TOTAL TRIALS, TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% Trials to Criterion, Perseverative Errors, & Other Errors

vars = {'trials2crit','pErr','oErr'};
for i = 1:numel(vars)
%Plot data with sample median and IQR
data = [B.(vars{i}).sound.data, B.(vars{i}).action.data];
ax(i) = nexttile;

%Setup axes must ahead of beeswarm()
ax(i) = setupAxes(ax(i),0,max(data(:)),params.boxWidth,{'Sound','Action'}); %setupAxes(axes_handle,yMin,yMax,boxWidth,xLabels)
ax(i).PlotBoxAspectRatio = [1,2,1];
%Equal YLims for two error types
if i==3
    ax(i).YLim = ax(2).YLim;
end
%Plot data with sample median and IQR
plot_swarms(ax(i),data,colors,params.dotSize,params.lineWidth,params.boxWidth); %(ax,data,colors,dotSize,lineWidth,boxWidth,offset)
% axis(ax(i),'square');
title(titles{i}); %Title

end

%% Additional Formatting

% YLabel & Box
ylabel(ax(1),'Number of trials per block');
set(ax,'Box','off'); %Box off for all
% Drop YAxis on second error plot
ax(3).YAxis.Visible = 'off';

%% ---INTERNAL FUNCTIONS----------------------------------------------------------------------------

%% Setup Axes
function axes_handle = setupAxes( axes_handle, yMin, yMax, boxWidth, xLabels )
%Arg check
if nargin<4
    boxWidth = [];
    xLabels = [];
end
%Set YLims 
yRng = yMax - yMin; %Range
if yMin<0
    axes_handle.YLim = [yMin-0.1*yRng, yMax+0.2*yRng];
else
    axes_handle.YLim = [0, yMax+0.2*yRng];
end
%Set XAxis Properties
if ~isempty(boxWidth) %If box/swarm
    axes_handle.XLim = [1-(boxWidth) numel(xLabels)+(boxWidth)];
    axes_handle.XTick = 1:numel(xLabels); %Box/bar/swarm chart: titles and labels
    axes_handle.XTickLabels = xLabels;
else %If line
    
end
axes_handle.Layer = 'top'; %Make sure patches, etc are behind axes