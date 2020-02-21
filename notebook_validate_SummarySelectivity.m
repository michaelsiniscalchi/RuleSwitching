
%Updated shuffle procedure generates identical selectivity results to old method (GOOD!)
%Therefore, we can move forward with comparisons to null distribution, preserving temporal correlations...  

S = load('C:\Users\Michael\Documents\Data & Analysis\Rule Switching\Summary\selectivity.mat');
S.choice_sound.SST.pSig  % 0.8, 0
S.choice_action.SST.pSig % 0, 0

S.choice_sound.SST.selMag % 0.3721, 0.2232
S.choice_action.SST.selMag % NaN, NaN
