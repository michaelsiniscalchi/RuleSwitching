function plotReg_summary(input,pvalThresh,tlabel,xtitle)
% % plot_regr %
%PURPOSE:   Plot results from multiple linear regression
%AUTHORS:   AC Kwan 170515 
%           Edited by MJ Siniscalchi 190327
%
%INPUT ARGUMENTS
%   input:        Structure generated by linear_regr().
%   pvalThresh:   Threshold value to deem whether p-values are significant
%   tlabel:       Text to put as title of the plot.
%   xtitle:       Text to put as the label for x-axis.

%% Setup input data for plotting

t = input{1}.regr_time;
dt = nanmean(diff(t));

%Subplots: size of grid
nPredictor = input{1}.numPredictor; %Number of current trial variables, eg choice & outcome ~ 2 
nBack = input{1}.nback;
nInteraction = (nPredictor-1)*double(input{1}.interaction); % (p-1) x indicator variable for considering interactions
nRows = nPredictor + nInteraction;    %plot extra row(s) for the interaction terms
nCols = nBack + 1;

nCells = numel(input);
for i = 1:nCells
    pval(:,:,i)=input{i}.pval;
end

%% plot results

% Regressors are:
% N for current trial vars + (N*nBack) for prior trials + (nBack+1) for same-trial interaction
terms = 1 + (1 : nPredictor*(nBack+1) + nBack+1); % 1+ for bias term; 

figure;
for i = 1:nRows
    for j = 1:nCols 
        currPredictor = terms((i-1)*nCols + j); %Reference column from input.
        subplot(nRows,nCols,currPredictor-1); hold on;
        patch([t(1) t(end) t(end) t(1)],[0 0 100*pvalThresh 100*pvalThresh],[0.7 0.7 0.7],'EdgeColor','none');
        plot(t,100*sum(pval(:,currPredictor,:)<pvalThresh,3)/nCells,'k.-','MarkerSize',30);
        plot([0 0],[0 100],'k','LineWidth',1);
        xlim([t(1) t(end)]);
        ylim([0 40]);
        title(tlabel{currPredictor-1});
        
        % Identify points with significant proportion of cells via binomial test
        sig = [];
        for ii = 1:numel(t)
            p = myBinomTest(sum(pval(ii,currPredictor,:)<pvalThresh,3),nCells,pvalThresh);
            sig(ii) = p;
        end
        for ii = 1:numel(sig)
            if sig(ii)<pvalThresh
                plot(t(ii)+dt*[-0.5 0.5],[35 35],'k-','LineWidth',5);
            end
        end
        
        if j==1
            ylabel('Cells significant (%)');
        end
        if i==nRows
            xlabel(xtitle);
        end
    end
end