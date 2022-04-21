function StatsCorrMatrices(HypoxiaLevels)
allpvaluesBefore = [];
allpvaluesHypox = [];

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};

    %load 
    load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
    load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
    
    CorrBefore = mean(CorrBefore,3, 'omitnan');
    zscoresBefore = atanh(CorrBefore);
    pvaluesBefore = 1 - normcdf(zscoresBefore);
    pvaluesBefore = tril(pvaluesBefore);
    pvaluesBefore = nonzeros(pvaluesBefore);
    
    CorrHypox = mean(CorrHypox, 3, 'omitnan');
    zscoresHypox = atanh(CorrHypox);
    pvaluesHypox = 1 - normcdf(zscoresHypox);
    pvaluesHypox = tril(pvaluesHypox);
    pvaluesHypox = nonzeros(pvaluesHypox);
    
    allpvaluesBefore = cat(2, allpvaluesBefore, pvaluesBefore);
    allpvaluesHypox = cat(2, allpvaluesHypox, pvaluesHypox);
end

    %% Stats
    %%Thing-gny
    % 
    allpvalues = [allpvaluesBefore, allpvaluesHypox];
    allpvalues = reshape(allpvalues, [], 1);
    allpvalues = sort(allpvalues);
    
% 8*8 seed pairs so 64, 64 - 8 that are correlating with themselves. Half
% of them are the same so 28, and then before and during hypox so 2. 8
% hypoxia levels so in the end: 28*2*8 statistical tests
NumberOfSeedPairs = 0.5 * ((size(CorrBefore,1)*size(CorrBefore,1)) - size(CorrBefore, 1));
    N = NumberOfSeedPairs * 2 * size(HypoxiaLevels, 2);   
    k = 1:N;
    gamma = 0.05;
    
    BH = (k/N).*(gamma);
    
    plot(BH)
    hold
    plot(allpvalues)
end