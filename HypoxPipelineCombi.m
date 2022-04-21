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

%% CombiMask
% CombinedMask(0)

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
    SpatialDistribution(HypoxiaLevels, Glist, 'spO2', 0)
catch
    disp('spO2 spatial distribution error')
    return;
end

%% spO2 statistics
disp('spO2 statistics')

try
    %%     Mean
    %peaks/dips 
    %PeakStats(HypoxiaLevels, Glist, CenterOfPeak, CenterOfBaseline, Window, Data)
    % peak
    %small start peak center 10.07, window 50 frames
    disp('Mean spO2 statistics - small peak')
    load('/media/mbakker/data1/Hypoxia/spO2/spO2mean.mat')
    [AveragePeak, AverageBaseline, pvalues, MaxPeak, ~] = ...
        PeakStats(HypoxiaLevels, Glist, 12084, [], 50, mean_spO2_list)
    
    %Dip
    %10.5 center, 10.25 start (so 300 frames before so 600 window)
    % baseline center 8.5
    disp('Mean spO2 statistics - dip')
    [AveragePeak, AverageBaseline, pvalues, ~, MinPeak] = ...
        PeakStats(HypoxiaLevels, Glist, 12600, 10200, 600, mean_spO2_list)
    
    % Peak
    % after return to normoxia - 20 to 25
    % center at 20.3. window 720 so it starts at 20 and ends at 20.6
    % baseline at 5. 
    %     HypoxiaLevels, Glist, CenterOfPeak, CenterOfBaseline, Window, Data
    disp('Mean spO2 statistics - peak return to normoxia')
    [~, ~, pvalues, MaxPeak, ~] = ...
        PeakStats(HypoxiaLevels, Glist, 24360, 6000, 720, mean_spO2_list)
    
    
    % plateau 14.5-19.5 min
    disp('Mean spO2 statistics - plateau')
    [AveragePlateau, AverageBaseline, pvalues] = ...
        PlateauStats(HypoxiaLevels, Glist, mean_spO2_list,0)
    
    
    
catch
    disp('spO2 statistics error')
    return;
end

%% HbO/HbR Mean and Median
disp('HbO/HbR Mean Median');
try
    HbOMedianMean(Glist, ManualInput) %0 for dont overwrite, 1 for do overwrite
    HbRMedianMean(Glist, ManualInput)
    disp('Mean and Median HbO/HbR lists written')
catch
    disp('Mean and Median HbO/HbR error')
    return;
end

%% HbO/HbR linegraphs with 95 CI

disp('HbO/HbR Linegraphs');
try
    hemodynamicslinegraph(HypoxiaLevels, Glist, TitleList, ManualInput)
    disp('Linegraphs HbO/HbR made')
catch
    disp('HbO/HbR Linegraphs error')
    return;
end

%% HbO/HbR stats
disp('HbO/HbR statistics')

try
    %%     Mean
    % HbR plateau  14.5-19.5 min
    disp('Mean HbR statistics - plateau')
    load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmean.mat')
    [AveragePlateau, AverageBaseline, pvalues] = ...
        PlateauStats(HypoxiaLevels, Glist, mean_HbR_list, 0) %0 is no prompt box, take 14,5 to 19,5 min for plateau
    
    % HbO plateau
    disp('Mean HbO statistics - plateau')
    load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmean.mat')
    [AveragePlateau, AverageBaseline, pvalues] = ...
        PlateauStats(HypoxiaLevels, Glist, mean_HbO_list, 0) %0 is no prompt box, take 14,5 to 19,5 min for plateau
    
    
    %HbR undershoot return to normoxia
        %PeakStats(HypoxiaLevels, Glist, CenterOfPeak, CenterOfBaseline, Window, Data)
    % center 20.5 window van 1 min zodat hij start bij 20
    % center van baseline 5 min
    disp('Mean HbR statistics - Undershoot')
    [AveragePeak, AverageBaseline, pvalues, ~, MinPeak] = ...
        PeakStats(HypoxiaLevels, Glist, 24600, 6000, 1200, mean_HbR_list)
    
    %HbO overshoot return to normoxia
       disp('Mean HbO statistics - Overshoot')
    [AveragePeak, AverageBaseline, pvalues, Maxpeak, ~] = ...
        PeakStats(HypoxiaLevels, Glist, 24600, 6000, 1200, mean_HbO_list)
    catch
    disp('Mean and Median HbO/HbR error')
    return;
end
    

%% Spatial Distributions Hemodynamics
disp('HbO/HbR spatial distribution')

try
    SpatialDistribution(HypoxiaLevels, Glist, 'HbO', 0)
    SpatialDistribution(HypoxiaLevels, Glist, 'HbR', 0)
    SpatialDistribution(HypoxiaLevels, Glist, 'HbT', 0)
catch
    disp('HbO/HbR spatial distribution error')
    return;
end
 
    
    %% GCaMP data
    % To exclude Katy who doesn't have GCaMP activation
GlistGCaMP = [Glist(:,1:40), Glist(:,49:end)];


%% Correlation matrices
disp('GCaMP data Correlation Matrices');
try
    CombiCorrMatrices(HypoxiaLevels, GlistGCaMP, ManualInput);
    disp('GCaMP correlation Matrices done')
catch
    disp('GCaMP correlation Matrices error')
    return;
end

%% normoxia acquisitions
try 
    CompareNormoxia({'Normoxia_2', 'Normoxia_3', 'Normoxia_4'}, 'Normoxia_1', GlistGCaMP, ManualInput);
catch
    disp('GCaMP Normoxia comparison error')
    return;
end

%% Connectivity graphs
disp('GCaMP data Connectivity graph');
try
    CombiConnectivityGraph(HypoxiaLevels, ManualInput);
    disp('GCaMP connectivity graph done')
catch
    disp('GCaMP connectivity graph error')
    return;
end
    

%% Plot most changed seed pairs

    
end