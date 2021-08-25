fid = fopen('green.dat');
dat = fread(fid, inf, '*single');
dat = reshape(dat,192,192,[]);
dat = flipud(rot90(dat));
%%
% D = abs(dat - dat(:,:,1));


%%
dat = dat - imgaussfilt(dat,2);

dat = (dat - min(min(dat,[],1),[],2))./(max(max(dat,[],1),[],2)-min(min(dat,[],1),[],2));

parfor(ind = 1:48060, 23)
    dat(:,:,ind) = adapthisteq(dat(:,:,ind)); 
end
%%
Z1 = dat(50:90, 50:90, :);


dftregistration(fft(Z1(:,:,2000)), fft(Z1(:,:,1)), 10); 

%% Visu

figure;
for ind = 1600:1:2200
    imagesc(squeeze(dat(:,:,ind)));
    title(int2str(ind))
    pause(0.05)
end

%%
[optimizer, metric] = imregconfig('monomodal');
optimizer.GradientMagnitudeTolerance = 1e-6;
optimizer.MaximumIterations = 1e3;
optimizer.MaximumStepLength = 1e-2;
optimizer.MinimumStepLength = 1e-6;
optimizer.RelaxationFactor = 1e-1;

T = zeros(3,3,48060);
Fixed = dat(:,:,1);

parfor( ind = 1800:2200,12)
    %disp(ind)
    Temp = imregtform(dat(:,:,ind),Fixed,'affine',optimizer,metric);
    T(:,:,ind) = Temp.T;
    %plot(squeeze(T(3,1,:)));
%     plot(squeeze(sqrt(T(3,1,:).^2 + T(3,2,:).^2)),'.');
%     pause(0.01);
end
%%
V = (squeeze(sqrt(T(3,1,1:250:48060).^2 + T(3,2,1:250:48060).^2)));

idx = find(ischange(V,'linear','Threshold', 0.005));
% 
% for indX = 1:size(idx,1)
%     fStart = 250*(idx(indX)-2) + 1;
%     fEnd = fStart + 250;
%     for indF = fStart:10:fEnd
%         disp(indF)
%         Temp = imregtform(dat(:,:,indF),dat(:,:,1),'rigid',optimizer,metric);
%         T(:,:,indF) = Temp.T;
%         %plot(squeeze(T(3,1,:)));
%         plot(squeeze(sqrt(T(3,1,:).^2 + T(3,2,:).^2)));
%         pause(0.01);
%     end
% end



for ind = 1800:2200
    tform = affine2d;
    tform.T = squeeze(T(:,:,ind));
    dat(:,:,ind) = imwarp(squeeze(dat(:,:,ind)), tform, 'OutputView', imref2d([192,192]));
end