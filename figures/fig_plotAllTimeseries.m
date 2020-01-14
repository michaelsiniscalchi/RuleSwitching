function fig = fig_plotAllTimeseries( img_beh, params )

fig = figure('Name',img_beh.sessionID);
fig.Visible = 'off';
fig.Position = [100 100 1200 800];
color = params.Color; 

nROIs = numel(img_beh.dFF); %Number of cells to plot
t = (img_beh.t ./ 60); %Unit: seconds->minutes

cueTimes = (img_beh.trialData.cueTimes ./ 60); %Unit: seconds->minutes
trigTimes = (img_beh.trialData.(params.trigTimes) ./ 60); %'cueTimes' or 'responseTimes'

%Make color-coded backdrop for each rule block
spc = params.spacing; %Unit: sd
ymax = 0;
ymin = -spc*(nROIs+1); %Cell idx negated so cell 1 is on top
for i = 1:numel(img_beh.blocks.type)
    firstTrial = img_beh.blocks.firstTrial(i);
    nTrials = min(img_beh.blocks.nTrials(i), img_beh.blocks.nTrials(end)-1); %First startTime of next block or last startTime of last block
    t1 = cueTimes(firstTrial); %Time of first trial in ith block
    t2 = cueTimes(firstTrial+nTrials); %Time of first trial in (i+1)th block
    switch img_beh.blocks.type{i}
        case 'sound'; c = 'w';
        case 'actionL'; c = color.red;
        case 'actionR'; c = color.blue;
    end
    fill([t1;t1;t2;t2],[ymax;ymin;ymin;ymax],c,...
        'FaceAlpha',params.FaceAlpha,'EdgeColor','none');
    hold on;
end

%Mark beginning of each trial
if params.trialMarkers
    c = cell(numel(trigTimes),1);
    c(:) = {'w'};
    c(img_beh.trials.hit) = {'k'};
    c(img_beh.trials.err) = {color.red};
    for i = 1:numel(trigTimes)
        plot([trigTimes(i),trigTimes(i)],[ymin,ymax],'-','Color',c{i},'LineWidth',0.5)
    end
end

%Plot dF/F for all cells as z-score
for i = 1:nROIs
    Y = zscore(img_beh.dFF{i}) - spc*i;
    plot(t,Y,'k','LineWidth',params.LineWidth); hold on
end

%Label y-axis
if params.ylabel_cellIDs
    ytick = -spc*numel(img_beh.cellID):spc:-spc;
    yticklabel = img_beh.cellID(end:-1:1);
else
    lowTick = -10*(mod(spc*nROIs/10,10) - spc*nROIs/10); %Bottom tick spacing value
    ytick = lowTick:spc*10:-spc; %Ticks at these spacing values
    yticklabel = -lowTick/10:10:-10; %Label from 10:10:nCells from top to bottom
end
set(gca,'YTick',ytick); %Ticks at these spacing values
set(gca,'YTickLabel',yticklabel);
title(img_beh.sessionID);
ylabel('Cell Identifier'); xlabel('Time (min)');
set(gca,'box','off');
axis tight;

end
