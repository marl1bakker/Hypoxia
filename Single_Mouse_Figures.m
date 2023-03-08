%% Examples of 1 mouse - Nick & 227
% For Images in Article
% figure with seeds and correlation matrices and overview maps are of 227
% load('/media/mbakker/data1/Hypoxia/Glist.mat')
% 
% for index = 1:size(Glist,2)
%     HypoxPipeline(Glist(index).name, 0)
% end

%% Seed pixel correlation maps, 227, hemodynamics
Seednames = {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'};
% DataTypes = {'HbR', 'HbT'};
DataTypes = {'HbO', 'HbR', 'HbT'};
HypoxiaLevels = {'Normoxia_1', 'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

for ind1 = 1:size(HypoxiaLevels,2)
    for ind2 = 1:size(DataTypes,2)
        HemoSeedPixelCorrelationMap(DataTypes{ind2}, ...
            ['/media/mbakker/data1/Hypoxia/TheBoys/227/' HypoxiaLevels{ind1}], ...
            Seednames, 1, 15000, 21000, 0); %last one is GSR/noGSR
    end
end


%% Seed pixel correlation maps, 227, fluo

for ind1 = 1:size(HypoxiaLevels,2)
    SeedPixelCorrelationMap(['/media/mbakker/data1/Hypoxia/TheBoys/227/' HypoxiaLevels{ind1}], ...
        {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, ...
        1, 15000, 21000, 0) %last one is GSR/noGSR
end


%correlation matrix
%change in combicorrmatrices the .png to the .tiff and comment the save.mat

% HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
%     'Normoxia_1'};
% Glist227 = Glist(9:13);
% CombiCorrMatrices(HypoxiaLevels, Glist227, 1);
% ConnectivityGraph(HypoxiaLevels, '227', 0);


%% hemodynamics spatial distribution
load('/media/mbakker/data1/Hypoxia/Glist.mat')
Glist227 = Glist(9:13);

SpatialDistribution(HypoxiaLevels, Glist227, 'HbO', 1, 1) %last one GSR
SpatialDistribution(HypoxiaLevels, Glist227, 'HbR', 1, 1)
SpatialDistribution(HypoxiaLevels, Glist227, 'HbT', 1, 1)
SpatialDistribution(HypoxiaLevels, Glist227, 'spO2', 1, 1)

SpatialDistribution(HypoxiaLevels, Glist227, 'HbO', 1, 0) %last one GSR
SpatialDistribution(HypoxiaLevels, Glist227, 'HbR', 1, 0)
SpatialDistribution(HypoxiaLevels, Glist227, 'HbT', 1, 0)
SpatialDistribution(HypoxiaLevels, Glist227, 'spO2', 1, 0)
