function Output = GetSeedPairs(Threshold, GSR, CorrMatrix)

if ~exist('GSR', 'var')
    GSR = 1;
end

if ~exist('CorrMatrix', 'var')
    if GSR == 1
        load('/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/Hypox_8_2_qvaluesDiff.mat');
    else
        load('/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/Hypox_8_2_qvaluesDiff_NoGSR.mat');
    end
    CorrMatrix = q;
    clear q
end

ROIlist = {};

CorrMatrix = tril(CorrMatrix);
CorrMatrix(CorrMatrix==0) = NaN;

% [index1, index2] = find(CorrMatrix < -Threshold | CorrMatrix > Threshold); %old, no FDR
[index1, index2] = find(CorrMatrix < Threshold);
ROIlabels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};

for ind = 1:size(index1,1)
    ROI1 = ROIlabels{index1(ind)};
    ROI2 = ROIlabels{index2(ind)};
    ROIlist{ind} = {ROI1, ROI2};
end

Output = ROIlist;

end




% function Output = GetSeedPairs(Threshold, CorrMatrix)
% 
% if ~exist('CorrMatrix', 'var')
%     load('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Diff.mat');
%     CorrMatrix = CorrDiff;
%     clear CorrDiff
% end
% 
% ROIlist = {};
% 
% CorrMatrix = tril(CorrMatrix);
% [index1, index2] = find(CorrMatrix < -Threshold | CorrMatrix > Threshold);
% ROIlabels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
% 
% for ind = 1:size(index1,1)
%     ROI1 = ROIlabels{index1(ind)};
%     ROI2 = ROIlabels{index2(ind)};
%     ROIlist{ind} = {ROI1, ROI2};
% end
% 
% Output = ROIlist;
% 
% end
