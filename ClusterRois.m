% if there's weird values, check if the ROIs that you want to cluster don't
% overlap
% 21-3-2022

function ClusterRois(DataFolder, ManualInput)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

idx = strfind(DataFolder, filesep); %zoek alle plekken van fileseps in naam
pathFixed = [DataFolder(1:idx(end-1)) 'Normoxia_1']; %pak naam tot laatste filesep, plak normoxia 1 achter

if exist([pathFixed filesep 'BigROI.mat'], 'file') && ManualInput == 0
    return
end
    
load([pathFixed filesep 'ROI_149.mat']);
clear idx fid


%% Get data
% fid = fopen([DataFolder 'fChanCor.dat']);
% dat = fread(fid, inf, '*single');
% dat = reshape(dat, 192,192, []);
% 
% load([DataFolder 'MaskC.mat']);
% dat = dat.*Mask;
% dat(dat == 0) = NaN;

load('/media/mbakker/data1/Hypoxia/LargerAreaAtlas.mat');

%% get ROI


BigROI = struct;
BigROI.VisualROI_R = zeros(192);
BigROI.SensoryROI_R = zeros(192);
BigROI.AuditoryROI_R = zeros(192);
BigROI.MotorROI_R = zeros(192);
BigROI.UnknownROI_R = zeros(192);
BigROI.VisualROI_L = zeros(192);
BigROI.SensoryROI_L = zeros(192);
BigROI.AuditoryROI_L = zeros(192);
BigROI.MotorROI_L = zeros(192);
BigROI.UnknownROI_L = zeros(192);

for idx = 1:size(ROI_info,2)
    
    if contains(ROI_info(idx).Name, '_R') && ...
            sum( matches(AreasTag.Visual, ROI_info(idx).Name) ) > 0
        BigROI.VisualROI_R = BigROI.VisualROI_R + ROI_info(idx).Stats.ROI_binary_mask;
    elseif contains(ROI_info(idx).Name, '_L') && ...
            sum( matches(AreasTag.Visual, ROI_info(idx).Name) ) > 0
        BigROI.VisualROI_L = BigROI.VisualROI_L + ROI_info(idx).Stats.ROI_binary_mask;
        
    elseif contains(ROI_info(idx).Name, '_R') && ...
            sum( matches(AreasTag.Sensory, ROI_info(idx).Name) ) > 0
        BigROI.SensoryROI_R = BigROI.SensoryROI_R + ROI_info(idx).Stats.ROI_binary_mask;
    elseif contains(ROI_info(idx).Name, '_L') && ...
            sum( matches(AreasTag.Sensory, ROI_info(idx).Name) ) > 0
        BigROI.SensoryROI_L = BigROI.SensoryROI_L + ROI_info(idx).Stats.ROI_binary_mask;
        
    elseif contains(ROI_info(idx).Name, '_R') && ...
            sum( matches(AreasTag.Auditory, ROI_info(idx).Name) ) > 0
        BigROI.AuditoryROI_R = BigROI.AuditoryROI_R + ROI_info(idx).Stats.ROI_binary_mask;
    elseif contains(ROI_info(idx).Name, '_L') && ...
            sum( matches(AreasTag.Auditory, ROI_info(idx).Name) ) > 0
        BigROI.AuditoryROI_L = BigROI.AuditoryROI_L + ROI_info(idx).Stats.ROI_binary_mask;
        
    elseif contains(ROI_info(idx).Name, '_R') && ...
            sum( matches(AreasTag.Motor, ROI_info(idx).Name) ) > 0
        BigROI.MotorROI_R = BigROI.MotorROI_R + ROI_info(idx).Stats.ROI_binary_mask;
    elseif contains(ROI_info(idx).Name, '_L') && ...
            sum( matches(AreasTag.Motor, ROI_info(idx).Name) ) > 0
        BigROI.MotorROI_L = BigROI.MotorROI_L + ROI_info(idx).Stats.ROI_binary_mask;
        
    elseif contains(ROI_info(idx).Name, '_R') && ...
            sum( matches(AreasTag.Unknown, ROI_info(idx).Name) ) > 0
        BigROI.UnknownROI_R = BigROI.UnknownROI_R + ROI_info(idx).Stats.ROI_binary_mask;
    elseif contains(ROI_info(idx).Name, '_L') && ...
            sum( matches(AreasTag.Unknown, ROI_info(idx).Name) ) > 0
        BigROI.UnknownROI_L = BigROI.UnknownROI_L + ROI_info(idx).Stats.ROI_binary_mask;
    end
    
end



%%
% disp('bla')
save([pathFixed filesep 'BigROI.mat'], 'BigROI');

end