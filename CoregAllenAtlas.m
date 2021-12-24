function CoregAllenAtlas(NormFolder1, NormFolder2)

if( ~strcmp(NormFolder1(end), filesep) )
    NormFolder1 = [NormFolder1 filesep];
end
if( ~strcmp(NormFolder2(end), filesep) )
    NormFolder2 = [NormFolder2 filesep];
end

%% Step 1: Load data
if ~exist([NormFolder1 'CoregMask.mat'])
    Mask_CoregAllenAtlas(NormFolder1)
end
load([NormFolder1 'CoregMask.mat'])
Mask1 = CoregMask;

if ~exist([NormFolder2 'CoregMask.mat'])
    Mask_CoregAllenAtlas(NormFolder2)
end
load([NormFolder2 'CoregMask.mat'])
Mask2 = CoregMask;

%% Step 4: CoReg
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 1e3;
optimizer.MinimumStepLength = 1e-6;
optimizer.MaximumStepLength = 5e-3;
optimizer.GradientMagnitudeTolerance = 1e-6;
optimizer.RelaxationFactor = 5e-1;
tformMask = affine2d();
[iX, iY] = meshgrid(1:192, 1:192);

Tx = mean(iX(Mask2(:)==1)) - mean(iX(Mask1(:)==1));
Ty = mean(iY(Mask2(:)==1)) - mean(iY(Mask1(:)==1));
initTform = affine2d();
initTform.T(3,1) = -Tx;
initTform.T(3,2) = -Ty;

init = imregcorr(Mask2, Mask1);
tformMask = imregtform(Mask2, Mask1, 'rigid', optimizer, metric,...
    'DisplayOptimization', false, 'PyramidLevels', 3, ...
    'InitialTransformation', initTform);
Mask2_cor = imwarp(Mask2, tformMask, 'OutputView',imref2d(size(Mask1)));

%% Step 5:Confirmation
Mask2_cor = imwarp(Mask2, tformMask, 'OutputView',imref2d(size(Mask1)));
f = figure;
imshowpair(Mask1, Mask2_cor);
% saveas(gcf,[path_moving 'CoregMask.png']);
% 
answer = questdlg('Does it make sense?', ...
	'Coregistration', ...
	'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        disp('≧◠‿●‿◠≦    ᕙ(^▿^-ᕙ)');
       
    case 'No'
        close(f);
        return
end
close(f);
%% Step 5 B: Save/load
save([NormFolder2 'tformMask.mat'],'tformMask');
end