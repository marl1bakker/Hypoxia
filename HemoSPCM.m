%% Make seed pixel correlation maps hemodata

load('/media/mbakker/data1/Hypoxia/Glist.mat')

%% last step HypoxPipeline
for index = 1:size(Glist,2)
    DataFolder = Glist(index).name;
    disp(DataFolder)
    
    if( ~strcmp(DataFolder(end), filesep) )
        DataFolder = [DataFolder filesep];
    end
    
    % Seed generator & Timecourse calculator
    SeedGeneratorHbO(DataFolder, 'BigROI.mat', 1, 0); %can be changed for 'ROI_149.mat', and No GSR
    
end

%% HypoxPipelineCombi
HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
    'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};

CombiCorrMatricesHbO(HypoxiaLevels, Glist, 1, 1); %can be changed to no GSR


