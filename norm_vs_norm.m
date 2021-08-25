%% Norm vs Norm to check

datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
mouse = 'Tom';
% mouse = 'Jane';
% mouse = 'Katy';
% mouse = 'Nick';

acquisition_norm1 = '/Normoxia_1';
acquisition_norm2 = '/Normoxia_2';

path_norm1 = strcat(datafolder, mouse, acquisition_norm1);
path_norm2 = strcat(datafolder, mouse, acquisition_norm2);

AllRois_norm1 = load(strcat(path_norm1,'/AllRois.mat'));
% AllRois_norm = load(strcat(path_norm,'/AllRoisGSR.mat'));
AllRois_norm1 = AllRois_norm1.AllRois;

AllRois_norm2 = load(strcat(path_norm2,'/AllRois.mat'));
% AllRois_hypox = load(strcat(path_hypox,'/AllRoisGSR.mat'));
AllRois_norm2 = AllRois_norm2.AllRois;

Infos = matfile([path_norm1 filesep 'fluo_475.mat']);
dims = [Infos.datSize(1,1), Infos.datSize(1,2), 48000]; %pak grootte van acquisition, en 48000 frames dus 40 min

%% Make sure your normoxia data and hypoxia data have the same ROI

%that
NamesNorm1 = arrayfun(@(x) AllRois_norm1{x,3}, 1:size(AllRois_norm1,1), 'UniformOutput', false); %is for loop in principe
NamesNorm2 = arrayfun(@(x) AllRois_norm2{x,3}, 1:size(AllRois_norm2,1), 'UniformOutput', false); %is for loop in principe

AreaNorm2Corrected = [];
AreaNorm1Corrected = [];
TimecoursesNorm1Corrected = [];
TimecoursesNorm2Corrected = [];
NamesNorm1Corrected = [];
NamesNorm2Corrected = [];
IndexnrNorm2Corrected = [];
IndexnrNorm1Corrected = [];
for ind = 1:size(NamesNorm1,2) %go over all roi in normoxia
    currentroi = NamesNorm1(ind); %give name that is in normoxia to currentroi
    if sum(matches(NamesNorm2, currentroi)) > 0 %if there is a roi in hypoxia with the same name, this will be larger than 0 so you will enter the function
        indNorm2 = find(matches(NamesNorm2, currentroi)); %find the index of the roi in hypoxia
        
        AreaNorm1Corrected = [AreaNorm1Corrected, AllRois_norm1(ind,1)];
        AreaNorm2Corrected = [AreaNorm2Corrected, AllRois_norm2(indNorm2,1)];
        
        TimecoursesNorm1Corrected = [TimecoursesNorm1Corrected, AllRois_norm1(ind,2)]; %add timecourse to corrected matrix
        TimecoursesNorm2Corrected = [TimecoursesNorm2Corrected, AllRois_norm2(indNorm2,2)]; %deze anders want wil alleen tot 48000
        
        NamesNorm1Corrected = [NamesNorm1Corrected, NamesNorm1(:,ind)]; %deze anders dan de anderen want je kan niet bij de naam als je oude manier houdt
        NamesNorm2Corrected = [NamesNorm2Corrected, NamesNorm2(:,indNorm2)];     
        
        IndexnrNorm1Corrected = [IndexnrNorm1Corrected, AllRois_norm1(ind,4)];
        IndexnrNorm2Corrected = [IndexnrNorm2Corrected, AllRois_norm2(indNorm2,4)];
    end
    %if the name of the roi is not both in normoxia and hypoxia, nothing
    %will happen and the roi will not be added to the corrected matrix
end

AllRoisNorm1Corrected = [AreaNorm1Corrected', TimecoursesNorm1Corrected', NamesNorm1Corrected', IndexnrNorm1Corrected'];
AllRoisNorm2Corrected = [AreaNorm2Corrected', TimecoursesNorm2Corrected', NamesNorm2Corrected', IndexnrNorm2Corrected'];

clear AreaNorm1Corrected AreaNorm2Corrected TimecoursesNorm1Corrected TimecoursesNorm2Corrected NamesNorm1Corrected NamesNorm2Corrected IndexnrNorm1Corrected IndexnrNorm2Corrected ind indNorm2 currentroi;

TimecoursesNorm2 = reshape([AllRoisNorm2Corrected{:,2}],size(AllRoisNorm2Corrected{1,2},2),[]);
TimecoursesNorm1 = reshape([AllRoisNorm1Corrected{:,2}],size(AllRoisNorm1Corrected{1,2},2),[]); %reshape naar aantal frames dat je hebt

