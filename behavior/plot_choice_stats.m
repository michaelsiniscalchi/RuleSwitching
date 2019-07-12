function plot_choice_stats(input,tlabel)
% % plot_choice_stats %
%PURPOSE:   Plot choice behavior in discrim/flexibility task
%AUTHORS:   AC Kwan 170515
%
%INPUT ARGUMENTS
%   input:        Structure generated by choice_stats().
%   tlabel:       Text to put as title of the plot.

%%

% if called from single-session analysis, input is a struct
% if called from summary analysis, input is a cell array
% here convert everything to a cell array first
if ~iscell(input)  
    temp = input;
    clear input;
    input{1} = temp;
end

% load from the cell array
for j=1:numel(input)
    nTrialsPerformed(j)=input{j}.nTrialsPerformed;
    nDouble(j)=input{j}.nDouble;
    nOmit(j)=input{j}.nOmit;
    nErr(j)=input{j}.nErr;
    correctRate(j)=input{j}.correctRate;  %correct rate = correct/(correct+err)
    correctRateL(j)=input{j}.correctRateL;
    correctRateR(j)=input{j}.correctRateR;
    correctRateAfterHit(j)=input{j}.correctRateAfterHit;    %correct rate = correct/(correct+err)
    correctRateAfterDouble(j)=input{j}.correctRateAfterDouble;
    correctRateAfterOmit(j)=input{j}.correctRateAfterOmit;
    correctRateAfterErr(j)=input{j}.correctRateAfterErr;
    correctRateAfterMiss(j)=input{j}.correctRateAfterMiss;
    missFracAfterHit(j)=input{j}.missFracAfterHit;  %miss fraction = miss/(hit+err+miss)
    missFracAfterDouble(j)=input{j}.missFracAfterDouble;
    missFracAfterOmit(j)=input{j}.missFracAfterOmit;
    missFracAfterErr(j)=input{j}.missFracAfterErr;
    missFracAfterMiss(j)=input{j}.missFracAfterMiss;
    dprime(j)=input{j}.dprime;
    stayRate(j)=input{j}.stayRate;
    wslsRate(j)=input{j}.wslsRate;
    wsRate(j)=input{j}.wsRate;
    lsRate(j)=input{j}.lsRate;
    fracLeft(j)=input{j}.fracLeft;
end

gray=[0.7 0.7 0.7];

%% First plot

