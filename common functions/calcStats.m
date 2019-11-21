%%% calcSummaryStats()
%
% PURPOSE: To estimate commonly used parameters of an arbitrary distribution of data.
%
% AUTHOR: MJ Siniscalchi 191118
%
% INPUT ARGS:   
%               'data' (numeric), a 1D or 2D array with replicates assigned to different rows.
%               '', a vector with number of elements corresponding to
%---------------------------------------------------------------------------------------------------

function stats = calcStats( data, expID )

stats.data      = data;
stats.median    = median(data,1);
stats.IQR       = prctile(data,[25,75],1);
stats.mean      = mean(data,1);
stats.sem       = std(data)/sqrt(size(data,1)); 
stats.N         = size(data,1);
stats.expID     = expID;