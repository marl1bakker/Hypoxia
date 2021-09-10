%% HbO/HbR
% ImagesClassification(pwd, pwd, 1, 1, 1, 0);
% datafolder = pwd;

%%
datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
% mouse = 'Tom';
% mouse = 'Jane';
% mouse = 'Katy';
mouse = 'Nick';

acquisition_norm = '/Normoxia_1';
acquisition_hypox12 = '/Hypox_12';
acquisition_norm2 = '/Normoxia_2';
acquisition_hypox10 = '/Hypox_10';
acquisition_norm3 = '/Normoxia_3';

% currentacq = replace(acquisition_hypox10, '/', '');

path_norm = strcat(datafolder, mouse, acquisition_norm);
path_hypox12 = strcat(datafolder, mouse, acquisition_hypox12);
path_norm2 = strcat(datafolder, mouse, acquisition_norm2);
path_hypox10 = strcat(datafolder, mouse, acquisition_hypox10);
path_norm3 = strcat(datafolder, mouse, acquisition_norm3);

datafolder = path_hypox10;
cd(datafolder);
videoname = mouse;

Infos = matfile('fluo_475.mat');
dims = [Infos.datSize(1,1), Infos.datSize(1,2), Infos.datLength];

%% Get data
AcqInfoStream = ReadInfoFile(datafolder);
fid = fopen('red.dat');
datr = fread(fid,inf,'*single');
datr = reshape(datr,AcqInfoStream.Width,AcqInfoStream.Height,[]);
fclose(fid);
datr = -log(datr./mean(datr(:,:,1:12000),3));
C = datr(:);
clear datr;

fid = fopen('green.dat');
datg = fread(fid,inf,'*single');
datg = reshape(datg,AcqInfoStream.Width,AcqInfoStream.Height,[]);
datg = -log(datg./mean(datg(:,:,1:12000),3));
C = [C, datg(:)];
clear datg;

fid = fopen('yellow.dat');
daty = fread(fid,inf,'*single');
daty = reshape(daty,AcqInfoStream.Width,AcqInfoStream.Height,[]);
fclose(fid);
daty = -log(daty./mean(daty(:,:,1:12000),3));
C = [C, daty(:)];
clear daty;

%%
eps = ioi_epsilon_pathlength('Hillman', 100, 60, 40, 0); %get pathlengths
Ainv = pinv(eps); %pseudoinverse of eps matrix (inverse niet mogelijk, want niet vierkant, dus soort benadering - Moore-penrose))

Hbs = Ainv*C';

HbO = reshape(Hbs(1,:), dims(1),dims(2),[]);
HbR = reshape(Hbs(2,:), dims(1),dims(2),[]);
clear Hbs C 

HbO = permute(HbO,[2,1,3]);
HbR = permute(HbR,[2,1,3]);

%% Normalisation and filtering

% HbO = NormalisationFiltering(HbO, 1/120, 1/10, 1); %nul is voor delen door, 1 is voor min voor hbo/hbr

%% Save Stuff
save('Hbo.mat', 'HbO', '-v7.3');
save('Hbr.mat', 'HbR', '-v7.3');

%% For AllRois

load('Hbo.mat')
load('Hbr.mat')
load('tform.mat')
for ind = 1:size(HbO,3)
    HbO(:,:,ind) = imwarp(squeeze(HbO(:,:,ind)), tform, 'OutputView',imref2d([size(HbO,1), size(HbO,2)]));
    HbR(:,:,ind) = imwarp(squeeze(HbR(:,:,ind)), tform, 'OutputView',imref2d([size(HbR,1), size(HbR,2)]));
end

imshowpair(HbO(:,:,1),HbR(:,:,1));

load(strcat(path_norm,'/ROI_Stretched.mat'));
HbR = HbR*1e6; %ga van mol naar micromol
HbO = HbO*1e6;

%% Make AllRois variables 
% load(strcat(path_norm,'/ROI_.mat'));
load(strcat(path_norm,'/ROI_Stretched.mat'));