figure;
for l=1:14
    if l==1
        temp=nTrialsPerformed;
        ytitle='Trials performed';
        yrange=[0 max([1 100*ceil(nanmax(temp)/100)])]; %ceiling nearest 100, but at least 1
    elseif l==2
        temp=100*correctRate;
        ytitle='Correct rate, overall (%)';
        yrange=[0 100]; 
    elseif l==3
        temp=100*correctRateL;
        ytitle='Correct rate, left (%)';
        yrange=[0 100]; 
    elseif l==4
        temp=100*correctRateR;
        ytitle='Correct rate, right (%)';
        yrange=[0 100];
    elseif l==5
        temp=dprime;
        ytitle='d''';
        if sum(~isnan(dprime)) > 0  %if at least some of the d-prime's are valid numbers, set a proper range
            yrange = [min([0 floor(nanmin(dprime))]) ceil(nanmax(dprime))+0.1];
            %floor is usually 0, but could be negative if d-prime is below 0
            %ceiling is nearest interger number plus a small amount just in case floor/ceil functions yield same value
        else
            yrange = [0 1];
        end     
    elseif l==6
        temp=nTrialsPerformed - nDouble - nOmit - nErr;
        ytitle='Single rewards';
        yrange=[0 max([1 100*ceil(nanmax(temp)/100)])]; %ceiling nearest 100, but at least 1
    elseif l==7
        temp=nDouble;
        ytitle='Double rewards';
        yrange=[0 max([1 100*ceil(nanmax(temp)/100)])]; %ceiling nearest 100, but at least 1
    elseif l==8
        temp=nOmit;
        ytitle='Omitted rewards';
        yrange=[0 max([1 100*ceil(nanmax(temp)/100)])]; %ceiling nearest 100, but at least 1
    elseif l==9
        temp=nErr;
        ytitle='Error';
        yrange=[0 max([1 100*ceil(nanmax(temp)/100)])]; %ceiling nearest 100, but at least 1
    elseif l==10
        temp=100*stayRate;
        ytitle='Stay rate (%)';
        yrange=[0 100];
    elseif l==11
        temp=100*wslsRate;
        ytitle='WSLS rate (%)';
        yrange=[0 100];
    elseif l==12
        temp=100*wsRate;
        ytitle='Win-stay rate (%)';
        yrange=[0 100];
    elseif l==13
        temp=100*lsRate;
        ytitle='Lose-switch rate (%)';
        yrange=[0 100];
    elseif l==14
        temp=100*max([fracLeft(:) 1-fracLeft(:)]');    %left or right bias
        ytitle='Side bias (%)';
        yrange=[0 100];
    end

    subplot(2,7,l); hold on;
    plot(1+0.5*rand(size(temp)),temp,'^','MarkerSize',10,'LineWidth',2,'Color',gray);
    if numel(input)>1  %more than 1 data set, plot mean+-sem
        plot([0.5 2],nanmean(temp)*[1 1],'k-','LineWidth',3);
        plot([1.25 1.25],nanmean(temp)+nanstd(temp)/sqrt(numel(temp))*[-1 1],'k-','LineWidth',3);
    end
    xlim([0 3]);
    ylim(yrange);
    set(gca,'xtick',[]);
    ylabel(ytitle);
    if l==1
        title(tlabel);
    end
end

print(gcf,'choice_stats','-dpng');    %png format
saveas(gcf,'choice_stats', 'fig');
print(gcf,'choice_stats','-depsc','-painters');   %eps format

%% Second plot
        
figure;
for l=1:10
    if l==1
        temp=100*correctRateAfterHit;
        ytitle='Correct rate, after hit (%)';
        yrange=[0 100]; 
    elseif l==2
        temp=100*correctRateAfterDouble;
        ytitle='Correct rate, after double (%)';
        yrange=[0 100]; 
    elseif l==3
        temp=100*correctRateAfterOmit;
        ytitle='Correct rate, after omit (%)';
        yrange=[0 100]; 
    elseif l==4
        temp=100*correctRateAfterErr;
        ytitle='Correct rate, after error (%)';
        yrange=[0 100]; 
    elseif l==5
        temp=100*correctRateAfterMiss;
        ytitle='Correct rate, after miss (%)';
        yrange=[0 100]; 
    elseif l==6
        temp=100*missFracAfterHit;
        ytitle='Fraction miss, after hit (%)';
        yrange=[0 30]; 
    elseif l==7
        temp=100*missFracAfterDouble;
        ytitle='Fraction miss, after double (%)';
        yrange=[0 30]; 
    elseif l==8
        temp=100*missFracAfterOmit;
        ytitle='Fraction miss, after omit (%)';
        yrange=[0 30]; 
    elseif l==9
        temp=100*missFracAfterErr;
        ytitle='Fraction miss, after error (%)';
        yrange=[0 100];         
    elseif l==10
        temp=100*missFracAfterMiss;
        ytitle='Fraction miss, after miss (%)';
        yrange=[0 100];         
    end
    
    subplot(2,7,l); hold on;
    plot(1+0.5*rand(size(temp)),temp,'^','MarkerSize',10,'LineWidth',2,'Color',gray);
    if numel(input)>1  %more than 1 data set, plot mean+-sem
        plot([0.5 2],nanmean(temp)*[1 1],'k-','LineWidth',3);
        plot([1.25 1.25],nanmean(temp)+nanstd(temp)/sqrt(numel(temp))*[-1 1],'k-','LineWidth',3);
    end
    xlim([0 3]);
    ylim(yrange);
    set(gca,'xtick',[]);
    ylabel(ytitle);
    if l==1
        title(tlabel);
    end
    
    % --- print the mean and std; print the statistical test results
%     if l==1 || l==5
%         temp_comp = temp;
%     end
%     [nanmean(temp) nanstd(temp)/sqrt(numel(temp))]
%     signrank(temp_comp,temp)
end

print(gcf,'choice_stats2','-dpng');    %png format
saveas(gcf,'choice_stats2', 'fig');
print(gcf,'choice_stats2','-depsc','-painters');   %eps format

end


