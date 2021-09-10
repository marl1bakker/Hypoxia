function SamCoreg()

fid = fopen('green.dat');
dat = fread(fid, inf, '*single');
dat = reshape(dat,192,192,[]);
dat = flipud(rot90(dat));

%% Preprocessing: Images preparation to optimize High spatial Frequencies
DQ = parallel.pool.DataQueue;
afterEach(DQ, @UpdateWB);
p = 0;
N = size(dat,3);
h = waitbar(0);

parfor ind = 1:size(dat,3)
   
    Im = dat(:,:,ind) - imbothat(dat(:,:,ind),fspecial('disk',2)>0)...
        + imtophat(dat(:,:,ind),fspecial('disk',2)>0);
    Im(Im<0) = 0;
    Im(Im>65535) = 65535; 
    Im = round(65535*adapthisteq(Im./65535)); 
    Im = Im - imgaussfilt(Im,16);
    dat(:,:,ind) = (Im - min(Im(:)))./(max(Im(:)) - min(Im(:)));

    send(DQ,ind);
end
close(h)
%% Rigid transformation: Rot + Translation
[opt1, metric] = imregconfig('monomodal');
opt1.GradientMagnitudeTolerance = 1e-3;
opt1.MaximumIterations = 100;
opt1.MaximumStepLength = 1e-3;
opt1.MinimumStepLength = 1e-4;
opt1.RelaxationFactor = 5e-1;

T = zeros(3,3,size(dat,3));
Demons = zeros(192,192,2,size(dat,3));
Fixed = dat(:, : ,1);
p = 0;
N = size(dat,3);
h = waitbar(0);

parfor ind = 1:size(dat,3)
    Temp = imregtform(dat(:,:,ind),Fixed,'affine',opt1,metric,'DisplayOptimization', false);
    dat(:,:,ind) = imwarp(dat(:,:,ind), Temp, 'cubic',...
        'OutputView', imref2d([192,192]));
    T(:,:,ind) = Temp.T;
   [D,movingReg] = imregdemons(dat(:,:,ind),Fixed,[200 150 100], ...
       'PyramidLevels', 3, 'AccumulatedFieldSmoothing', 1.5,...
       'DisplayWaitbar', false);
   Demons(:,:,:,ind) = D;
   dat(:,:,ind) = movingReg;
   send(DQ,ind);
end

    function UpdateWB(~)
        p = p + 1;
        waitbar(p/N,h);
    end

end