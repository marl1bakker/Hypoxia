function IntraCoRegistration(folderpath)

fid = fopen([folderpath filesep 'green.dat']);
dat = fread(fid, inf, '*single');
dat = reshape(dat,192,192,[]);
dat = flipud(rot90(dat));

%% Preprocessing: Images preparation to optimize High spatial Frequencies

parfor ind = 1:size(dat,3)
    dat(:,:,ind) = dat(:,:,ind) - imbothat(dat(:,:,ind),fspecial('disk',2)>0)...
        + imtophat(dat(:,:,ind),fspecial('disk',2)>0);
end
dat(dat<0) = 0;
dat(dat>65535) = 65535; %limit in intensity, 2^16

parfor ind = 1:size(dat,3)
    dat(:,:,ind) = round(65535*adapthisteq(dat(:,:,ind)./65535)); 
end

dat = dat - imgaussfilt(dat,16);
%% Rigid transformation: Rot + Translation
[opt1, metric] = imregconfig('monomodal');
opt1.GradientMagnitudeTolerance = 1e-3;
opt1.MaximumIterations = 100;
opt1.MaximumStepLength = 1e-3;
opt1.MinimumStepLength = 1e-4;
opt1.RelaxationFactor = 5e-1;

% opt2 = opt1;
% opt2.GradientMagnitudeTolerance = 1e-3;
% opt2.MaximumIterations = 100;
% opt2.MaximumStepLength = 1e-3;
% opt2.MinimumStepLength = 1e-4;
% opt2.RelaxationFactor = 7.5e-1;
% 
% opt3 = opt1;
% opt3.GradientMagnitudeTolerance = 1e-3;
% opt3.MaximumIterations = 100;
% opt3.MaximumStepLength = 1e-3;
% opt3.MinimumStepLength = 1e-4;
% opt3.RelaxationFactor = 9e-1;

T = zeros(3,3,size(dat,3));
Demons = zeros(192,192,2,size(dat,3));
Fixed = dat(:, : ,1);

DQ = parallel.pool.DataQueue;
h = waitbar(0, 'Please wait...');
afterEach(DQ, @nUpdateWB);
p = 0; 
N = size(dat,3);

parfor(ind = 1:size(dat,3))
    Temp = imregtform(dat(:,:,ind),Fixed,'affine',opt1,metric,'DisplayOptimization', false);
%     Temp = imregtform(dat(:,:,ind),Fixed,'similarity',opt2,metric,...
%         'InitialTransformation', Temp, 'DisplayOptimization', false);
%     Temp = imregtform(dat(:,:,ind),Fixed,'affine',opt3,metric,...
%         'InitialTransformation', Temp, 'DisplayOptimization', false);
    dat(:,:,ind) = imwarp(dat(:,:,ind), Temp, 'OutputView', imref2d([192,192]));
    T(:,:,ind) = Temp.T;
    [D,~] = imregdemons(dat(:,:,ind),Fixed,[100 75 50],'PyramidLevels', 3,...
        'AccumulatedFieldSmoothing',3, 'DisplayWaitbar', false);
    Demons(:,:,:,ind) = D;
   send(DQ, ind);
end
T = single(T);
Demons = single(Demons);
close(h);
save([folderpath filesep 'IntraCoReg.mat'], 'T', 'Demons','-v7.3');

    function nUpdateWB(~)
        p = p + 1;
        if( mod(p, 100) == 0 )
            waitbar(p/N,h);
        end        
    end

end