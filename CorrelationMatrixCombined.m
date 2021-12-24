%% Combined correlation matrix
%% take all seeds, calculate correlation for:
% - before hypox (5 min)
% - hypox (5 min)
% - after hypox (3x5 min)
Atlas = load('mouse_ctx_borders.mat','atlas');
areaTags = Atlas.atlas.areatag;
clear Atlas;

SeedPairsTag = [repelem(areaTags,48), repmat(areaTags,48,1)];
idx = arrayfun(@(x) strcmp(SeedPairsTag(x,1),SeedPairsTag(x,2)), 1:size(SeedPairsTag,1));
SeedPairsTag(idx,:) = [];
SeedPairsTag = unique(sort(string(SeedPairsTag),2),'rows');
clear idx areaTags

folders = {'TheGirlz', 'TheBoys'};

CombinedCorrelationMatrix = zeros(size(SeedPairsTag,1), 64*5);

acquisitions = {'/Normoxia_1', '/Hypox_12','/Normoxia_2','/Hypox_10', ...
    '/Normoxia_3','/Hypox_8_1','/Normoxia_4','/Hypox_8_2'};

for indF = 1:size(folders,2)
    folder = folders{indF};
    cd(['/media/mbakker/data1/Hypoxia' filesep folder])
    Mice = dir(['/media/mbakker/data1/Hypoxia' filesep folder]);
    idx = [Mice(:).isdir];
    Mice = Mice(idx); 
    clear idx;
    Mice(1:2)= [];
    for indM = 1:size(Mice,1)
        mouse = Mice(indM).name
        %         acquisitions = dir(['/media/mbakker/data1/Hypoxia' filesep folder filesep mouse]);
        for indA = 1:size(acquisitions,2)
            acquisition = acquisitions{indA}
            try
                cd(['/media/mbakker/data1/Hypoxia' filesep folder filesep mouse filesep acquisition])
                load('AllRoisGSR.mat', 'AllRois');
            catch
                CombinedCorrelationMatrix(:, ...
                    (size(Mice,1)*size(acquisitions,2)*5)*(indF-1) + ...
                    5*size(acquisitions,2)*(indM-1) + ...
                    5*(indA-1) + (1:5)) = nan;
                continue;
            end
            areaTags = AllRois(:,3);
            Mouse_SPTags = [repelem(areaTags,size(areaTags,1)), repmat(areaTags,size(areaTags,1),1)];
            idx = arrayfun(@(x) strcmp(Mouse_SPTags(x,1),Mouse_SPTags(x,2)), 1:size(Mouse_SPTags,1));
            Mouse_SPTags(idx,:) = [];
            Mouse_SPTags = unique(sort(string(Mouse_SPTags),2),'rows');
            
            Timecourses = reshape([AllRois{:,2}],[],size(AllRois,1));
            
            try
                CorrelationsBefore = corr(Timecourses(3000:9000,:));
                vBefore = nonzeros(reshape(tril(CorrelationsBefore,-1),[],1));
            catch
                vBefore = nan*ones(size(AllRois,1)*size(AllRois,1),1);
            end
            try
                CorrelationsHypoxia = corr(Timecourses(15000:21000,:));
                vHypox = nonzeros(reshape(tril(CorrelationsHypoxia,-1),[],1));
            catch
                vHypox = nan*ones(size(AllRois,1)*size(AllRois,1),1);
            end
            try
                CorrelationsAfter1 = corr(Timecourses(27000:33000,:));
                vA1 = nonzeros(reshape(tril(CorrelationsAfter1,-1),[],1));
            catch
                vA1 = nan*ones(size(AllRois,1)*size(AllRois,1),1);
            end
            try
                CorrelationsAfter2 = corr(Timecourses(33000:39000,:));
                vA2 = nonzeros(reshape(tril(CorrelationsAfter2,-1),[],1));
            catch
                vA2 = nan*ones(size(AllRois,1)*size(AllRois,1),1);
            end
            try
                CorrelationsAfter3 = corr(Timecourses(39000:45000,:));
                vA3 = nonzeros(reshape(tril(CorrelationsAfter3,-1),[],1));
            catch
                vA3 = nan*ones(size(AllRois,1)*size(AllRois,1),1);
            end
            
            clear idx areaTags
            
            (size(Mice,1)*size(acquisitions,2)*5)*(indF-1) + ...
                size(acquisitions,2)*5*(indM-1) + ...
                5*(indA-1) + (1:5)
            
            for indT = 1:size(SeedPairsTag,1)
                idx = find(arrayfun(@(x) all(strcmp(SeedPairsTag(indT,:),...
                    Mouse_SPTags(x,:))), 1:size(Mouse_SPTags,1)));
                if(isempty(idx))
                    CombinedCorrelationMatrix(indT, ...
                        (size(Mice,1)*size(acquisitions,2)*5)*(indF-1) + ...
                        size(acquisitions,2)*5*(indM-1) + ...
                        5*(indA-1) + (1:5)) = nan;
                else
                    CombinedCorrelationMatrix(indT, ...
                        (size(Mice,1)*size(acquisitions,2)*5)*(indF-1) + ...
                        size(acquisitions,2)*5*(indM-1) + ...
                        5*(indA-1) + (1:5)) = [vBefore(idx) vHypox(idx) vA1(idx) vA2(idx) vA3(idx)];
                end
            end
            imagesc(CombinedCorrelationMatrix);
            pause(0.01);
        end
    end
end