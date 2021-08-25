datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
mouse = 'Tom';
% mouse = 'Jane';
% mouse = 'Katy';
% mouse = 'Nick';

acquisition_norm = '/Normoxia_1';
acquisition_hypox = '/Hypox_12';

path_norm = strcat(datafolder, mouse, acquisition_norm);
path_hypox = strcat(datafolder, mouse, acquisition_hypox);

AllRois_norm = load(strcat(path_norm,'/AllRois.mat'));
% AllRois_norm = load(strcat(path_norm,'/AllRoisGSR.mat'));
AllRois_norm = AllRois_norm.AllRois;

AllRois_hypox = load(strcat(path_hypox,'/AllRois.mat'));
% AllRois_hypox = load(strcat(path_hypox,'/AllRoisGSR.mat'));
AllRois_hypox = AllRois_hypox.AllRois;

Infos = matfile([path_norm filesep 'fluo_475.mat']);
dims = [Infos.datSize(1,1), Infos.datSize(1,2), 48000]; %pak grootte van acquisition, en 48000 frames dus 40 min

%% Make sure your normoxia data and hypoxia data have the same ROI

%that
NamesNorm = arrayfun(@(x) AllRois_norm{x,3}, 1:size(AllRois_norm,1), 'UniformOutput', false); %is for loop in principe
NamesHypox = arrayfun(@(x) AllRois_hypox{x,3}, 1:size(AllRois_hypox,1), 'UniformOutput', false); %is for loop in principe

AreaHypoxCorrected = [];
AreaNormCorrected = [];
TimecoursesNormCorrected = [];
TimecoursesHypoxCorrected = [];
NamesNormCorrected = [];
NamesHypoxCorrected = [];
IndexnrHypoxCorrected = [];
IndexnrNormCorrected = [];
for ind = 1:size(NamesNorm,2) %go over all roi in normoxia
    currentroi = NamesNorm(ind); %give name that is in normoxia to currentroi
    if sum(matches(NamesHypox, currentroi)) > 0 %if there is a roi in hypoxia with the same name, this will be larger than 0 so you will enter the function
        indHypox = find(matches(NamesHypox, currentroi)); %find the index of the roi in hypoxia
        
        AreaNormCorrected = [AreaNormCorrected, AllRois_norm(ind,1)];
        AreaHypoxCorrected = [AreaHypoxCorrected, AllRois_hypox(indHypox,1)];
        
        TimecoursesNormCorrected = [TimecoursesNormCorrected, AllRois_norm(ind,2)]; %add timecourse to corrected matrix
        TimecoursesHypoxCorrected = [TimecoursesHypoxCorrected, AllRois_hypox(indHypox,2)]; %deze anders want wil alleen tot 48000
        
        NamesNormCorrected = [NamesNormCorrected, NamesNorm(:,ind)]; %deze anders dan de anderen want je kan niet bij de naam als je oude manier houdt
        NamesHypoxCorrected = [NamesHypoxCorrected, NamesHypox(:,indHypox)];     
        
        IndexnrNormCorrected = [IndexnrNormCorrected, AllRois_norm(ind,4)];
        IndexnrHypoxCorrected = [IndexnrHypoxCorrected, AllRois_hypox(indHypox,4)];
    end
    %if the name of the roi is not both in normoxia and hypoxia, nothing
    %will happen and the roi will not be added to the corrected matrix
end

AllRoisNormCorrected = [AreaNormCorrected', TimecoursesNormCorrected', NamesNormCorrected', IndexnrNormCorrected'];
AllRoisHypoxCorrected = [AreaHypoxCorrected', TimecoursesHypoxCorrected', NamesHypoxCorrected', IndexnrHypoxCorrected'];

clear AreaNormCorrected AreaHypoxCorrected TimecoursesNormCorrected TimecoursesHypoxCorrected NamesNormCorrected NamesHypoxCorrected IndexnrNormCorrected IndexnrHypoxCorrected ind indHypox currentroi;

TimecoursesHypox = reshape([AllRoisHypoxCorrected{:,2}],size(AllRoisHypoxCorrected{1,2},2),[]);
TimecoursesNorm = reshape([AllRoisNormCorrected{:,2}],size(AllRoisNormCorrected{1,2},2),[]); %reshape naar aantal frames dat je hebt

%clip to 48000 frames
TimecoursesNorm = TimecoursesNorm(1:48000,:);
TimecoursesHypox = TimecoursesHypox(1:48000,:);

NamesNorm = arrayfun(@(x) AllRoisNormCorrected{x,3}, 1:size(AllRoisNormCorrected,1), 'UniformOutput', false); %is for loop in principe
NamesHypox = arrayfun(@(x) AllRoisHypoxCorrected{x,3}, 1:size(AllRoisHypoxCorrected,1), 'UniformOutput', false); %is for loop in principe

