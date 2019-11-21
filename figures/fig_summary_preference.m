function fig = fig_summary_preference( stats_selectivity, time, params )

setup_figprops('singleUnit');

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = fieldnames(S);
nDecode = numel(decodeType);
cellType = fieldnames(S.(decodeType{1}));

%Initialize figure
fig = figure('Name','Proportion_Pref_classX','Position',[10 500 1900 400]);
ax = gobjects(numel(decodeType),1);
lineWidth = 2;

var_name = {'pPrefPos','pPrefNeg'};
for i = 1:nDecode
    %One plot for each decode type
    ax(i) = subplot(1,nDecode,i); hold on; %#ok<AGROW>
    %One pair of bars for each cell type
    for j=1:numel(cellType)
        for k = 1:numel(var_name)
            var = S.(decodeType{i}).(cellType{j}).(var_name{k});
            Mean(j,k) = var.mean;
            SEM(j,k) = var.sem;
            Y{j,k} = var.data;
        end
    end
    
    %Bar chart with overlayed data by session
    b = bar(Mean,'FaceColor','flat','EdgeColor','flat'); hold on;
    for k = 1:numel(b)
        b(k).CData = params.colors{k};
        bar_center(:,k) = b(k).XEndPoints;
    end
    
    %Error bars
    if strcmp(params.variance,'bars')
        for j=1:numel(cellType)
            for k = 1:numel(var_name)
                errorbar(bar_center(j,k),Mean(j,k),SEM(j,k),...
                    'Color',params.colors{k}(j,:),'LineWidth',lineWidth,'CapSize',0);
            end
        end
    else
        %Data points
        for j=1:numel(cellType)
            for k = 1:numel(var_name)
                X = bar_center(j,k)*ones(size(Y{j,k}));
                plot(X,Y{j,k},'.','Color',[0.5 0.5 0.5],'LineWidth',lineWidth);
            end
        end
    end
    
    ax(i).XTick = 1:numel(cellType); %Bar chart: titles and labels
    ax(i).XTickLabels = cellType;
    
    %Get ylims for later standardization
    axis square;
    ylims(i,:) = ylim;
    
    %Title
    if isfield(params,'titles') && ~isempty(params.titles)
        ax(i).Title.String = params.titles{i};
    else %Use decode fieldnames
        title_str = [upper(decodeType{i}(1)), decodeType{i}(2:end)];
        title_str(title_str=='_') = ' ';
        ax(i).Title.String = title_str;
    end
    
    
end

%Set YLabel & YLims
ax(1).YLabel.String = 'Proportion pref. +/- class';
ylim(ax,[min(ylims(:)) max(ylims(:))]);