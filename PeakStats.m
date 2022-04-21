%% Statistics on peaks
% 11-3-2022
% Gives the average of the peaks over all mice in the same hypoxia
% condition, the average of the baseline that it compares it to, the SEM,
% and the pvalue indicating significant difference.

% AveragePeak will give the average value over the windows around the peak
% for all mice in the same hypoxia condition on the left, and the SEM of
% that on the right. Similar for the rest. 

% To do statistics on a certain peak that you see in a linegraph. For
% example, a small peak at the beginning. You have to enter the center of
% the peak you want to investigate, and the window over which you want to
% take the average (default is 50 frames and will take 25 frames before and
% 25 frames after the center that you give).
% The baseline it compares the peak to is always a minute before the peak
%
% HypoxiaLevels, Glist: see HypoxPipelineCombi
% CenterOfPeak: the center of the peak you want to do stats on IN FRAMES
% CenterOfBaseline: ... also in frames
% window: the window around the center that you want to investigate
% Data: the data you want to do stats on


function [AveragePeak, AverageBaseline, pvalues, MaxPeak, MinPeak] = ...
    PeakStats(HypoxiaLevels, Glist, CenterOfPeak, CenterOfBaseline, Window, Data)

if ~exist('CenterOfBaseline', 'var') || isempty(CenterOfBaseline)
    CenterOfBaseline = CenterOfPeak - 1200; %minute before
end

if ~exist('Window', 'var') || isempty(Window)
    Window = 50;
end

pvalues = [];
AveragePeak = [];
AverageBaseline = [];
MaxPeak = [];
MinPeak = [];

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    DataPerHlevel = [];
    peak = [];
    baseline = [];
    maxpeak = [];
    minpeak = [];
    %     dips = [];
    
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
%             CorrectedData = Data(ind,:)
            DataPerHlevel = [DataPerHlevel; Data(ind, :)];
            
            % peak is around 10.07 minutes, so frame 12084
            peak = [peak; mean(Data(ind,...
                CenterOfPeak-(0.5*Window):CenterOfPeak+(0.5*Window)), 'omitnan')]; %get a window around the peak of spO2 of 50 frames
            
            baseline = [baseline; mean(Data(ind,...
                CenterOfBaseline-(0.5*Window):CenterOfBaseline+(0.5*Window)), 'omitnan')]; %get a window a minute before the peak, as a baseline to compare to
            
            maxpeak = [maxpeak, max(Data(ind,...
                CenterOfPeak-(0.5*Window):CenterOfPeak+(0.5*Window)))];
            
            minpeak = [minpeak, min(Data(ind,...
                CenterOfPeak-(0.5*Window):CenterOfPeak+(0.5*Window)))];
        end
    end
    
    %% Stats
    
    [~,p] = ttest(peak, baseline); %get p-value for the peak
    pvalues = [pvalues; p];
    AveragePeak = [AveragePeak; mean(peak, 'omitnan'), std(peak, 'omitnan')];
    AverageBaseline = [AverageBaseline; mean(baseline, 'omitnan'), std(baseline, 'omitnan')];
    MaxPeak = [MaxPeak; mean(maxpeak, 'omitnan'), std(maxpeak, 'omitnan')];
    MinPeak = [MinPeak; mean(minpeak, 'omitnan'), std(minpeak, 'omitnan')];
    
end

end
