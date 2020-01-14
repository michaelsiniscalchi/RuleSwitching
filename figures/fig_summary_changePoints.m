
function fig = fig_summary_changePoints( transitions, params )

% Get Cell & Transition Types
cellType = fieldnames(transitions);
cellType = cellType(~strcmp(cellType,'all'));
transType = {'sound','action'};


% Setup Figure Properties
setup_figprops([]);
ax = gobjects(numel(transType),numel(cellType));

% Generate Scatter Plots for Neural vs. Behavioral Change-Points
fig = figure('Name','Neural & behavioral change points plotted separately by cell type');
fig.Position = [100 500 1000 500];
tiledlayout(2,4,'TileSpacing','none','Padding','none');
for i = 1:numel(transType)
    for j = 1:numel(cellType)
        ax(i,j) = nexttile; hold on
        beh_trans = getChgPt(transitions.(cellType{j}).(transType{i}), params.useChangePt);
        neural_trans = transitions.(cellType{j}).(transType{i}).neuralChgPt.data;
        scatter(beh_trans,neural_trans,20,params.color.(cellType{j}),'LineWidth',2);
        plot(median(beh_trans),median(neural_trans),'+','MarkerSize',30,...
            'Color',params.color.(transType{i}),'LineStyle','none','LineWidth',1); %params.color.([cellType{j} num2str(2)])
        lims = max([ylim xlim]);
        plot([0 lims],[0 lims],':k');
        axis square
    end
end

% Label axes

for j = 1:numel(cellType)
    %Title for top row
    title(ax(1,j),cellType{j});
    %XLabel bottom row
    xlabel(ax(2,j),{'Sound';'Behavioral transition trial'});
end

%YLabel left col
ylabel(ax(1,1),{'Sound';'Neural transition trial'});
ylabel(ax(2,1),{'Action';'Neural transition trial'});

% ---INTERNAL FUNCTIONS ----------------------------------------------------------------------------

    function chgPt = getChgPt(T, flag)
    if flag
        chgPt = T.behChgPt.data;
    else 
        chgPt = T.nTrials-19; %Idx of first of last 20 trials in block
    end
