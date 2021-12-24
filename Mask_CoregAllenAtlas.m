%% alignment allen atlas
function Mask_CoregAllenAtlas(NormFolder)

if( ~strcmp(NormFolder(end), filesep) )
    NormFolder = [NormFolder filesep];
end

dd = load('mouse_ctx_borders.mat','atlas');
roi.tags = dd.atlas.areatag;

load([NormFolder 'ROI_149.mat'])
Atlas = zeros(192);
for indA = 1:size(ROI_info,2)
    idx = find(strcmp(ROI_info(indA).Name,roi(:).tags));
    Atlas(ROI_info(indA).Stats.ROI_binary_mask) = idx;
end

% idx = arrayfun(@(x) endsWith(ROI_info(x).Name, '_L'), 1:size(ROI_info,2));
% RH_Mask = imfill(bwmorph(ismember(Atlas,find(~idx)) ,'close',inf),'holes');
% LH_Mask = imfill(bwmorph(ismember(Atlas,find(idx)),'close',inf),'holes');

CoregMask = Atlas;
save([NormFolder 'CoregMask.mat'], 'CoregMask')

end