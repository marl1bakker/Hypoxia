function datH12 = Coregistration(path_fixed, path_moving, bApply)

if( ~strcmp(path_moving(end), filesep) )
    path_moving = [path_moving filesep];
end
if( ~strcmp(path_fixed(end), filesep) )
    path_fixed = [path_fixed filesep];
end

%% Step 1: Load data
%check if both acquisitions have done coregistration within, otherwise the
%orientation is gonna be different
if( exist([path_fixed 'IntraCoReg.mat'], 'file') ) && ( exist([path_moving 'IntraCoReg.mat'], 'file') )
    disp('both paths have been coregistered within their own acquisition')
else
    disp('one of the acquisitions have not been coregistered within the acquisition')
    datH12 = 0;
    return 
end

fid = fopen([path_fixed 'green.dat']);
dat = fread(fid, 192*192, '*single');
dat = reshape(dat, 192,192,[]);
fclose(fid);
datg_n = dat;
MaskN = load([path_fixed 'Mask.mat']);
MaskN = imfill(MaskN.Mask, 'holes');

fid = fopen([path_moving 'green.dat']);
dat = fread(fid, 192*192, '*single');
dat = reshape(dat, 192,192,[]);
fclose(fid);
datg_h = dat;
MaskH12 = load([path_moving 'Mask.mat']);
MaskH12 = imfill(MaskH12.Mask, 'holes');
clear dat;

%% Step 3: Prep
datg_n = datg_n(:,:,1);
datg_n = datg_n - imgaussfilt(datg_n,4);
P = prctile(datg_n(:), [2 98]);
datg_n = (datg_n - P(1))/(P(2) - P(1));
datg_n(datg_n < 0) = 0;
datg_n(datg_n > 1) = 1;
datg_n = adapthisteq(datg_n);
% datg_n = datg_n';

datg_h = datg_h(:,:,1);
datg_h = datg_h - imgaussfilt(datg_h,4);
P = prctile(datg_h(:), [2 98]);
datg_h = (datg_h - P(1))/(P(2) - P(1));
datg_h(datg_h < 0) = 0;
datg_h(datg_h > 1) = 1;
datg_h = adapthisteq(datg_h);
% datg_h = datg_h';

%% Step 4: CoReg
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 1e3;
optimizer.MinimumStepLength = 1e-6;
optimizer.MaximumStepLength = 1e-2;
optimizer.GradientMagnitudeTolerance = 1e-6;
tform = imregtform(datg_h.*MaskH12, datg_n.*MaskN, 'affine', optimizer, metric,...
    'DisplayOptimization', false, 'PyramidLevels', 3);

%% Step 5:Confirmation
datg_hCorr = imwarp(datg_h,tform,'OutputView',imref2d(size(datg_n)));
figure;
imshowpair(datg_n.*MaskN, datg_hCorr);
saveas(gcf,[path_moving 'CoregistrationComp.png']);
% 
% answer = questdlg('Does it make sense?', ...
% 	'Coregistration', ...
% 	'Yes','No','Yes');
% % Handle response
% switch answer
%     case 'Yes'
%         disp('≧◠‿●‿◠≦    ᕙ(^▿^-ᕙ)');
%     case 'No'
%         datH12 = 0;
%         return
% end
%% Step 5 B: Save/load
save([path_moving 'tform.mat'],'tform');

%% Step 6: Apply to all fluo images
if( bApply )
    fid = fopen([path_moving 'fChanCor.dat']);
    dat = fread(fid, inf, '*single');
    dat = reshape(dat, 192,192,[]);
    fclose(fid);
    datH12 = dat;
    datH12 = flipud(rot90(datH12));
    
    for ind = 1:size(datH12,3)
        datH12(:,:,ind) = imwarp(squeeze(datH12(:,:,ind)),tform,'OutputView',imref2d(size(datH12(:,:,1))),'interp','nearest');
    end
else
    datH12 = 1;
end