function fig = fig_summary_behavior( behavior, cellType, params )

D = behavior.(cellType); %Extract cell-type specific data

%% SETUP PANELS FOR PLOTTING
bar_width = 0.8;
titles = {'Trials to Crit.','Persev. Errors','Other Errors'};
% titles = {'Trials Perf.','Trials to Crit.','Persev. Errors','Other Errors'};

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
ax(i).XLim = [0 3];
ax(i).XTickLabel = {'Sound','Action'};

swarmPlot(data, params.ruleColors(:), 0.5);
title(titles{i}); %Title

ylims(i,:) = ylim; %#ok<AGROW> %Store ylims for later standardization
end

%% Formatting

% Set YLims for Error Plots
ylims = ylims(2:3,:);
ylim(ax(2:3),[min(ylims(:)) max(ylims(:))]);
ax(3).YAxis.Visible = 'off';

% YLabel & Box
ylabel(ax(1),'Number of trials per block');
set(ax,'Box','off','XTick',[1,2],'XTickLabel',{'Sound','Action'}); %Box off for all

function swarmPlot( data, colors, barWidth )

CI(1,:) = prctile(data,25);
CI(2,:) = prctile(data,75);

for i = 1:size(data,2)

    %Beeswarm for individual data points
    X = (i).*ones(size(data,1),1); 
    Y = data(:,i);
    color = colors{i}(2,:); %Lighter shade
    beeswarm(X,Y,'use_current_axes',true,'dot_size',1,'colormap',color,'sort_style','square'); 
    hold on;
    
    % Horizontal bar for population median
    X = i + [-barWidth/2 barWidth/2]; 
    Y = [median(data(:,i)),median(data(:,i))];
    color = colors{i}(1,:); %Darker shade
    line(X,Y,'Color',color,'LineWidth',2); hold on; %Horz. bar for Median
    
    % Vertical bar for IQR
    X = [i,i]; 
    Y = [CI(1,i),CI(2,i)];
    line(X,Y,'Color',color,'LineWidth',1);  %Vertical Bar for IQR

end  


