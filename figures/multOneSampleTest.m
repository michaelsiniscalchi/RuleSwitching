%%% multOneSampleTest()
%
% PURPOSE: To conduct one or more one-sample hypothesis tests, with H0: mean difference is zero.
% AUTHOR: MJ Siniscalchi, Yale University, 200316
% INPUT ARGUMENTS:
%                   'testData', a column vector of differences from null, or a matrix comprised of 
%                               such vectors.                 
%                   'testName', name of function for hypothesis test: 'ttest' or 'signrank'.
%                   'alpha', the threshold p-value for statistical significance.
%
%---------------------------------------------------------------------------------------------------

%Get one-sample hypothesis test result for column vector or matrix
function sigVector = multOneSampleTest( testData, testName, alpha )

sigVector = false(1,size(testData,2));
if strcmp(testName,'ttest')
    for i = 1:numel(sigVector)
        sigVector(i) = ttest(testData(:,i),0,'Alpha',alpha);
    end
elseif strcmp(testName,'signrank')
    for i = 1:numel(sigVector)
        [~, sigVector(i)] = signrank(testData(:,i),0,'alpha',alpha);
    end
else
    warning('Test name should be "ttest" or "signrank"');
end