function fig = fig_transitions_binned( transitions, params )

setup_figprops('timeseries');

T = transitions;
fig = figure('Name',[T.sessionID ' ' T.params.stat],'Visible','off');
fig.Position = [100,100,900,600];
tiledlayout(1,2);

% Plot Mean Binned Similarity Index For Rule
rule = {'sound','action'};
titles = {'Action->Sound','Sound->Action'}; 
X = T.similarity.binIdx;
for i = 1:numel(rule)
    ax(i) = nexttile; %#ok<AGROW>
    for j = 1:size(T.aggregate.(rule{i}),1)
        Y = T.aggregate.(rule{i})(j,:);
        plot(X,Y,'Color',params.Color{3},'Marker','none','LineWidth',1); hold on;
    end
    Y = mean(T.aggregate.(rule{i}),1);
    plot(X,Y,'Color',params.Color{i},'Marker','none','LineWidth',3);
    title(titles{i});
    ylabel([T.params.stat '(dest) - ' T.params.stat '(origin)']);
    axis square;
end

% Standardize YLims
lims = cell2mat(ylim(ax));
set(ax,'YLim',[min(lims(:)) max(lims(:))]);

% Formatting
for j=1:numel(ax)
    plot(ax(j),[0,0],ylim,':k','LineWidth',1); %Plot t0
    xlabel(ax(j),'Number of bins from rule switch');
    ax(j).XTick = X;
    box(ax(j),'off');
end