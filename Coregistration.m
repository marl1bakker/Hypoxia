function datH12 = Coregistration(path_fixed, path_moving)

%% Step 1: Load data
cd(path_fixed);
fid = fopen('green.dat');
dat = fread(fid, inf, '*single');
dat = reshape(dat, 192,192,[]);
fclose(fid);
datg_n = dat;

cd(path_moving);
fid = fopen('green.dat');
dat = fread(fid, inf, '*single');
dat = reshape(dat, 192,192,[]);
fclose(fid);
datg_h = dat;
clear dat;

%% Step 2: Mask
cd(path_fixed);
MaskN = load('Mask.mat');
MaskN = imfill(MaskN.Mask, 'holes');

cd(path_moving);
MaskH12 = load('Mask.mat');
MaskH12 = imfill(MaskH12.Mask, 'holes');

% imagesc(datg_n);
% h = impoly;
% MaskN = h.createMask;
% imagesc(datg_h);
% h = impoly;
% MaskH12 = h.createMask;

%% Step 3: Prep
datg_n = datg_n(:,:,1);
datg_n = datg_n - imgaussfilt(datg_n,4);
P = prctile(datg_n(:), [2 98]);
datg_n = (datg_n - P(1))/(P(2) - P(1));
datg_n(datg_n < 0) = 0;
datg_n(datg_n > 1) = 1;
datg_n = adapthisteq(datg_n);
datg_n = datg_n';

datg_h = datg_h(:,:,1);
datg_h = datg_h - imgaussfilt(datg_h,4);
P = prctile(datg_h(:), [2 98]);
datg_h = (datg_h - P(1))/(P(2) - P(1));
datg_h(datg_h < 0) = 0;
datg_h(datg_h > 1) = 1;
datg_h = adapthisteq(datg_h);
datg_h = datg_h';

%% Step 4: CoReg
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 1e3;
optimizer.MinimumStepLength = 1e-6;
optimizer.MaximumStepLength = 1e-2;
optimizer.GradientMagnitudeTolerance = 1e-6;
tform = imregtform(datg_h.*MaskH12, datg_n.*MaskN, 'affine', optimizer, metric,...
    'DisplayOptimization', true, 'PyramidLevels', 3);

%% Step 5:Confirmation
datg_hCorr = imwarp(datg_h,tform,'OutputView',imref2d(size(datg_n)));
imshowpair(datg_n.*MaskN, datg_hCorr);

answer = questdlg('Does it make sense?', ...
	'Coregistration', ...
	'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        disp('≧◠‿●‿◠≦    ᕙ(^▿^-ᕙ)');
    case 'No'
        datH12 = 0;
        return
end
%% Step 5 B: Save/load
cd(path_moving);
save('tform.mat','tform');

load('tform.mat');

%% Step 6: Apply to all fluo images
% cd(path_hypox);
fid = fopen('fChanCor.dat');
dat = fread(fid, inf, '*single');
dat = reshape(dat, 192,192,[]);
fclose(fid);
datH12 = dat;
datH12 = flipud(rot90(datH12));

for ind = 1:size(datH12,3)
    datH12(:,:,ind) = imwarp(squeeze(datH12(:,:,ind)),tform,'OutputView',imref2d(size(datH12(:,:,1))),'interp','nearest');
end