% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Normoxia_2', 'Hypox_10', 'Normoxia_3',...
%     'Hypox_8_1', 'Normoxia_4', 'Hypox_8_2'};

function RealTimeSeedsCorrelation(GlistGCaMP, HypoxiaLevels, ManualInput, GSR)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if ~exist('GSR', 'var')
    GSR = 1;
end

%make if exist thing
if( ManualInput == 0 ) && GSR == 1 &&( exist('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix.mat', 'file') )
    disp('Real time seeds correlation cmatrix already made, exited function')
    return;
elseif ( ManualInput == 0 ) && GSR == 0 &&( exist('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix_NoGSR.mat', 'file') )
    disp('Real time seeds correlation cmatrix (no GSR) already made, exited function')
    return;
end
if( ManualInput == 1 ) && GSR == 1 && ( exist('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix.mat', 'file') )
    disp('Real time seeds correlation cmatrix already made, OVERWRITING FILES')
elseif( ManualInput == 1 ) && GSR == 0 && ( exist('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix_NoGSR.mat', 'file') )
    disp('Real time seeds correlation cmatrix (no GSR) already made, OVERWRITING FILES')
end

cmatrix = zeros(size(HypoxiaLevels,2), 7, 28, 48000 - 1200, 'single'); %size of hypoxia levels, mice, seedpairs. 48000-12000 because of average over min

for indH = 1:size(HypoxiaLevels,2)
    HypoxiaLevel = HypoxiaLevels{indH};
    
    idx = arrayfun(@(x) contains(GlistGCaMP(x).name, HypoxiaLevel), 1:size(GlistGCaMP,2));
    
    index = find(idx);
    
    for indM = 1:size(index,2)
        if GSR == 1
            load([GlistGCaMP(index(indM)).name filesep 'Timecourses.mat']);
        else
            load([GlistGCaMP(index(indM)).name filesep 'Timecourses_NoGSR.mat']);
        end
        
        if size(Timecourses, 2) < 48000
            Temp = NaN(8, 48000);
            Temp(:,1:size(Timecourses, 2)) = Timecourses;
            Timecourses = Temp;
        end
        
        for indf = 1:size(cmatrix,4)
            Tmp = corr(Timecourses(:,indf + (1:1200))');
            Tmp = Tmp(tril(ones(8))&~eye(8));
            cmatrix(indH, indM, :, indf) = Tmp;
        end
        
    end
    
end

if GSR == 1
    save('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix.mat', 'cmatrix');
else
    save('/media/mbakker/data1/Hypoxia/SeedPairs/cmatrix_NoGSR.mat', 'cmatrix');
end

end