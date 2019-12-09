function fig = fig_summary_scatter_perf( behavior, params )

%% EXTRACT DATA AND CELL TYPES
B = behavior;
cellType = fieldnames(B);
cellType = cellType(~ismember(cellType,'all'));

%% SETUP PANELS FOR PLOTTING

titles = {'Trials to Crit.','Persev. Errors','Other Errors'};
MarkerSize = 20;
MarkerWidth = 2;
LineWidth = 1;

setup_figprops([]);
fig = figure('Name','Summary behavioral statistics (scatter)');
fig.Position = [400 400 1000 500]; %BLWH
tiledlayout(1,3);
ax = gobjects(3,1);

%% PLOT TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% Trials to Criterion, Perseverative Errors, & Other Errors

%Scatter action data against sound
vars = {'trials2crit','pErr','oErr'};
for i = 1:numel(vars)
    %Plot population median for each cell type
    ax(i) = nexttile;

    for j=1:numel(cellType)
        X = B.(cellType{j}).(vars{i}).sound.data;
        Y = B.(cellType{j}).(vars{i}).action.data;
        scatter(X,Y,MarkerSize,params.cellColors{j},'LineWidth',MarkerWidth); hold on;
    end
    
    title(titles{i}); %Title
    xlabel('Number per sound block');
    axis square
    lim = max([xlim,ylim]);
    line([0,lim],[0,lim],'LineStyle',':','LineWidth',LineWidth,'Color','k');

end

%% Formatting

% YLable for first of three block averaged variables
ylabel(ax(1),'Number per action block');

