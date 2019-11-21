function fig = fig_summary_periswitch_performance( behavior, cellType, params )

fig = figure('Name',['Periswitch peformance curve - ' cellType]);
fig.Position = [200 400 1200 400];

setup_figprops([]);
transparency = 0.2;
switchType = fieldnames(behavior.(cellType).perfCurve);
X = -20:19;

for i = 1:numel(switchType)
    ax(i) = subplot(1,3,i);  hold on
    for j=1:numel(params.outcomes)
        
        data = behavior.(cellType).perfCurve.(switchType{i}).(params.outcomes{j});
        M = mean(data);
        sem = std(data)/sqrt(size(data,1));
        CI = M + [-sem; sem];
        
        errorshade(X,CI(1,:),CI(2,:),params.colors{j},transparency);
        p(j) = plot(X,M,'Color',params.colors{j},'LineStyle',params.LineStyle{j});
        
    end
    plot([0 0],[0 1],'k:','LineWidth',get(groot,'DefaultAxesLineWidth')); %First trial post-switch
    title([upper(switchType{i}(1)) switchType{i}(2:end)]);
    xlabel('Trials from rule switch');
    axis square;
end
ylabel(ax(1),'Proportion of trial outcomes');
lgd = legend(ax(3),p,'Location','northeast');
lgd.String = params.outcomes;