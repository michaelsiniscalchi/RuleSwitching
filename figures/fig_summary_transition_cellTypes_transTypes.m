function fig = fig_summary_transitions( T, cellTypes, transTypes )

% % Get Cell Types
% cellTypes = fieldnames(T);
% cellTypes = cellTypes(~strcmp(cellTypes,'all')); %Exclude field 'all'

%Initialize Figure
fig = figure('Name','Evolution of Population Activity Following Rule Switch (by cell type)');
fig.Position = [50 50 1000 900];
setup_figprops([]);
t = tiledlayout(numel(cellTypes),numel(transTypes),'TileSpacing','none','Padding','none');
ax = gobjects(t.GridSize);
color = repmat({'r','k'},1,numel(transTypes)/2);

X = T.all.all.binIdx(1,:); %Get bin idxs
for i = 1:numel(cellTypes)
    for j = 1:numel(transTypes)
        ax(i,j) = nexttile; hold on;
        Y = T.(cellTypes{i}).(transTypes{j}).bins.mean;
        CI = Y + [T.(cellTypes{i}).(transTypes{j}).bins.sem;...
            -T.(cellTypes{i}).(transTypes{j}).bins.sem];
        errorshade(X,CI(2,:),CI(1,:),color{j},0.2);
        plot(X,Y,color{j});
        axis square;
    end
end

% Formatting
for j = 1:numel(transTypes)
    %Title for top row
    C = strsplit(transTypes{j},'_');
    C = [upper(C{1}(1)) C{1}(2:end) '->' upper(C{2}(1)) C{2}(2:end)];
    title(ax(1,j),C); 
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
    ylabel(ax(i,1),{cellTypes{i};'Similarity index'});
end
