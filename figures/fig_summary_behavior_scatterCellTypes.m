function fig = fig_summary_behavior( behavior, params )

B = behavior; %Extract pooled data from all cell-types

%% SETUP PANELS FOR PLOTTING
titles = {'Trials to Crit.','Persev. Errors','Other Errors'};
setup_figprops([]);
fig = figure('Name','Summary behavioral statistics');
fig.Position = [400 50 866 900]; %BLWH for keeping axes same size as periswitch perf
tiledlayout(2,3,'TileSpacing','none','Padding','none');
c = params.colors;
colors = {[c.sound;c.sound2];[c.action;c.action2]};

%% PLOT TOTAL TRIALS, TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% Trials to Criterion, Perseverative Errors, & Other Errors

vars = {'trials2crit','pErr','oErr'};
for i = 1:numel(vars)
%Plot data with sample median and IQR
data = [B.all.(vars{i}).sound.data, B.all.(vars{i}).action.data];
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

%% SCATTER BY CELL TYPE

% For Each Cell Type, Scatter Action Data Against Sound
cellType = fieldnames(B);
cellType = cellType(~ismember(cellType,'all'));
MarkerSize = params.dotSize*20;
for i = 1:numel(vars)
    
    ax(i+3) = nexttile;
    for j=1:numel(cellType)
        X = B.(cellType{j}).(vars{i}).sound.data;
        Y = B.(cellType{j}).(vars{i}).action.data;
        scatter(X,Y,MarkerSize,params.colors.(cellType{j}),'LineWidth',params.lineWidth); hold on;
    end
    
    xlabel('Number per sound block');
    lim = max([xlim,ylim]);
    line([0,lim],[0,lim],'LineStyle','-','LineWidth',1,'Color',params.colors.data2);
    axis square;
end

% Formatting

% YLable for first of three block averaged variables
ylabel(ax(4),'Number per action block');

%% ---INTERNAL FUNCTIONS----------------------------------------------------------------------------

%% Setup Axes
function axes_handle = setupAxes( axes_handle, yMin, yMax, boxWidth, xLabels )
%Arg check
if nargin<4
    boxWidth = [];
    xLabels = axes_handle.XLabel;
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