function fig = fig_summary_transitions_transTypes( T )

transTypes = {'sound','action'};

% Initialize Figure
fig = figure('Name','Evolution of Population Activity Following Rule Switch');
fig.Position = [50 50 1400 400];
setup_figprops([]);
tiledlayout(1,numel(transTypes));
color = repmat({'r','k'},1,numel(transTypes)/2);

% Plot Similarity Index as a Function of Bins from Rule Switch
X = T.all.all.binIdx(1,:);
for i = 1:numel(transTypes)
    
    ax(i) = nexttile; hold on;
    Y = T.all.(transTypes{i}).bins.mean;
    CI = Y + [T.all.(transTypes{i}).bins.sem; -T.all.(transTypes{i}).bins.sem];
    errorshade(X,CI(2,:),CI(1,:),color{i},0.2);
    plot(X,Y,color{i});
    
    %Title
    C = strsplit(transTypes{i},'_');
    C = [upper(C{1}(1)) C{1}(2:end) '->' upper(C{2}(1)) C{2}(2:end)];
    title(C);
    
    %Axes labels
    xlabel('Number of bins from rule switch');
    ylabel('Similarity index');
    axis square;
    
end

%Scale axes and plot X=0 & Y=0
ylims = max(abs([ax(:).YLim]));
ylim(ax(:),[-ylims,ylims]);
for i = 1:numel(transTypes)
    plot(ax(i),xlim(ax(i)),[0,0],':k','LineWidth',1);
    plot(ax(i),[0,0],[-ylims,ylims],':k','LineWidth',1);
end



