function save_multiplePlots(figs,save_path)
for j = 1:numel(figs)

    % Set CreateFcn callback
    figs(j).CreateFcn = 'set(gcbo,''Visible'',''on'')';
    
    % Save graphics file and MATLAB figure
    savename = fullfile(save_path,figs(j).Name);
    print(figs(j),'-dpng',savename);    %Save PNG
    savefig(figs(j),savename);
end
close all;