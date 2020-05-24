function fig = fig_summary_periswitch_performance( behavior, cellType, params )

%NOTE: output of summary_behavior was used; stats.behavior could also be
%       used as input, eliminating the need to calculate mean, sem, etc... (200207mjs)

% Setup Figure for Plotting
fig = figure('Name',['Periswitch peformance curve - ' cellType]);
fig.Position = [400 50 500 900]; %BLWH
setup_figprops([]);
tiledlayout(3,1,'TileSpacing','none','Padding','none');
ax = gobjects(3,1);
transparency = 0.2;

switchType = {'sound','action','all'};
outcomes = params.outcomes;
X = -20:19;

for i = 1:numel(switchType)
ax(i) = nexttile;
hold on;
    for j=1:numel(outcomes)
        
        data = behavior.(cellType).perfCurve.(outcomes{j}).(switchType{i}).data; 
        M = mean(data);
        sem = std(data)/sqrt(size(data,1));
        CI = M + [-sem; sem];
        
        errorshade(X,CI(1,:),CI(2,:),params.colors.(outcomes{j}),transparency);
        p(j) = plot(X,M,'Color',params.colors.(outcomes{j}),'LineStyle',params.lineStyle{j});
        
    end
    plot([0 0],[0 1],'k:','LineWidth',get(groot,'DefaultAxesLineWidth')); %First trial post-switch
    title([upper(switchType{i}(1)) switchType{i}(2:end)]);
    ylabel('Proportion of trial outcomes');
    axis square;
end
ax(1).XTickLabel = [];
ax(2).XTickLabel = [];
xlabel(ax(3),'Trials from rule switch');

%Legend
lgd = legend(ax(1),p,'Location','northeastoutside');
lgd.String = params.outcomes;