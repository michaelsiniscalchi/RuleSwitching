function fig = fig_summary_lickstats( behavior, cellType, params )

D = behavior.(cellType); %Extract cell-type specific data

%% SETUP PANELS FOR PLOTTING
bar_width = 0.8;
titles = {'Trials to Crit.','Persev. Errors','Other Errors'};

setup_figprops([]);
fig = figure('Name',['Summary behavioral statistics - ' cellType]);
fig.Position = [400 400 800 500]; %BLWH
tiledlayout(1,3);
ax = gobjects(3,1);

%% PLOT TOTAL TRIALS, TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% Trials to Criterion, Perseverative Errors, & Other Errors

vars = {'trials2crit','pErr','oErr'};
for i = 1:numel(vars)
%Plot data with sample median and IQR
data = [D.(vars{i}).sound.data, D.(vars{i}).action.data];
ax(i) = nexttile;
ax(i).YLim = [0, 1.1*max(data(:))]; %Must be set ahead of beeswarm()
ax(i).XLim = [0.5 2.5];
ax(i).XTickLabel = {'Sound','Action'};
%Equal YLims for two error types
if i==3
    ax(i).YLim = ax(2).YLim;
end
%Plot data with sample median and IQR
plot_swarms(ax(i),data,params.ruleColors(:),0.5);
title(titles{i}); %Title

end

%% Formatting


% YLabel & Box
ylabel(ax(1),'Number of trials per block');
set(ax,'Box','off','XTick',[1,2],'XTickLabel',{'Sound','Action'}); %Box off for all
% Drop YAxis on second error plot
ax(3).YAxis.Visible = 'off';