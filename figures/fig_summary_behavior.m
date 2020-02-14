function fig = fig_summary_behavior( behavior, params )

B = behavior; %Extract pooled data from all cell-types

%% SETUP PANELS FOR PLOTTING
titles = {'Trials to Crit.','Persev. Errors','Other Errors'};
setup_figprops([]);
fig = figure('Name','Summary behavioral statistics');
fig.Position = [400 50 866 900]; %BLWH for keeping axes same size as periswitch perf
tiledlayout(2,3,'TileSpacing','none','Padding','none');
ax = gobjects(6,1);

%% PLOT TOTAL TRIALS, TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% Bee Swarm: Trials to Criterion, Perseverative Errors, & Other Errors

vars = {'trials2crit','pErr','oErr'};
for i = 1:numel(vars)
    %Setup axes ahead of beeswarm()
    data = [B.all.(vars{i}).sound.data, B.all.(vars{i}).action.data]; %Pooled data from all cell-types
    ax(i) = nexttile;
    ax(i).YLim = [0, 1.1*max(data(:))];
    ax(i).XLim = [0 3];
    ax(i).XTickLabel = {'Sound','Action'};
    %Equal YLims for two error types
    if i==3
        ax(i).YLim = ax(2).YLim;
    end
    %Plot data with sample median and IQR
    plot_swarms(ax(i),data,params.ruleColors(:),0.5);
    title(titles{i}); %Title
    
    ylims(i,:) = ylim; %#ok<AGROW> %Store ylims for later standardization
end

% Formatting

%Set YLims for Error Plots
ylims = ylims(2:3,:);
ylim(ax(2:3),[min(ylims(:)) max(ylims(:))]);
ax(3).YAxis.Visible = 'off';

%YLabel & Box
ylabel(ax(1),'Number per block');
% set(ax(1:3),'Box','off','XTick',[1,2],'XTickLabel',{'Sound','Action'},'PlotBoxAspectRatio',[2,4,1]); %Box off for all
set(ax(1:3),'Box','off','XTick',[1,2],'XTickLabel',{'Sound','Action'}); %Box off for all

%% SCATTER BY CELL TYPE

% SETUP PANELS FOR PLOTTING

MarkerSize = 20;
MarkerWidth = 2;
LineWidth = 1;

% For Each Cell Type, Scatter Action Data Against Sound
cellType = fieldnames(B);
cellType = cellType(~ismember(cellType,'all'));
for i = 1:numel(vars)
    
    ax(i+3) = nexttile;
    
    for j=1:numel(cellType)
        X = B.(cellType{j}).(vars{i}).sound.data;
        Y = B.(cellType{j}).(vars{i}).action.data;
        scatter(X,Y,MarkerSize,params.cellColors{j},'LineWidth',MarkerWidth); hold on;
    end
    
    xlabel('Number per sound block');
    axis square
    lim = max([xlim,ylim]);
    line([0,lim],[0,lim],'LineStyle',':','LineWidth',LineWidth,'Color','k');
    
end

% Formatting

% YLable for first of three block averaged variables
ylabel(ax(4),'Number per action block');