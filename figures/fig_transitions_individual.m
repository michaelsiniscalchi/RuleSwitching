function fig = fig_transitions_individual( transitions, params )

T = transitions;

setup_figprops('timeseries');
nCols = 3;

blkIdx.Sound = find(ismember(T.type,{'actionL_sound','actionR_sound'}));
blkIdx.Action = find(ismember(T.type,{'sound_actionL','sound_actionR'}));

ruleName = fieldnames(blkIdx);
for i = 1:numel(ruleName)
    
    blocks = blkIdx.(ruleName{i});
    nRows = ceil(numel(blocks)/nCols);
    fig(i) = figure('Name',[T.sessionID ' (' ruleName{i} ') ' T.params.stat],...
        'Position',[0,50,1850,300*nRows],'Visible','off'); %#ok<*AGROW>
    tiledlayout(nRows,nCols);
    
    for j = 1:numel(blocks)
        ax(j) = nexttile; 
        X = T.similarity(blocks(j)).trialIdx;
        Y = T.similarity(blocks(j)).trials;
        plot(X,Y,'Color',params.Color{i},'Marker','o','LineStyle','none'); hold on;
        ylims(j,:) = ylim; 
    end
    
    % Standardize YLims
    ylims = [-1,1]*max(abs(ylims(:)));
    
    % Formatting
    for j = 1:numel(ax)
        % Title and labels
        title(ax(j),['Neural Transition ' num2str(blocks(j))]);
        if mod(j-1,nCols)==0
            ylabel(ax(j),[T.params.stat '(dest) - ' T.params.stat '(origin)']);
        end
        % Indicate switch trial
        plot(ax(j),[0,0],ylims,':k','LineWidth',1);
        set(ax(j),'PlotBoxAspectRatio',[2,1,1],'Box','off','YLim',ylims);
    end
    clearvars ax ylims
end