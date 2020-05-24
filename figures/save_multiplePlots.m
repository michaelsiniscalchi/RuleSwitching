function save_multiplePlots(figs,save_path,varargin)

opt_names = varargin;
options = parseOptions(opt_names);

for j = 1:numel(figs)
    
    if strcmp(class(figs(j)),'matlab.graphics.GraphicsPlaceholder')
        continue %Skip empty graphics placeholders
    end
    
    % Set CreateFcn callback
    figs(j).CreateFcn = 'set(gcbo,''Visible'',''on'')';
    
    % Save PNG
    savename = fullfile(save_path,figs(j).Name);
    print(figs(j),savename,'-dpng');    %Save PNG
    
    % Save SVG
    if options.svg
        orient(figs(j),'landscape')
        print(figs(j),savename,'-dsvg','-painters','-r0');    %Save vector for work in Illustrator
    end
    
    % Save SVG
    if options.pdf
        orient(figs(j),'landscape')
        print(figs(j),savename,'-dpdf','-painters','-r0');    %Save vector for work in Illustrator
    end
    
    %Save as MATLAB .FIG file
    savefig(figs(j),savename);
end
close all;

function options = parseOptions( opt_names )
options = struct('svg',false,'pdf',false);
for i = 1:numel(opt_names)
    options.(opt_names{i}) = true;
end

