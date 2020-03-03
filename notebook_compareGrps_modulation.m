%%%notebook_compareGrps_modulation

% Validate comparisons of difference from null; try one-sample equivalent:
cellTypes = ["SST", "VIP", "PV", "PYR"]'; %Column vectors
vars = {["pSig",'pNull'],["selMag","nullMag"]};
S = stats.selectivity;
stats_str = string(NaN(numel(vars),numel(cellTypes)));
for i=1:numel(vars)
    for j=1:numel(cellTypes)
    data = S.choice_sound.(cellTypes(j)).diffNull.(vars{i}(1)).data;
        [p,~,stat] = signrank(data);
        stat.diff = median(data);
        stats_str(i,j) = strjoin({'W=' num2str(stat.signedrank)}); %W statistic
    end
end

%Appears to be equivalent! Therefore, we can proceed with omnibus test across cell types, using
%   diffNull as the corrected proportion, selectivity magnitude, etc. 