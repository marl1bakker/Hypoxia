function PlotSeedPairs(GlistGCaMP, HypoxiaLevels, GSR)

if ~exist('GSR', 'var')
    GSR = 1;
end

%get prominent seeds
% SeedPairs = GetSeedPairs(0.15); %old way, no FDR
SeedPairs = GetSeedPairs(0.05, GSR); %with FDR

%or
% SeedPairs = {{'Mot R', 'Sen L'}, {'Mot L', 'Sen R'},...
%     {'Sen R', 'Sen L'}, {'Mot R', 'Mot L'}...,
%     {'Vis L', 'Vis R'}, ...
%     {'Ret R', 'Vis L'}, {'Ret L', 'Vis R'}};
% SeedPairs = {{'Ret R', 'Mot R'}, {'Ret L', 'Mot L'},...
%     {'Ret R', 'Mot L'}, {'Ret L', 'Mot R'}...,
%     {'Mot L', 'Vis L'}};


% To get cmatrix in SeedPairs
RealTimeSeedsCorrelation(GlistGCaMP, HypoxiaLevels, 0, GSR);

% To plot the timecourse of the seeds
% PlotRealTimeSeedsCorrelation(SeedPairs, HypoxiaLevels);

% To plot over levels: 
PlotSeedPairsOverHypoxLevels(SeedPairs, GSR);
PlotSeedPairsOverNormLevels(SeedPairs, GSR);

end









%% OLD
% SeedPairs = {{'Mot R', 'Sen L'}, {'Vis L', 'Vis R'}};
% HypoxiaLevels = {'Normoxia_1','Normoxia_2', 'Normoxia_3', 'Normoxia_4'};
% HypoxiaLevels = {'Normoxia_1', 'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Normoxia_2', 'Hypox_10', 'Normoxia_3',...
%     'Hypox_8_1', 'Normoxia_4', 'Hypox_8_2'};

% Condition = 'Hypoxia', 'Before', 'Difference'
% function PlotSeedPairs(SeedPairs, HypoxiaLevels)

% % startframe = 1;
% % endframe = 48000;
% % startframe = 12000;
% % endframe = 24000;
% % startframe = 1;
% % endframe = 10800; %first 9 minutes
% labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
% 
% %% For Plotting
% f = figure('InvertHardcopy','off','Color',[1 1 1]);
% axes1 = axes;
% hold(axes1,'on');
% set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
% f.Position = [10 10 1500 500]; %for size of screen before saving
% hold on
%     
% for idx = 1:size(SeedPairs, 2)
%     SeedPair = SeedPairs{idx};
%     CorrValues = [];
%     
%     index1 = find(contains(labels, SeedPair{1}));
%     index2 = find(contains(labels, SeedPair{2}));
%     
%     for ind = 1:size(HypoxiaLevels,2)
%         HypoxiaLevel = HypoxiaLevels{ind};
%         
%             CorrValue = Corr(index1, index2);
%      
%         
%         CorrValues = cat(2, CorrValues, CorrValue);
%     end
%     
%     % plot the progression of seed pair correlation changes
% plot(CorrValues, 'LineWidth', 2)
% SeedPairsLegend{idx} = [SeedPair{1} '-' SeedPair{2}];
% end 
% 
% legend(SeedPairsLegend)
% %% Save data
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/' HypoxiaLevel Condition '.tiff'])
% %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/' HypoxiaLevel Condition '.fig'])
%     
% close all
% 
% end