%%% plot_basicBox()
%
% PURPOSE: To generate a no-frills boxplot representing the five number summary for input data.
% AUTHOR: MJ Siniscalchi, Yale University, 200315
%
%   
%
%---------------------------------------------------------------------------------------------------
function h = plot_basicBox( X, data, boxWidth, lineWidth, color, transparency )

% Arg Check
if nargin<6
    transparency = 0.5;
end

l = X-0.5*boxWidth;       %Box left
r = X+0.5*boxWidth;       %Box right
t = prctile(data,75);     %Box top: Q3
b = prctile(data,25);     %Box bottom: Q1

med = median(data);       %Median (Q2)
wl = prctile(data,9);     %Whisker low  (9th; see theory on 7-number summary...)
wh = prctile(data,91);    %Whisker high (91th; see theory on 7-number summary...)

p = patch([l l r r],[b t t b],color,'EdgeColor',color,'LineWidth',lineWidth); hold on;
ln(1) = plot([X X]',[wl b]','-','Color',color); %Low Whisker
ln(2) = plot([X X]',[t wh]','-','Color',color); %High Whisker
ln(3) = plot([l r]',[med med]','-','Color',color); %High Whisker

p.FaceAlpha = transparency;
set(ln(:),'LineWidth',lineWidth);

h = gca;