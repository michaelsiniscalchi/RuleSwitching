function fig = fig_transitions_cell_x_trial( transitions, params )

T = transitions;
T.dFF = [T.meanDFF{:}];

fig = figure('Name',transitions.sessionID);
fig.Visible = 'off';
fig.Position = [100 100 1200 800];

nCells = numel(T.cellID); %Number of cells to plot

% Color-coded backdrop for each rule block
c = cell(numel(T.type),1); %Initialize color array
c(:) = {'w'};
c(strcmp(T.type,'sound_actionL')) = {'r'};
c(strcmp(T.type,'sound_actionR')) = {'b'};
spc = params.spacing; %Spacing: unit, sd
ymax = 0;
ymin = -spc*(nCells+1); %Cell idx negated so cell 1 is on top

for i = 1:numel(T.type)
    firstTrial = T.firstTrial(i);
    nTrials = min(T.nTrials(i), T.nTrials(end)-1); %First startTime of next block or last startTime of last block
    idx1 = firstTrial; %Time of first trial in ith block
    idx2 = firstTrial+nTrials; %Time of first trial in (i+1)th block
    fill([idx1;idx1;idx2;idx2],[ymax;ymin;ymin;ymax],c{i},'FaceAlpha',params.FaceAlpha,'EdgeColor','none'); hold on;
end

%Plot dF/F for all cells as z-score
for i = 1:nCells
    X = T.firstTrial(1) + (1:size(T.dFF,2));
    Y = zscore(T.dFF(i,:)) - spc*i;
    plot(X,Y,'k','LineWidth',params.LineWidth); hold on
end

%Label x- and y-axis
ytick = -spc*numel(T.cellID):spc:-spc;
yticklabel = T.cellID(end:-1:1);
set(gca,'YTick',ytick); %Ticks at these spacing values
set(gca,'YTickLabel',yticklabel);
ylabel('Cell Identifier'); 
xlabel('Trial number');

title(['Mean dF/F, post-cue period: ' T.sessionID]);
set(gca,'box','off');
axis tight;

end
