function CombinedMask(ManualInput,Mice)
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/TheGirl/Tom/Mask.mat', 'file') )
    disp('Combined Masks already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/TheGirl/Tom/Mask.mat', 'file') )
    disp('Combined Masks already done, OVERWRITING FILES')
end

if ~exist('Mice', 'var')
    Mice = {'TheBoys/087', 'TheBoys/227', 'TheBoys/552', 'TheBoys/Chiploos',...
        'TheGirls/Jane', 'TheGirls/Katy','TheGirls/Nick','TheGirls/Tom'};
end


for ind = 1:size(Mice,2)
    mousepath = ['/media/mbakker/data1/Hypoxia' filesep Mice{ind}];
    cd(mousepath);
    
    %% load green images
    load('./Hypox_8_1/AnaMap.mat');
    AM8_1 = AnaMap./mean(AnaMap(:));
    load('./Hypox_8_2/AnaMap.mat');
    AM8_2 = AnaMap./mean(AnaMap(:));
    load('./Hypox_10/AnaMap.mat');
    AM10 = AnaMap./mean(AnaMap(:));
    load('./Hypox_12/AnaMap.mat');
    AM12 =  AnaMap./mean(AnaMap(:));
    fid = fopen('./Normoxia_1/green.dat');
    AMN_1 = reshape(fread(fid,192*192,'*single'),192,192);
    AMN_1 = AMN_1./mean(AMN_1(:));
    load('./Normoxia_2/AnaMap.mat');
    AMN_2 =  AnaMap./mean(AnaMap(:));
    load('./Normoxia_3/AnaMap.mat');
    AMN_3 =  AnaMap./mean(AnaMap(:));
    load('./Normoxia_4/AnaMap.mat');
    AMN_4 = AnaMap./mean(AnaMap(:));
    
    %% to check if it's normal
    % figure()
    % subplot(2,4,1)
    % imagesc(AMN_1)
    % subplot(2,4,2)
    % imagesc(AMN_2 - AMN_1, [-1 1]);
    % subplot(2,4,3)
    % imagesc(AMN_3 - AMN_1, [-1 1]);
    % subplot(2,4,4)
    % imagesc(AMN_4 - AMN_1, [-1 1]);
    % subplot(2,4,5)
    % imagesc(AM10 - AMN_1, [-1 1]);
    % subplot(2,4,6)
    % imagesc(AM12 - AMN_1, [-1 1]);
    % subplot(2,4,7)
    % imagesc(AM8_1 - AMN_1, [-1 1]);
    % subplot(2,4,8)
    % imagesc(AM8_2 - AMN_1, [-1 1]);
    
    % load('./Hypox_8_1/MaskC.mat');
    % Mask8_1 = Mask;
    % load('./Hypox_8_2/MaskC.mat');
    % Mask8_2 = Mask;
    % load('./Hypox_10/MaskC.mat');
    % Mask10 = Mask;
    % load('./Hypox_12/MaskC.mat');
    % Mask12 = Mask;
    % load('./Normoxia_1/MaskC.mat');
    % MaskN1 = Mask;
    % load('./Normoxia_2/MaskC.mat');
    % MaskN2 = Mask;
    % load('./Normoxia_3/MaskC.mat');
    % MaskN3 = Mask;
    % load('./Normoxia_4/MaskC.mat');
    % MaskN4 = Mask;
    
    % maskor = (Mask8_1 | Mask8_2 | Mask10 | Mask12 | MaskN1 | MaskN2 | MaskN3 | MaskN4);
    %
    % % figure()
    % maskand = (Mask8_1 & Mask8_2 & Mask10 & Mask12 & MaskN1 & MaskN2 & MaskN3 & MaskN4);
    % maskand = imfill(maskand, 'holes');
    %
    % figure()
    % imagesc(maskor+maskand)
    
    %% Make mask
    AnaMap = AMN_1 + AMN_2 +AMN_3 +AMN_4 + AM8_2 + AM8_1 + AM10 + AM12;
    imagesc(AnaMap);
    h= impoly; %dont close, draw mask
    Mask = h.createMask;
    % Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
    % Im = Im./max(Im(:));
    % Mask = bwmorph(Mask&(Im<=0.25),'close',inf);
    close all
    obj = imagesc(Mask);
    save([pwd filesep 'Mask.mat'], 'Mask');
    % close all
    waitfor(obj)
    
end