%%
% CorrMatrixNorm = corr(TimecoursesNorm(13200:24000,:));
% CorrMatrixHypox = corr(TimecoursesHypox(13200:24000,:));
CorrMatrixNorm = corr(TimecoursesNorm(:,:));
CorrMatrixHypox = corr(TimecoursesHypox(:,:));

%% 2D graph
cPairs = repelem(NamesNorm,size(AllRoisNormCorrected,1)); %repeat the ROI name as many times as there are ROIs, so you can match them
cPairs(2,:) = repmat(NamesNorm,1,size(AllRoisNormCorrected,1)); %same as above but in a different way, so that you have all possible pairs
Cnorm = zeros((48000-1200), size(AllRoisNormCorrected,1)*size(AllRoisNormCorrected,1),'single'); % maak lege matrix met grootte van roi x roi dus alle mogelijke paren
Chypox = zeros((48000-1200), size(AllRoisHypoxCorrected,1)*size(AllRoisHypoxCorrected,1),'single');

for ind = 601:(48000-600) %zorg dat je per min vanuit midden begint
    Cnorm(ind-600,:) = reshape(corr(TimecoursesNorm((ind) + (-600:599),:)),[],1); %krijg lopende correlatie per minuut
    Chypox(ind-600,:) = reshape(corr(TimecoursesHypox((ind) + (-600:599),:)),[],1);
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
line([12000-1200, 12000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(Cnorm,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(Cnorm,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');

title(strcat(mouse, ' Hypoxia 12% minus Normoxia'));


%% histogram
IntraLim = find([AllRoisNormCorrected{:,4}] <= 24,1,'last');

Tmp = tril(CorrMatrixNorm,-1); %tril is lower triangular of matrix
IntraLeftNorm = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterNorm = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightNorm = nonzeros(Tmp(1:IntraLim,1:IntraLim));
IntraNorm = [IntraLeftNorm(:); IntraRightNorm(:)];

Tmp = tril(CorrMatrixHypox,-1);
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
subtitle('Hypoxia acquisition minus normoxia acquisition')

















%% put things in easy way
% Names = arrayfun(@(x) AllRois_norm{x,3}, 1:size(AllRois_norm,1), 'UniformOutput', false); %is for loop in principe
NamesNorm = arrayfun(@(x) AllRois_norm{x,3}, 1:size(AllRois_norm,1), 'UniformOutput', false); %is for loop in principe
NamesHypox = arrayfun(@(x) AllRois_hypox{x,3}, 1:size(AllRois_hypox,1), 'UniformOutput', false); %is for loop in principe

% Timecourses_norm = reshape([AllRois_norm{:,2}],[],size(AllRois_norm,1)) - 1;
% Timecourses_norm = Timecourses_norm(1:48000,:); %knip zodat je "maar" 48000 frames hebt, en voor hypox en normox hetzelfde aantal
% 
% Timecourses_hypox = reshape([AllRois_hypox{:,2}],[],size(AllRois_hypox,1)) - 1;
% Timecourses_hypox = Timecourses_hypox(1:48000,:);

TimecoursesNorm = reshape([AllRois_norm{:,2}],size(AllRois_norm{1,2},2),[]);
TimecoursesHypox = reshape([AllRois_hypox{:,2}],size(AllRois_hypox{1,2},2),[]); %reshape naar aantal frames dat je hebt

%clip to 48000 frames
TimecoursesNorm = TimecoursesNorm(1:48000,:);
TimecoursesHypox = TimecoursesHypox(1:48000,:);


%% 2D graph
cPairs = repelem(Names,size(AllRoisNormCorrected,1)); %repeat the ROI name as many times as there are ROIs, so you can match them
cPairs(2,:) = repmat(Names,1,size(AllRoisNormCorrected,1)); %same as above but in a different way, so that you have all possible pairs
Cnorm = zeros((48000-1200), size(AllRoisNormCorrected,1)*size(AllRoisNormCorrected,1),'single'); % maak lege matrix met grootte van roi x roi dus alle mogelijke paren
Chypox = zeros((48000-1200), size(AllRoisHypoxCorrected,1)*size(AllRoisHypoxCorrected,1),'single');

for ind = 601:(48000-600) %zorg dat je per min vanuit midden begint
    Cnorm(ind-600,:) = reshape(corr(TimecoursesNorm((ind) + (-600:599),:)),[],1); %krijg lopende correlatie per minuut
    Chypox(ind-600,:) = reshape(corr(TimecoursesHypox((ind) + (-600:599),:)),[],1);
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

%Plot!
imagesc(Cnorm(:,[idxL, idxR, idxX])') %plot links, rechts en interhemispheric

line([12000-1200, 12000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(Cnorm,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(Cnorm,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');
title(strcat(mouse, ' Normoxia ')); 

figure()
imagesc(Chypox(:,[idxL, idxR, idxX])')

line([12000-1200, 12000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(Cnorm,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(Cnorm,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');
title(strcat(mouse, ' Hypoxia, 12% ')); 

figure()
imagesc(Chypox(:,[idxL, idxR, idxX])' - Cnorm(:,[idxL, idxR, idxX])')
line([12000-1200, 12000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [1, size(Cnorm,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(Cnorm,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(Cnorm,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');

title(strcat(mouse, ' Hypoxia 12% minus Normoxia'));



%%

plot(mean(Chypox(:,idxL),2))


%% 1/f
A = spectrogram(Timecourses_hypox(:,6), 1200, 1199, 0.2:0.1:3, 20);
OneOverF = 1./(0.2:0.1:3);
A = A./OneOverF';

%% dat hypox voor nodig
fid = fopen('fChanCor.dat');
dat = fread(fid,inf,'*single');
Infos = matfile('fluo_475.mat');
%AcqInfoStream = ReadInfoFile(datafolder);
dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
fclose(fid);

%%
FftDat_Norm = fft(dat(:,:,1:12000),[],3);
FftDat_Hypox = fft(dat(:,:,12001:24000),[],3);
FftDat_ReNorm = fft(dat(:,:,24001:36000),[],3);
% 
% FftDat_Norm = reshape(FftDat_Norm,192,192,12,[]);
% FftDat_Hypox = reshape(FftDat_Hypox,192,192,12,[]);
% FftDat_ReNorm = reshape(FftDat_ReNorm,192,192,12,[]);
% FftDat_Norm = squeeze(mean(FftDat_Norm,3));
% FftDat_Hypox = squeeze(mean(FftDat_Hypox,3));
% FftDat_ReNorm = squeeze(mean(FftDat_ReNorm,3));
Freq = linspace(0,10,size(FftDat_Norm,3));
FftDat_Norm = bsxfun(@rdivide, FftDat_Norm, permute(Freq,[3 1 2]));
FftDat_Hypox = bsxfun(@rdivide, FftDat_Hypox, permute(Freq,[3 1 2]));
FftDat_ReNorm = bsxfun(@rdivide, FftDat_ReNorm, permute(Freq,[3 1 2]));
figure(1);
figure(2);
figure(3);
for ind = 2500:size(FftDat_Norm,3)
    figure(1);
    PowerN = abs(squeeze(FftDat_Norm(:,:,ind)));
    imagesc(PowerN);
    figure(2);
    PowerH = abs(squeeze(FftDat_Hypox(:,:,ind)));
    imagesc(PowerH);
    figure(3);
    imagesc(PowerN - PowerH)
%     imagesc(angle(squeeze(FftDat_Norm(:,:,ind))));
%     hold('on');
%     imagesc(zeros(192),'AlphaData',Power<1e3)
%     hold('off');
%     colormap 'hsv'
     title(num2str(Freq(ind)));
    pause(0.1);
end




%%
IntraLim = find([AllRoisNormCorrected{:,4}] <= 24,1,'last');

% Tmp = tril(CMatrixDiff,-1);
% IntraLeft = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
% Inter = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
% IntraRight = nonzeros(Tmp(1:IntraLim,1:IntraLim));

Tmp = tril(CorrMatrixNorm,-1); %tril is lower triangular of matrix
IntraLeftNorm = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterNorm = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightNorm = nonzeros(Tmp(1:IntraLim,1:IntraLim));
IntraNorm = [IntraLeftNorm(:); IntraRightNorm(:)];

Tmp = tril(CorrMatrixHypox,-1);
IntraLeftHypox = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterHypox = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightHypox = nonzeros(Tmp(1:IntraLim,1:IntraLim));
IntraHypox = [IntraLeftHypox(:); IntraRightHypox(:)];

InterDiff = InterHypox - InterNorm;
% IntraDiffRight = IntraRightHypox - IntraRightNorm;
% IntraDiffLeft = IntraLeftHypox - IntraLeftNorm;
% IntraDiff = [IntraDiffRight(:); IntraDiffLeft(:)];
IntraDiff = IntraHypox - IntraNorm;

%% histogram differences
histogram(InterDiff(:),-0.5:0.015:0.5)
hold
histogram(IntraDiff, -0.5:0.015:0.5);
legend('Inter', 'Intra')
title(mouse)

% %% histogram all four bla
% H1 = histogram(InterNorm(:),0:0.005:1)
% hold
% H2 = histogram(IntraNorm(:),0:0.005:1)
% H3 = histogram(InterHypox(:),0:0.005:1)
% H4 = histogram(IntraHypox(:),0:0.005:1)
% legend('Inter norm','Intra Norm', 'Inter Hypox', 'Intra Hypox')