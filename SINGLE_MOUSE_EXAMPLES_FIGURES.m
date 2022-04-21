%% Examples of 1 mouse - Nick
% For Images in Article
load('/media/mbakker/data1/Hypoxia/Glist.mat')

for index = 1:size(Glist,2)
    HypoxPipeline(Glist(index).name, 0)
end

HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
    'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};

TitleList = {'spO2 levels - 12% oxygen', 'spO2 levels - 10% oxygen', ...
    'spO2 levels - 8% oxygen', 'spO2 levels - 8% oxygen (2)', ...
    'spO2 levels - Normoxia (1)', 'spO2 levels - Normoxia (2)', ...
    'spO2 levels - Normoxia (3)', 'spO2 levels - Normoxia (4)'};

%seed pixel correaltion maps of Nick (best subject)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheGirls/Nick/Normoxia_1', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheGirls/Nick/Hypox_12', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheGirls/Nick/Hypox_10', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheGirls/Nick/Hypox_8_2', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)

SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheBoys/227/Normoxia_1', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheBoys/227/Hypox_12', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheBoys/227/Hypox_10', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheBoys/227/Hypox_8_2', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)
SeedPixelCorrelationMap('/media/mbakker/data1/Hypoxia/TheBoys/227/Hypox_8_1', {'SensoryROI_R', 'MotorROI_R', 'UnknownROI_R', 'VisualROI_R', 'AuditoryROI_R'}, 1, 18000, 22800)


%correlation matrix
%change in combicorrmatrices the .png to the .tiff and comment the save.mat
GlistNick = Glist(49:56);
CombiCorrMatrices(HypoxiaLevels, GlistNick, 1);
CombiConnectivityGraph(HypoxiaLevels, 0);

HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
    'Normoxia_1'};
Glist227 = Glist(9:13);
CombiCorrMatrices(HypoxiaLevels, Glist227, 1);
ConnectivityGraph(HypoxiaLevels, '227', 0);
SpatialDistribution(HypoxiaLevels, Glist227, 'HbO', 0)
SpatialDistribution(HypoxiaLevels, Glist227, 'HbR', 0)
SpatialDistribution(HypoxiaLevels, Glist227, 'HbT', 0)
