function fig = fig_summary_behavior( behavior, cellType, params )

D = behavior.(cellType); %Extract cell-type specific data

%Set up panels for plotting
direction = {'left','right'};
cue = {'upsweep','downsweep'};
rule = {'sound','action'};
titles = {'Sound','Action'};

setup_figprops([]);
fig = figure('Name',['Summary behavioral statistics - ' cellType]);
fig.Position = [400 400 800 500]; %BLWH
tiledlayout(1,3);
ax = gobjects(1,3);

%Plot lick density as f(t)
for row = 1:numel(cue)
    for col = 1:numel(rule)
        
        idx = numel(rule)*(row-1)+col;
        ax(idx) = nexttile; hold on;
        for i = 1:numel(direction)
            %Extract specified data
            data = D.(direction{i}).(cue{row}).(rule{col}); %Counts/trial/second
            %Plot lick densities
            CI = data.mean + [-data.sem; data.sem];
            errorshade(t,CI(1,:),CI(2,:),params.colors{i},0.2); % errorshade(X,CI_low,CI_high,color,transparency)
            plot(t,data.mean,'Color',params.colors{i});  %Lick density, {left,right}
        end
        plot([0,0],[0,ymax],':k','LineWidth',1); %Plot t0
        
        %Standardize plotting area
        ylim([0,ymax]); %[0,12] Hz
        xlim([edges(1),edges(end)]); %Trial window
        axis square;
        
        %Titles and axis labels
        if row==1
            title(titles{col}); %Title: rule
        end
        if col==1 && row==1
            ylabel({'Upsweep trials'; 'Lick density (Hz)'});
        elseif col==1
             ylabel({'Downsweep trials'; 'Lick density (Hz)'});
        end
    end
end
