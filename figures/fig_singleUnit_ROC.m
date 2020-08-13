
function figs = fig_singleUnit_ROC( decode, cell_idx, sessionID, cellIDs, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters

% Extract decoded behavioral variables
decodeType = params.decodeType;

%One figure per cell
nType = numel(decodeType);
p = params.panels; %Unpack for readability
figs = gobjects(numel(cell_idx),1);
for cellIdx = cell_idx' %Increment input cell index
    
    disp(['Generating figure from decoding analysis for Cell ' cellIDs{cellIdx} '...']);
    figs(cellIdx) = figure('Name',[sessionID(1:10) '_cell' cellIDs{cellIdx} '_ROC']);
    figs(cellIdx).Position = [50 100 1800 800];
    figs(cellIdx).Visible = 'on';
    
    for typeIdx = 1:nType     %One row per decode type
        %Time-varying modulation index
        Y = decode.(decodeType{typeIdx}).selectivity{cellIdx};
        %Time index of peak modulation >t0
        I = Y(1,:);
        I(decode.t<0)=0; %Set pre-cue values to zero
        peak(typeIdx) = find(I==max(abs(I))|I==-max(abs(I)),1,'first'); %#ok<AGROW>
        
        % Row 1: Plot bootstrapped selectivity and CI as a function of time
        ax(typeIdx) = subplot(2,nType,typeIdx); hold on;
        
        %Error shading: shuffle or bootstrap
        if strcmp(params.shading,'shuffle')
            shuffle = prctile(decode.(decodeType{typeIdx}).AUC_shuffle{cellIdx},...
                [50-0.5*params.CI,50+0.5*params.CI]); %Get lower and upper CI bounds
            shuffle = 2*(shuffle-0.5); %Convert to modulation index
            errorshade(decode.t, shuffle(1,:), shuffle(2,:), p(typeIdx).color, 0.1); %errorshade(Y,CI_low,CI_high,color,transparency)
            data_range(typeIdx,:) = [min([Y(1,:),shuffle(:)']), max([Y(1,:),shuffle(:)'])];
        else %Bootstrap CI
            errorshade(decode.t, Y(2,:), Y(3,:), p(typeIdx).color, 0.2);
        end
        
        %Plot modulation index and reference line Y0 
        plot(decode.t,Y(1,:),'Color',p(typeIdx).color);
        plot([decode.t(1) decode.t(end)],[0 0],'k:','LineWidth',get(groot,'DefaultAxesLineWidth')); %Zero selectivity
        
        title(p(typeIdx).title);
        xlabel('Time from sound cue (s)');
        axis square tight;
        
        % Row 2: ROC curve
        %Find sample corresponding to peak modulation index
        ax(nType+typeIdx) = subplot(2,nType,nType+typeIdx); hold on;
        plot(decode.(decodeType{typeIdx}).FPR{cellIdx}(:,peak(typeIdx)),...
            decode.(decodeType{typeIdx}).TPR{cellIdx}(:,peak(typeIdx)),'k-'); %ROC curve
        plot(decode.(decodeType{typeIdx}).FPR_shuffle{cellIdx}(:,peak(typeIdx)),...
            decode.(decodeType{typeIdx}).TPR_shuffle{cellIdx}(:,peak(typeIdx)),...
            ':','Color',[0.5 0.5 0.5]); %Shuffled ROC curve
        xlabel('False positive rate');
        axis square;
    end
    
    % Standardize scale of axes
    %     [low,high] = bounds([ax(1:nType).YLim]);
    for i = 1:nType
        %         ax(i).YLim = [nanmin(low) - 0.1*range([low;high]),...
        %             nanmax(high)+ 0.1*range([low;high])]; %Disabled
        rng = range(data_range(i,:));
        [low,high] = deal(data_range(i,1)-0.2*rng, data_range(i,2)+0.2*rng); %Scale independently
        plot(ax(i),[0 0],[low,high],'k-','LineWidth',get(groot,'DefaultAxesLineWidth')); %t0
        markerX = decode.t(peak(i));
        markerY = low+0.03*range([low,high]);
        plot(ax(i),markerX,markerY,'k^','MarkerSize',3);
    end
    
    
    %Legend & YLabels
    if decode.(decodeType{1}).AUC{cellIdx}(peak(1))>0.5
        legend(ax(nType+1),'ROC','Shuffle','Location','southeast'); %Positive class preference
    else
        legend(ax(nType+1),'ROC','Shuffle','Location','northwest'); %Negative class preference
    end
    ax(1).YLabel.String = 'Modulation index, I';
    ax(nType+1).YLabel.String = 'True positive rate';
    
end