%clip to 48000 frames
TimecoursesNorm1 = TimecoursesNorm1(1:48000,:);
TimecoursesNorm2 = TimecoursesNorm2(1:48000,:);

NamesNorm1 = arrayfun(@(x) AllRoisNorm1Corrected{x,3}, 1:size(AllRoisNorm1Corrected,1), 'UniformOutput', false); %is for loop in principe
NamesHypox = arrayfun(@(x) AllRoisNorm2Corrected{x,3}, 1:size(AllRoisNorm2Corrected,1), 'UniformOutput', false); %is for loop in principe

%%
CorrMatrixNorm1 = corr(TimecoursesNorm1(:,:));
CorrMatrixNorm2 = corr(TimecoursesNorm2(:,:));

%% 2D graph
cPairs = repelem(NamesNorm2,size(AllRoisNorm1Corrected,1)); %repeat the ROI name as many times as there are ROIs, so you can match them
cPairs(2,:) = repmat(NamesNorm2,1,size(AllRoisNorm1Corrected,1)); %same as above but in a different way, so that you have all possible pairs
Cnorm = zeros((48000-1200), size(AllRoisNorm1Corrected,1)*size(AllRoisNorm1Corrected,1),'single'); % maak lege matrix met grootte van roi x roi dus alle mogelijke paren
Chypox = zeros((48000-1200), size(AllRoisNorm2Corrected,1)*size(AllRoisNorm2Corrected,1),'single');

for ind = 601:(48000-600) %zorg dat je per min vanuit midden begint
    Cnorm(ind-600,:) = reshape(corr(TimecoursesNorm1((ind) + (-600:599),:)),[],1); %krijg lopende correlatie per minuut
    Chypox(ind-600,:) = reshape(corr(TimecoursesNorm2((ind) + (-600:599),:)),[],1);
end


for ind = 1:size(cPairs, 2) %Geef per ROI paar aan of het binnen linker of rechter hemispheer is, of interhemispheric
    if contains(cPairs(1,ind), '_R') && contains(cPairs(2,ind), '_R')
        cPairs(3,ind) = {'R'};
    elseif contains(cPairs(1,ind), '_L') && contains(cPairs(2,ind), '_L')
        cPairs(3,ind) = {'L'};
    else 
        cPairs(3,ind) = {'X'};
    end
end

idxRemove = arrayfun(@(x) matches(cPairs(1,x),cPairs(2,x)), 1:size(cPairs,2)); %verwijder correlaties met zichzelf
cPairs(:,idxRemove) = [];
Cnorm(:,idxRemove) = [];
Chypox(:,idxRemove) = [];

idxR = find(contains(cPairs(3,:),{'R'})); %zoek welke paren rechter hemispheer zijn
idxL = find(contains(cPairs(3,:),{'L'}));
idxX = find(contains(cPairs(3,:),'X'));

%normalise correlations
Cnorm = Cnorm - mean(Cnorm(1:1200,:),1);
Chypox = Chypox - mean(Chypox(1:1200,:),1);

figure()
imagesc(Chypox(:,[idxL, idxR, idxX])' - Cnorm(:,[idxL, idxR, idxX])')

title(strcat(mouse, ' Normoxia 1 vs Normoxia 2'));


%% histogram
IntraLim = find([AllRoisNorm1Corrected{:,4}] <= 24,1,'last');

Tmp = tril(CorrMatrixNorm1,-1); %tril is lower triangular of matrix
IntraLeftNorm = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterNorm = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightNorm = nonzeros(Tmp(1:IntraLim,1:IntraLim));
IntraNorm = [IntraLeftNorm(:); IntraRightNorm(:)];

Tmp = tril(CorrMatrixNorm2,-1);
IntraLeftHypox = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterHypox = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightHypox = nonzeros(Tmp(1:IntraLim,1:IntraLim));
IntraHypox = [IntraLeftHypox(:); IntraRightHypox(:)];

InterDiff = InterHypox - InterNorm;
IntraDiff = IntraHypox - IntraNorm;

%% histogram differences
histogram(InterDiff(:),-0.5:0.015:0.5)
hold
histogram(IntraDiff, -0.5:0.015:0.5);
legend('Inter', 'Intra')
title(mouse)
subtitle('Normoxia acquisition 1 minus normoxia acquisition 2')