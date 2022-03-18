%% HypoxPipelineCombi
%Combines all mice for the same hypoxia levels
% load('/media/mbakker/data1/Hypoxia/Glist.mat');

%Pay attention: Girls 10% starts hypoxia at a different time and Hypox 12
%for boys 552 had an acquisition problem, so frames are missing at the end.
%Stop 552 after 42000 needs to be cut.

function HypoxPipelineCombi(Glist, ManualInput)
%ManualInput:

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
    'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};

TitleList = {'spO2 levels - 12% oxygen', 'spO2 levels - 10% oxygen', ...
    'spO2 levels - 8% oxygen', 'spO2 levels - 8% oxygen (2)', ...
    'spO2 levels - Normoxia (1)', 'spO2 levels - Normoxia (2)', ...
    'spO2 levels - Normoxia (3)', 'spO2 levels - Normoxia (4)'};

%% spO2 Mean and Median
disp('spO2 Mean Median');

try
    spO2MedianMean(Glist, 0) %0 for dont overwrite, 1 for do overwrite
catch
    disp('Mean and Median spO2 error')
    return;
end

%% spO2 linegraphs with 95 CI
disp('spO2 linegraphs');

try
    spO2linegraph(HypoxiaLevels, Glist, TitleList, 0)
catch
    disp('spO2 linegraphs error')
    return;
end

%% spO2 spatial distribution
disp('spO2 spatial distribution');

try
    spO2SpatialDistribution(HypoxiaLevels, Glist, TitleList, ManualInput)
catch
    disp('spO2 spatial distribution error')
    return;
end

%% spO2 statistics
disp('spO2 statistics')

try
    %%     Mean
    % peak
    %small start peak between 10 and 10.2 min
    disp('Mean spO2 statistics - small peak')
    load('/media/mbakker/data1/Hypoxia/spO2/spO2mean.mat')
    [AveragePeak, AverageBaseline, pvalues, MaxPeak, ~] = ...
        PeakStats(HypoxiaLevels, Glist, 12084, [], [], mean_spO2_list)
    
    %Dip
    % between 10 and 11 min (10.4 center, 9.4-11.4 window)
    disp('Mean spO2 statistics - dip')
    [AveragePeak, AverageBaseline, pvalues, ~, MinPeak] = ...
        PeakStats(HypoxiaLevels, Glist, 12480, (12480-2400), 2400, mean_spO2_list)
    
    % Peak
    % after return to normoxia - 20 to 25
    %     HypoxiaLevels, Glist, CenterOfPeak, CenterOfBaseline, Window, Data
    disp('Mean spO2 statistics - peak return to normoxia')
    [~, ~, ~, MaxPeak, ~] = ...
        PeakStats(HypoxiaLevels, Glist, 27000, 6000, 6000, mean_spO2_list)
    
    
    % plateau
    disp('Mean spO2 statistics - plateau')
    [AveragePlateau, AverageBaseline, pvalues] = ...
        PlateauStats(HypoxiaLevels, Glist, mean_spO2_list)
    
    
    
catch
    disp('spO2 statistics error')
    return;
end

%% HbO/HbR Mean and Median
disp('HbO/HbR Mean Median');
try
    HbOMedianMean(Glist, 1) %0 for dont overwrite, 1 for do overwrite
    HbRMedianMean(Glist, 1)
    disp('Mean and Median HbO/HbR lists written')
catch
    disp('Mean and Median HbO/HbR error')
    return;
end

%% HbO/HbR linegraphs with 95 CI

hemodynamicslinegraph(HypoxiaLevels, Glist, TitleList, ManualInput)

%% HbO/HbR stats
disp('spO2 statistics')

try
    %%     Mean
    % HbR plateau
    disp('Mean HbR statistics - plateau')
    load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmean.mat')
    [AveragePlateau, AverageBaseline, pvalues] = ...
        PlateauStats(HypoxiaLevels, Glist, mean_HbR_list)
    
    %HbR undershoot return to normoxia
    disp('Mean HbR statistics - Undershoot')
    [AveragePeak, AverageBaseline, pvalues, ~, MinPeak] = ...
        PeakStats(HypoxiaLevels, Glist, 24600, 6000, 2400, mean_HbR_list)
    
    
    %% Fucked up graph
    
    % DynamicSeedsCombi(HypoxiaLevels, Glist, TitleList, 1)
    % CombiFuckedUpGraph(HypoxiaLevels, Glist, TitleList, 1)
    
    
end