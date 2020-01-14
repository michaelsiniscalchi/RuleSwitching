function fig = fig_summary_transitions( T, params )

% Get Cell Types & Rule Transition Types
cellTypes = params.cellTypes;
transTypes = params.transTypes;

%Initialize Figure
figName = ['Evolution of Population Activity Following Rule Switch ('...
    num2str(numel(cellTypes)) ' celltypes ' num2str(numel(transTypes)) ' transtypes) ' params.stat];
fig = figure('Name',figName);
fig.Position = [50 50 250*numel(transTypes) 450*numel(cellTypes)];
setup_figprops([]);
t = tiledlayout(numel(cellTypes),numel(transTypes),'TileSpacing','none','Padding','none');
ax = gobjects(t.GridSize);
color = repmat({'k','r'},1,numel(transTypes)/2);

X = T.all.all.binIdx(1,:); %Get bin idxs
for i = 1:numel(cellTypes)
    for j = 1:numel(transTypes)
        ax(i,j) = nexttile; hold on;
        Y = T.(cellTypes{i}).(transTypes{j}).binValues.mean;
        CI = Y + [T.(cellTypes{i}).(transTypes{j}).binValues.sem;...
            -T.(cellTypes{i}).(transTypes{j}).binValues.sem];
        errorshade(X,CI(2,:),CI(1,:),color{j},0.2);
        plot(X,Y,color{j});
        axis square;
    end
end

% Formatting
for j = 1:numel(transTypes)
    %Title for top row
    [C,matches] = strsplit(transTypes{j},'_');
    if ~isempty(matches)
        str = [upper(C{1}(1)) C{1}(2:end) '->' upper(C{2}(1)) C{2}(2:end)];
    else
        str = ['->' upper(C{1}(1)) C{1}(2:end)];
    end
    title(ax(1,j),str); 
    %XLabel bottom row
    xlabel(ax(numel(cellTypes),j),'# bins from rule switch');
end
for i = 1:numel(cellTypes)
    %Scale axes and plot X=0 & Y=0
    ylims = max(abs([ax(i,:).YLim])); 
    ylim(ax(i,:),[-ylims,ylims]);
    for j = 1:numel(transTypes)
    plot(ax(i,j),xlim(ax(i,j)),[0,0],':k','LineWidth',1);
    plot(ax(i,j),[0,0],[-ylims,ylims],':k','LineWidth',1);
    end
    %YLabel left column
    str = [upper(cellTypes{i}(1)) cellTypes{i}(2:end) ' cells'];
    ylabel(ax(i,1),{str;'Similarity index'});
end
