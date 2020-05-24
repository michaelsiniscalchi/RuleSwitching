function fig = fig_summary_lickstats( behavior, cellType, params )

LR = behavior.(cellType).lickRates; %Extract cell-type specific data
LD = behavior.(cellType).lickDiffs;

%% SETUP PANELS FOR PLOTTING
titles = {'By Outcome','By Rule'};

setup_figprops([]);
fig = figure('Name',['Summary lick statistics - ' cellType]);
fig.Position = [100 100 700 600]; %BLWH [72 153 639 600]
tiledlayout(2,4);
ax = gobjects(5,1);

lineWidth = params.lineWidth;
boxWidth = params.boxWidth;
offset = 0.5*boxWidth(2) + 0.05; %Offset for paired boxplots

transparency = 0.3; %No shading to distinguish from sound rule color code
ylims.meanRate = [0,5];
ylims.diffRate = [-5,5];

%% PLOT MEAN LICK RATE PRE- & POST-CUE FOR HIT VS ERROR & SOUND VS ACTION

%Panel 1: Pre vs. Post Cue
ax(1) = nexttile();
epoch = {'preCue','postCue'}; %D.preCue.hit.data
subset = {'completed','completed'};
title('Epoch');
X = 1:numel(epoch);
for i = X
    %Box plot with 95% whiskers and median as line
    plot_basicBox(X(i), LR.(epoch{i}).(subset{i}).data,...
        boxWidth(1), lineWidth, params.colors.data, transparency);
end
xlim([1-(boxWidth(1)) numel(X)+(boxWidth(1))]); %margins on each side equal to box width
set(ax(1),'XTick',X,'XTickLabel',{'ITI','Cue'});

%Panel 2: Post Cue, Hit vs Err
ax(2) = nexttile();
epoch = {'postCue','postCue'}; %D.preCue.hit.data
subset = {'hit','err'};
title('Outcome');
X = 1:numel(epoch);
for i = X
    %Box plot with 95% whiskers and median as line
    % Left box in group
    plot_basicBox(X(i), LR.(epoch{i}).(subset{i}).data,...
        boxWidth(1), lineWidth, params.colors.data,transparency);
end
xlim([1-boxWidth(1) numel(X)+boxWidth(1)]); %margins on each side equal to box width
set(ax(2),'XTick',X,'XTickLabel',{'Hit','Error'});
set(ax(1:2),'PlotBoxAspectRatio', [1,2,1]);

%%
%Panel 3: Pre & Post Cue, Action vs Sound
ax(3) = nexttile([1,2]);
epoch = {'preCue','postCue'}; %D.preCue.hit.data
subset = {'sound','action'};
title('Rule Type');
X = 1:numel(epoch);
for i = X
    %Box plot with 95% whiskers and median as line
    % Left box in group
    plot_basicBox(X(i)-offset, LR.(epoch{i}).(subset{1}).data,...
        boxWidth(2), lineWidth, params.colors.(subset{1}), transparency);
    % Right box in group
    plot_basicBox(X(i)+offset, LR.(epoch{i}).(subset{2}).data,...
        boxWidth(2), lineWidth, params.colors.(subset{2}), transparency);
end
xlim([1-(2*boxWidth(2)) numel(X)+(2*boxWidth(2))]); %margins on each side equal to box width
set(ax(3),'XTick',X,'XTickLabel',{'ITI','Cue'},'PlotBoxAspectRatio', [2,2,1]);
set(ax(1:3),'YLim',ylims.meanRate);

%%
% Panel 4 & 5: Lick Lateralization in Sound, Action-L, & Action-R
epoch = {'preCue','postCue'}; %eg LD.preCue.upsweep.sound
cue = {'upsweep','downsweep'};
subset = {'sound','actionL','actionR'};

X = 1:numel(subset);
xlims = [1-(2*boxWidth(2)) numel(X)+(2*boxWidth(2))];
for i = 1:2
    ax(i+3) = nexttile([1,2]);
    title(epoch{i});
    for j = X
        %Box plot with 95% whiskers and median as line
        % Left box in group
        plot_basicBox(X(j)-offset, LD.(epoch{i}).upsweep.(subset{j}).data,...
            boxWidth(2), lineWidth, params.colors.(subset{j}), transparency);
        % Right box in group
        plot_basicBox(X(j)+offset, LD.(epoch{i}).downsweep.(subset{j}).data,...
            boxWidth(2), lineWidth, params.colors.(subset{j}), transparency);
        plot(xlims,[0 0],':k','LineWidth',0.5)
    end
    xlim(xlims); %margins on each side equal to box width
end
set(ax(4:5),'YLim',ylims.diffRate,...
    'XTick',sort([X-offset X+offset]),'XTickLabel',{'Up','Dn'},'PlotBoxAspectRatio', [2,2,1]);

%Set YLabels
ax(1).YLabel.String = 'Mean lick rate (Hz)';
ax(4).YLabel.String = 'Mean lick rate (right-left, Hz)';
