% SeedPairs = {{'Mot R', 'Sen L'}, {'Vis L', 'Vis R'}};
% HypoxiaLevels = {'Normoxia_1','Normoxia_2', 'Normoxia_3', 'Normoxia_4'};
% HypoxiaLevels = {'Normoxia_1', 'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Normoxia_2', 'Hypox_10', 'Normoxia_3',...
%     'Hypox_8_1', 'Normoxia_4', 'Hypox_8_2'};

% Condition = 'Hypoxia', 'Before', 'Difference'
function PlotSeedPairs(SeedPairs, HypoxiaLevels, Condition)
labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};

%% For Plotting
f = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes;
hold(axes1,'on');
set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
f.Position = [10 10 1500 500]; %for size of screen before saving
hold on
    
for idx = 1:size(SeedPairs, 2)
    SeedPair = SeedPairs{idx};
    CorrValues = [];
    
    index1 = find(contains(labels, SeedPair{1}));
    index2 = find(contains(labels, SeedPair{2}));
    
    for ind = 1:size(HypoxiaLevels,2)
        HypoxiaLevel = HypoxiaLevels{ind};
        
        % Get right data 
        if matches(Condition, 'Hypoxia')
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
            CorrHypox = mean(CorrHypox, 3, 'omitnan');
            CorrValue = CorrHypox(index1, index2);
        elseif matches(Condition, 'Before')
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
            CorrBefore = mean(CorrBefore, 3, 'omitnan');
            CorrValue = CorrBefore(index1, index2);
        else %So difference
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
            CorrHypox = mean(CorrHypox, 3, 'omitnan');
            CorrBefore = mean(CorrBefore, 3, 'omitnan');
            CorrValue = CorrHypox(index1, index2) - CorrBefore(index1, index2);
        end
        
        CorrValues = cat(2, CorrValues, CorrValue);
    end
    
    % plot the progression of seed pair correlation changes
plot(CorrValues, 'LineWidth', 2)
SeedPairsLegend{idx} = [SeedPair{1} '-' SeedPair{2}];
end 

legend(SeedPairsLegend)
%% Save data
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/' HypoxiaLevel Condition '.tiff'])
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/' HypoxiaLevel Condition '.fig'])
    
close all

end