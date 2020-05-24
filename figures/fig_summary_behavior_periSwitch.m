function fig = fig_summary_behavior_periSwitch( behavior, cellType, params )

%% Extract cell-type specific data
pre  = behavior.(cellType).perfLastTrial;
post = behavior.(cellType).perfNextTrial;

%% SETUP PANELS FOR PLOTTING
titles = {'Hits','Perseverative Errors','Other Errors','Misses'};

setup_figprops([]);
fig = figure('Name',['Summary periswitch performance - ' cellType]);
fig.Position = [100 200 950 450]; %BLWH
tiledlayout(2,4,'TileSpacing','none','Padding','none')
ax = gobjects(2,4);
c = params.colors;
transparency = 0.4; %For fill inside box plots

%% PLOT HIT, ERROR, AND MISS RATES SURROUNDING RULE SWITCH
rule = {'sound','action'};
var = {'hit','pErr','oErr','miss'};
for i = 1:numel(rule)
    for j = 1:numel(var)
        % Boxplot data pre- and post-switch
        data = [pre.(var{j}).(rule{i}).data, post.(var{j}).(rule{i}).data];
        ax(i,j) = nexttile;
        
        %Setup axes must ahead of beeswarm()
        ax(i,j) = setupAxes(ax(i,j),0,1,params.boxWidth,{'Pre','Post'}); %setupAxes(axes_handle,yMin,yMax,boxWidth,xLabels)
        ax(i,j).PlotBoxAspectRatio = [1,2,1];
        %Equal YLims for two error types
        if strcmp(var{j},'oErr')
            ax(i,j).YLim = ax(i,strcmp(var,'pErr')).YLim;
        end
        %Plot data as swarm with sample median and IQR
        %colors(1:2) = {[c.(var{j}); c.([var{j},'2'])]}; 
        %plot_swarms(ax(i,j),data,colors,params.dotSize,params.lineWidth,params.boxWidth(1)); %(ax,data,colors,dotSize,lineWidth,boxWidth,offset)
        
        % Simple box plots
        for k = 1:size(data,2)
            plot_basicBox(k,data(:,k),params.boxWidth(1),params.lineWidth,params.colors.(var{j}),transparency)
        end
        title(titles{j}); %Title
          
        % Y TickLabels and Labels only on the first column
        if j>1
            ax(i,j).YTickLabel = [];
        end
    end
end
ax(1,1).YLabel.String = ["Sound Rule:"; "Proportion of trials"];
ax(2,1).YLabel.String = ["Action Rule:"; "Proportion of trials"];

%% Additional Formatting

% YLabel & Box
set(ax,'Box','off'); %Box off for all

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
% axes_handle.YLim = [0, yMax+0.2*yRng];
axes_handle.YLim = [0, 1]; %For proportions, 0 to 1

%Set XAxis Properties
if ~isempty(boxWidth(1)) %If box/swarm
    axes_handle.XLim = [1-(boxWidth(1)) numel(xLabels)+(boxWidth(1))];
    axes_handle.XTick = 1:numel(xLabels); %Box/bar/swarm chart: titles and labels
    axes_handle.XTickLabels = xLabels;
else %If line
    
end
axes_handle.Layer = 'top'; %Make sure patches, etc are behind axes