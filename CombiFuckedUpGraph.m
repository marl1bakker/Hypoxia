function CombiFuckedUpGraph(HypoxiaLevels, Glist, TitleList, ManualInput)

%% YES I KNOW IT'S A GIANT MESS
%% I AM TRYING OKAY

OldMousePath = [];
%% Correlation matrix
load('/media/mbakker/data1/Hypoxia/LargerAreaAtlas.mat');
for ind = 1:size(Glist,2) %per acquisition
    
    %% Get ROI and group into clusters
    %Current mouse:
    idx = strfind(Glist(ind).name, filesep);
    MousePath = Glist(ind).name(1:idx(end));
    if( ~strcmp(MousePath, OldMousePath))
        NormFolder = [Glist(ind).name(1:idx(end)) 'Normoxia_1' filesep];
        load([NormFolder 'ROI_149.mat']);
        
        %per region of interest in the brain
        %combine smaller ROI into bigger chunks
        MaskMotorR = zeros(192, 192);
        MaskVisualR = zeros(192, 192);
        MaskAuditoryR = zeros(192, 192);
        MaskSensoryR = zeros(192, 192);
        MaskUnknownR = zeros(192, 192);
        
        MaskMotorL = zeros(192, 192);
        MaskVisualL = zeros(192, 192);
        MaskAuditoryL = zeros(192, 192);
        MaskSensoryL = zeros(192, 192);
        MaskUnknownL = zeros(192, 192);
        
        for index = 1:size(ROI_info,2)
            
            % check if in Motor, if yes, combine masks
            if sum(matches(AreasTag.Motor, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_R') %if any of the logical comparisons are 1, go in
                MaskMotorR = ROI_info(index).Stats.ROI_binary_mask + MaskMotorR;
            elseif   sum(matches(AreasTag.Motor, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_L')
                MaskMotorL = ROI_info(index).Stats.ROI_binary_mask + MaskMotorL;
                
            elseif sum(matches(AreasTag.Visual, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_R')
                MaskVisualR = ROI_info(index).Stats.ROI_binary_mask + MaskVisualR;
            elseif sum(matches(AreasTag.Visual, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_L')
                MaskVisualL = ROI_info(index).Stats.ROI_binary_mask + MaskVisualL;
                
            elseif sum(matches(AreasTag.Auditory, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_R')
                MaskAuditoryR = ROI_info(index).Stats.ROI_binary_mask + MaskAuditoryR;
            elseif sum(matches(AreasTag.Auditory, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_L')
                MaskAuditoryL = ROI_info(index).Stats.ROI_binary_mask + MaskAuditoryL;
                
            elseif sum(matches(AreasTag.Sensory, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_R')
                MaskSensoryR = ROI_info(index).Stats.ROI_binary_mask + MaskSensoryR;
            elseif sum(matches(AreasTag.Sensory, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_L')
                MaskSensoryL = ROI_info(index).Stats.ROI_binary_mask + MaskSensoryL;
                
            elseif sum(matches(AreasTag.Unknown, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_R')
                MaskUnknownR = ROI_info(index).Stats.ROI_binary_mask + MaskUnknownR;
            elseif sum(matches(AreasTag.Unknown, ROI_info(index).Name)) && contains(ROI_info(index).Name, '_L')
                MaskUnknownL = ROI_info(index).Stats.ROI_binary_mask + MaskUnknownL;
                
            end
        end
    end
    OldMousePath = MousePath; %so you dont have to do this again for the next acquisition of the same mosue
    
    %% Hemodynamics
    load([Glist(ind).name, filesep, 'MaskC.mat']);
    
    hemos = {'HbO', 'HbR', 'HbT'};
    
    for indeks = 1:size(hemos,2)
        
        HbO = load([Glist(ind).name, filesep, hemos{indeks}, '.mat']);
        HbO = HbO.hemos{indeks};
        HbO = reshape(HbO,[],size(HbO,3));  %HbO is not always HbO but can be HbT or HbR depending on the cycle
        % GSR
        %     Sig = mean(HbO(Mask(:),:),1);
        %     X = [ones(size(Sig)); Sig./mean(Sig)];
        %     B = X'\HbO';
        %     A = (X'*B)';
        %     HbO = (HbO - A);
        
        
        %take the hemodynamics only from the area of the mask
        MaskAuditoryL = imerode(imdilate(MaskAuditoryL,strel('diamond',3)),strel('diamond',3));
        AuditLSigBefore = mean(HbO(MaskAuditoryL(:)==1,3000:9000),1);
        AuditLSigDuring = mean(HbO(MaskAuditoryL(:)==1,15000:21000),1);
        AuditLSigAfter = mean(HbO(MaskAuditoryL(:)==1,27000:33000),1);
        
        MaskAuditoryR = imerode(imdilate(MaskAuditoryR,strel('diamond',3)),strel('diamond',3));
        AuditRSigBefore = mean(HbO(MaskAuditoryR(:)==1,3000:9000),1);
        AuditRSigDuring = mean(HbO(MaskAuditoryR(:)==1,15000:21000),1);
        AuditRSigAfter = mean(HbO(MaskAuditoryR(:)==1,27000:33000),1);
        
        MaskMotorL = imerode(imdilate(MaskMotorL,strel('diamond',3)),strel('diamond',3));
        MotorLSigBefore = mean(HbO(MaskMotorL(:)==1,3000:9000),1);
        MotorLSigDuring = mean(HbO(MaskMotorL(:)==1,15000:21000),1);
        MotorLSigAfter = mean(HbO(MaskMotorL(:)==1,27000:33000),1);
        
        MaskMotorR = imerode(imdilate(MaskMotorR,strel('diamond',3)),strel('diamond',3));
        MotorRSigBefore = mean(HbO(MaskMotorR(:)==1,3000:9000),1);
        MotorRSigDuring = mean(HbO(MaskMotorR(:)==1,15000:21000),1);
        MotorRSigAfter = mean(HbO(MaskMotorR(:)==1,27000:33000),1);
        
        MaskSensoryL = imerode(imdilate(MaskSensoryL,strel('diamond',3)),strel('diamond',3));
        SensoryLSigBefore = mean(HbO(MaskSensoryL(:)==1,3000:9000),1);
        SensoryLSigDuring = mean(HbO(MaskSensoryL(:)==1,15000:21000),1);
        SensoryLSigAfter = mean(HbO(MaskSensoryL(:)==1,27000:33000),1);
        
        MaskSensoryR = imerode(imdilate(MaskSensoryR,strel('diamond',3)),strel('diamond',3));
        SensoryRSigBefore = mean(HbO(MaskSensoryR(:)==1,3000:9000),1);
        SensoryRSigDuring = mean(HbO(MaskSensoryR(:)==1,15000:21000),1);
        SensoryRSigAfter = mean(HbO(MaskSensoryR(:)==1,27000:33000),1);
        
        MaskUnknownL = imerode(imdilate(MaskUnknownL,strel('diamond',3)),strel('diamond',3));
        UnknownLSigBefore = mean(HbO(MaskUnknownL(:)==1,3000:9000),1);
        UnknownLSigDuring = mean(HbO(MaskUnknownL(:)==1,15000:21000),1);
        UnknownLSigAfter = mean(HbO(MaskUnknownL(:)==1,27000:33000),1);
        
        MaskUnknownR = imerode(imdilate(MaskUnknownR,strel('diamond',3)),strel('diamond',3));
        UnknownRSigBefore = mean(HbO(MaskUnknownR(:)==1,3000:9000),1);
        UnknownRSigDuring = mean(HbO(MaskUnknownR(:)==1,15000:21000),1);
        UnknownRSigAfter = mean(HbO(MaskUnknownR(:)==1,27000:33000),1);
        
        MaskVisualL = imerode(imdilate(MaskVisualL,strel('diamond',3)),strel('diamond',3));
        VisualLSigBefore = mean(HbO(MaskVisualL(:)==1,3000:9000),1);
        VisualLSigDuring = mean(HbO(MaskVisualL(:)==1,15000:21000),1);
        VisualLSigAfter = mean(HbO(MaskVisualL(:)==1,27000:33000),1);
        
        MaskVisualR  = imerode(imdilate(MaskVisualR,strel('diamond',3)),strel('diamond',3));
        VisualRSigBefore = mean(HbO(MaskVisualR(:)==1,3000:9000),1);
        VisualRSigDuring = mean(HbO(MaskVisualR(:)==1,15000:21000),1);
        VisualRSigAfter = mean(HbO(MaskVisualR(:)==1,27000:33000),1);
        
        %% Correlation Matrix
        % Before hypoxia
        
        CorrBefore = corr([MotorLSigBefore;  SensoryLSigBefore; VisualLSigBefore;  AuditLSigBefore;  ...
            UnknownLSigBefore;  MotorRSigBefore; SensoryRSigBefore; VisualRSigBefore;...
            AuditRSigBefore; UnknownRSigBefore;]');
        save([Glist(ind).name, filesep, hemos{indeks}, 'CorrBefore.mat'], 'CorrBefore');
        
        CorrDuring = corr([MotorLSigDuring;  SensoryLSigDuring; VisualLSigDuring;  AuditLSigDuring;  ...
            UnknownLSigDuring;  MotorRSigDuring; SensoryRSigDuring; VisualRSigDuring;...
            AuditRSigDuring; UnknownRSigDuring;]');
        save([Glist(ind).name, filesep, hemos{indeks}, 'CorrDuring.mat'], 'CorrDuring');
        
        CorrAfter = corr([MotorLSigAfter;  SensoryLSigAfter; VisualLSigAfter;  AuditLSigAfter;  ...
            UnknownLSigAfter;  MotorRSigAfter; SensoryRSigAfter; VisualRSigAfter;...
            AuditRSigAfter; UnknownRSigAfter;]');
        save([Glist(ind).name, filesep, hemos{indeks}, 'CorrAfter.mat'], 'CorrAfter');
        
        %% Fucked up graph...
        
        
    end
end


end