dat = reshape(HbR,dims);
[CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
save('AllRoisHbR.mat', 'AllRois');
clear AllRois
close all

mkdir ./Figures/HbR
movefile ./Figures/CMatrixHypoxia.png ./Figures/HbR
movefile ./Figures/CMatrixBefore.png ./Figures/HbR
movefile ./Figures/CMatrixAfter.png ./Figures/HbR

mkdir ./Figures/HbRstretchedROI
movefile ./Figures/CMatrixHypoxia.png ./Figures/HbRstretchedROI
movefile ./Figures/CMatrixBefore.png ./Figures/HbRstretchedROI
movefile ./Figures/CMatrixAfter.png ./Figures/HbRstretchedROI

dat = reshape(HbO,dims);
[CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
save('AllRoisHbO.mat', 'AllRois');
clear AllRois
close all

mkdir ./Figures/HbO
movefile ./Figures/CMatrixHypoxia.png ./Figures/HbO
movefile ./Figures/CMatrixBefore.png ./Figures/HbO
movefile ./Figures/CMatrixAfter.png ./Figures/HbO

mkdir ./Figures/HbOstretchedROI
movefile ./Figures/CMatrixHypoxia.png ./Figures/HbOstretchedROI
movefile ./Figures/CMatrixBefore.png ./Figures/HbOstretchedROI
movefile ./Figures/CMatrixAfter.png ./Figures/HbOstretchedROI
%% load data
AllRoisHbR = load('AllRoisHbR.mat');
AllRoisHbR = AllRoisHbR.AllRois;

AllRoisHbO = load('AllRoisHbO.mat');
AllRoisHbO = AllRoisHbO.AllRois;

%% make plots for M1R and BCL

Names = arrayfun(@(x) AllRoisHbR{x,3}, 1:size(AllRoisHbR,1), 'UniformOutput', false); %is for loop in principe
indexroiMC1R = find(contains(Names,'M1_R'));
indexroiBCL = find(contains(Names,'BC_L'));

M1R_HbR = AllRoisHbR{indexroiMC1R,2};
BCL_HbR = AllRoisHbR{indexroiBCL,2};

M1R_HbO = AllRoisHbO{indexroiMC1R,2};
BCL_HbO = AllRoisHbO{indexroiBCL,2};

Hb_oneseed([M1R_HbO; M1R_HbR; M1R_HbR+M1R_HbO]')
saveas(gcf, './Figures/M1R.png');
Hb_oneseed([BCL_HbO; BCL_HbR; BCL_HbR+BCL_HbO]')
saveas(gcf, './Figures/BCL.png');

Hb_oneseed([M1R_HbO; M1R_HbR; M1R_HbR+M1R_HbO]')
saveas(gcf, './Figures/M1RstretchedROI.png');
Hb_oneseed([BCL_HbO; BCL_HbR; BCL_HbR+BCL_HbO]')
saveas(gcf, './Figures/BCLstretchedROI.png');

%% Graphs
HistogramInterIntra(AllRoisHbR, 'HbR Tom');
close all
CorrelationLineGraphInterIntra(AllRoisHbR, 'HbR Tom');
close all
Graph2D(AllRoisHbR, 'HbR Tom');
close all

movefile ./Figures/Histogram.png ./Figures/HbR
movefile ./Figures/Scatterplot.png ./Figures/HbR
movefile ./Figures/MedianLineGraph.png ./Figures/HbR
movefile ./Figures/MeanLineGraph.png ./Figures/HbR
movefile ./Figures/Graph2D.png ./Figures/HbR

movefile ./Figures/Histogram.png ./Figures/HbRstretchedROI
movefile ./Figures/Scatterplot.png ./Figures/HbRstretchedROI
movefile ./Figures/MedianLineGraph.png ./Figures/HbRstretchedROI
movefile ./Figures/MeanLineGraph.png ./Figures/HbRstretchedROI
movefile ./Figures/Graph2D.png ./Figures/HbRstretchedROI

HistogramInterIntra(AllRoisHbO, 'HbO Tom');
close all
CorrelationLineGraphInterIntra(AllRoisHbO, 'HbO Tom');
close all
Graph2D(AllRoisHbO, 'HbO Tom');
close all

movefile ./Figures/Histogram.png ./Figures/HbO
movefile ./Figures/Scatterplot.png ./Figures/HbO
movefile ./Figures/MedianLineGraph.png ./Figures/HbO
movefile ./Figures/MeanLineGraph.png ./Figures/HbO
movefile ./Figures/Graph2D.png ./Figures/HbO

movefile ./Figures/Histogram.png ./Figures/HbOstretchedROI
movefile ./Figures/Scatterplot.png ./Figures/HbOstretchedROI
movefile ./Figures/MedianLineGraph.png ./Figures/HbOstretchedROI
movefile ./Figures/MeanLineGraph.png ./Figures/HbOstretchedROI
movefile ./Figures/Graph2D.png ./Figures/HbOstretchedROI

%% Visualisation data
HbO = reshape(HbO,dims(1),dims(2),[]);
figure;
for ind = 20000:20:25000
    imagesc((squeeze(HbO(:,:,ind))), [-15 15]);
    title(int2str(ind));
    axis image
    pause(0.01);
end
    
HbR = reshape(HbR,dims(1),dims(2),[]);
figure;
for ind = 1:1:12000
    imagesc((squeeze(HbR(:,:,ind))), [-15 15]);
    title(int2str(ind));
    axis image
    pause(0.01);
end

AcqInfoStream = ReadInfoFile(datafolder);
fid = fopen('green.dat');
datg = fread(fid,inf,'*single');
datg = reshape(datg,dims(1),dims(2),[]);  

AcqInfoStream = ReadInfoFile(datafolder);
fid = fopen('green.dat');
datg2 = fread(fid,inf,'*single');
datg2 = reshape(datg2,dims(1),dims(2),[]);
datg2 = datg2 ./ mean(datg2, 3);
figure;
for ind = 1:1:12000
    imagesc((squeeze(datg2(:,:,ind))));
    title(int2str(ind));
    axis image
    pause(0.01);
end

fid = fopen('red.dat');
datr = fread(fid,inf,'*single');
datr = reshape(datr,dims(1),dims(2),[]);
datr = datr - mean(datr, 3);
figure;
for ind = 1:1:12000
    imagesc((squeeze(datr(:,:,ind))));
    title(int2str(ind));
    axis image
    pause(0.01);
end

fid = fopen('yellow.dat');
daty = fread(fid,inf,'*single');
daty = reshape(daty,dims(1),dims(2),[]);
daty = daty - mean(daty, 3);
figure;
for ind = 1:1:12000
    imagesc((squeeze(daty(:,:,ind))));
    title(int2str(ind));
    axis image
    pause(0.01);
end

fid = fopen('fluo_475.dat');
datf = fread(fid,inf,'*single');
datf = reshape(datf,dims(1),dims(2),[]);
datf = datf - mean(datf, 3);
figure;
for ind = 1:1:12000
    imagesc((squeeze(datf(:,:,ind))));
    title(int2str(ind));
    axis image
    pause(0.01);
end

%% Average over a minute hypox vs a minute normox
% Time = linspace(0, (48000-1)/20, 48000); %delen door 20 want 20 Hz
% Time = reshape(Time,1200,[]); %1200 want 20 Hz x 60 sec - tijd per min
% timecorrected = cat(2,Time(1:end));
load('tform.mat')
load('Mask.mat');
Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask)));

%to know when the hypoxia period was
fileID = fopen('Acquisition_information.txt');
bstop = 0;
while (bstop == 0) || ~feof(fileID)
   Textline = fgetl(fileID);
   if endsWith(Textline,'min')
       bstop = 1;
   end
end

hypoxmin = str2num(Textline(1:2));
hypoxbegin = hypoxmin * 60 * 20;
hypoxend = hypoxbegin + 12000;

hypoxminHbO = HbO(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
hypoxminHbR = HbR(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
normoxminHbO = HbO(:,:,(5*60*20):(6*60*20)); %minute 5 to 6
normoxminHbR = HbR(:,:,(5*60*20):(6*60*20));

hypoxminHbO = hypoxminHbO .* Mask;
hypoxminHbR = hypoxminHbR .* Mask;
normoxminHbO = normoxminHbO .* Mask;
normoxminHbR = normoxminHbR .* Mask;

subplot(1,2,1)
imagesc(mean(normoxminHbO,3),[-5 18])
colorbar
hold on
imagesc(zeros(192,192,3),'AlphaData', ~Mask);
axis image
axis off
title('HbO Normoxia')
subplot(1,2,2)
imagesc(mean(hypoxminHbO,3), [-5 18])
colorbar
hold on
imagesc(zeros(192,192,3),'AlphaData', ~Mask);
axis image
axis off
title('HbO Hypoxia')
saveas(gcf, './Figures/HbONormHypox.png');

subplot(1,2,1)
imagesc(mean(normoxminHbR,3),[-5 18])
colorbar
hold on
imagesc(zeros(192,192,3),'AlphaData', ~Mask);
axis image
axis off
title('HbR Normoxia')
subplot(1,2,2)
imagesc(mean(hypoxminHbR,3), [-5 18])
colorbar
hold on
imagesc(zeros(192,192,3),'AlphaData', ~Mask);
axis image
axis off
title('HbR Hypoxia')
saveas(gcf, './Figures/HbRNormHypox.png');

diffHbO = mean(hypoxminHbO,3) - mean(normoxminHbO,3);
diffHbR = mean(hypoxminHbR,3) - mean(normoxminHbR,3);

% % imshowpair(diffHbO, diffHbR, 'ColorChannels', [1 0 2])
% subplot(1,2,1)
% imagesc(diffHbO, [-50 50])
% colorbar
% hold on
% imagesc(zeros(192,192,3),'AlphaData', ~Mask); %for black background
% axis image
% axis off
% title('HbO difference')
% subplot(1,2,2)
% imagesc(diffHbR, [-50 50])
% colorbar
% hold on
% imagesc(zeros(192,192,3),'AlphaData', ~Mask);
% axis image
% axis off
% title('HbR difference')
% saveas(gcf, './Figures/HbOHbRdifferences.png');





%% GSR
dat = reshape(HbO,[], dims(3));
mS = mean(dat(Mask(:),:),1);

X = [ones(size(mS)); mS];
B = X'\dat';
A = (X'*B)';
dat = dat-A;
HbO = reshape(dat,dims);
clear h mS X B A;


dat = reshape(HbR,[], dims(3));
mS = mean(dat(Mask(:),:),1);

X = [ones(size(mS)); mS];
B = X'\dat';
A = (X'*B)';
dat = dat-A;
HbR = reshape(dat,dims);
clear h mS X B A;





%% Direct Computation:
load('SysSpect.mat');
[c_ext_hbo,c_ext_hbr] = ioi_get_extinctions(400, 700, 301);
c_pathlength = ioi_path_length_factor(400, 700, 301, 100*1000, 'Silico');

CHbO_n
CHbO_h
CHbR_n
CHbR_h
%for green LED:
-2.*c_pathlength.*c_ext_hbo.*Green*(CHbO_h-CHbO_n) - 2.*c_pathlength.*c_ext_hbr.*Green*(CHbR_h-CHbR_n);

A = [-2.*c_pathlength.*c_ext_hbo.*Green; -2.*c_pathlength.*c_ext_hbo.*Red;...
    -2.*c_pathlength.*c_ext_hbo.*Yellow; -c_pathlength.*c_ext_hbo.*Blue - c_pathlength.*c_ext_hbo.*GFP_em];
B = [-2.*c_pathlength.*c_ext_hbr.*Green; -2.*c_pathlength.*c_ext_hbr.*Red;...
    -2.*c_pathlength.*c_ext_hbr.*Yellow];


%%
figure;
for ind = 1:10:size(HbO,3)
    imagesc(squeeze(HbR(:,:,ind)),[-5e-5 5e-5]);
    title(int2str(ind));
    pause(0.005)
end
















%% old
%% Normalisation For HbO and HbR
%omdat namen veranderd zijn:

% Temporal filtering butterworth
Infos = matfile('fluo_475.mat');
f = fdesign.lowpass('N,F3dB', 4, 0.3, Infos.Freq); %Fluo lower Freq/
%f = fdesign.lowpass('N,F3dB', 4, 1/3, Infos.Freq); %Intrinsic Lower Freq  
lpass = design(f,'butter');
f = fdesign.lowpass('N,F3dB', 4, 3, Infos.Freq);   %Fluo Higher Freq
%f = fdesign.lowpass('N,F3dB', 4, 3, Infos.Freq);   %Intrinsic Higher Freq 
hpass = design(f,'butter');

dat = Hypoxia;

Hd = zeros(size(dat),'single');
for ind = 1:dims(1)
    disp(ind);
    Hd(ind,:,:) = reshape(single(filtfilt(hpass.sosMatrix, hpass.ScaleValues, double(squeeze(dat(ind,:,:))'))'),dims(2),[]);
    Hd(ind,:,:) = squeeze(Hd(ind,:,:))./ ...
        reshape(single(filtfilt(lpass.sosMatrix, lpass.ScaleValues, double(squeeze(dat(ind,:,:))'))'),dims(2),[]);        
end
Hypoxia = Hd;
clear Hd f lpass hpass ind;

videoname = strcat(videoname, '_NormButterworth')
%% 

Before = HbO(:,:,2000:12000);
Hypoxia = HbO(:,:,14000:24000);
After = HbO(:,:,38000:48000);

[CMatrixWholeAcq, ~, ~, ~, ~, AllRois] ...
    = CorrelationMatrix(Before, ROI_info, 'CMatrixWholeAcq');

%% stdev imagesc
TC = reshape([AllRois{:,2}], dims(3),[]);
imagesc(movstd(TC,20,0,1)')
yticks(1:size(AllRois,1));
yticklabels([AllRois(:,3)]);

TC_mstd = (movstd(TC,20,0,1)');
TC_mstd = TC_mstd - mean(TC_mstd(:,1:12000),2);
imagesc(TC_mstd)
yticks(1:size(AllRois,1));
yticklabels([AllRois(:,3)]);