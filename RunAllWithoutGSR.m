% 11/1/23
% For submission to scientific reports (feedback from JCB)

% create files without GSR

load('/media/mbakker/data1/Hypoxia/Glist.mat')

%% last step HypoxPipeline
for index = 1:size(Glist,2)
    DataFolder = Glist(index).name;
    disp(DataFolder)
    
    if( ~strcmp(DataFolder(end), filesep) )
        DataFolder = [DataFolder filesep];
    end
    
    % Seed generator & Timecourse calculator
    SeedGenerator(DataFolder, 'BigROI.mat', 1, 0); %can be changed for 'ROI_149.mat', and No GSR
    
end

%% HypoxPipelineCombi

GlistGCaMP = [Glist(:,1:40), Glist(:,49:end)];

HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
    'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};

% correlation matrixes
CombiCorrMatrices(HypoxiaLevels, GlistGCaMP, 0, 0); %dont overwrite, no GSR

%stats normoxia
[pvalues, qvalues] = CompareNormoxiaFriedman(HypoxiaLevels, 0);
disp('p values');
disp(pvalues)
disp('q values');
disp(qvalues)

% STats gcamp
StatsForGCaMPData(HypoxiaLevels, {'Diff'}, 0);

PlotSeedPairs(GlistGCaMP, HypoxiaLevels, 0);



