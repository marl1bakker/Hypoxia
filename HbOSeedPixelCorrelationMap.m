% choose one pixel in the brain, and make a correlationmap of that. 
% ManualInput 0 - dont ignore existing files
% ManualInput 1 - overwrite existing files
% Input Seedname can be several, give like {'seed1', 'seed2'} etc.
%{'VisualROI_R'} SensoryROI_R AuditoryROI_R UnknownROI_R MotorROI_R

function HemoSeedPixelCorrelationMap(DataType,DataFolder, Seedname, ManualInput, StartFrame, EndFrame)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

% if it already exists, dont do it
if( exist('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/HbO_227_Hypox_8_2_Frames_15000_to_21000SensoryROI_L.tiff', 'file') && ManualInput == 0 )
    disp('Seed pixel correlation map already done, function exited')
    return
elseif( exist('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/HbO_227_Hypox_8_2_Frames_15000_to_21000SensoryROI_L.tiff', 'file') && ManualInput == 1 )
    disp('Seed pixel correlation map already done, OVERWRITING FILES')
end 

% find normoxia 1 folder, check if you have the clustered ROI
idx = strfind(DataFolder, filesep); 
pathFixed = [DataFolder(1:idx(end-1)) 'Normoxia_1']; 
if exist([pathFixed filesep 'BigROI.mat'], 'file')
    load([pathFixed filesep 'BigROI.mat']);
else
    disp('No BigROI.mat in Normoxia_1 folder, run ClusterRois first')
    return
end
clear idx

%% Get data
fid = fopen([DataFolder 'HbO.dat']);
dat = fread(fid, inf, '*single');
dat = reshape(dat, 192,192, []);

% load([DataFolder 'MaskC.mat']); 
idx = strfind(DataFolder, filesep); %zoek alle plekken van fileseps in naam
Mask = load([DataFolder(1:idx(end-1)) 'Mask.mat']); %get general mask of mouse
Mask = Mask.Mask;

dat = dat.*Mask;
dat(dat == 0) = NaN;

%% GSR
dims = size(dat);
dat = reshape(dat,[], dims(3));
mS = mean(dat,1, 'omitnan');

X = [ones(size(mS)); mS];
B = X'\dat';
A = (X'*B)';
dat = dat - A; % - because its hbo hbr, 
dat = reshape(dat,dims);
clear h Mask mS X B A;

%% Do everything per seedname you gave in
for ind = 1:size(Seedname, 2) 
    disp(Seedname{ind})
    
    %% Get middle of ROIs
% Get centroid of ROI based on weight
    [X, Y] = meshgrid(1:192, 1:192);
    iX = sum(reshape(X.*BigROI.(Seedname{ind}), [], 1))/sum(BigROI.(Seedname{ind})(:));
    iY = sum(reshape(Y.*BigROI.(Seedname{ind}), [], 1))/sum(BigROI.(Seedname{ind})(:));
    iX = round(iX);
    iY = round(iY);
    
    
    %% Calculate the seed pixel correlation map
    dat = reshape(dat,dims);
    Seeddat = dat(iY, iX, StartFrame:EndFrame);
    Seeddat = reshape(Seeddat, 1, []);
    dat = reshape(dat, 36864, []);
    [rho, pval] = corr(Seeddat', dat(:,StartFrame:EndFrame)');
    rho = reshape(rho, 192, 192);
    
    figure()
    imagesc(rho, [-0.5 0.5])
%     colormap jet
    load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
    colormap(NL)
    colorbar
    
    axis image
    hold on
    line([5 20.7], [5 5]);
    line([5 5], [5 20.7]); %for scale, it's 157 pix for 10 mm
    
    idx = strfind(DataFolder, filesep); 
    MouseAcq = [DataFolder(idx(end-2):end) 'Frames_' num2str(StartFrame) '_to_' num2str(EndFrame) Seedname{ind}]; 
    MouseAcq = replace(MouseAcq, filesep, '_');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/HbO' MouseAcq '.tiff']);    
    close gcf
    
end



end