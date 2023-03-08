% give ROI_input as 'BigROI.mat' or as 'ROI_149.mat'

function SeedGeneratorHbO(DataFolder, ROI_input, ManualInput, GSR)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if ~exist('GSR', 'var')
    GSR = 1;
end

if( exist([DataFolder 'TimecoursesHbO.mat'], 'file') && ManualInput == 0 && GSR == 1)
    disp('Timecourses already calculated, function exited')
    return
elseif( exist([DataFolder 'TimecoursesHbO.mat'], 'file') && ManualInput == 1 && GSR == 1)
    disp('Timecourses already calculated, OVERWRITING FILES')
    
elseif( exist([DataFolder 'TimecoursesHbO_NoGSR.mat'], 'file') && ManualInput == 0 && GSR == 0)
    disp('Timecourses already calculated, function exited')
    return
elseif( exist([DataFolder 'TimecoursesHbO_NoGSR.mat'], 'file') && ManualInput == 1 && GSR == 0)
    disp('Timecourses already calculated, OVERWRITING FILES')
end


if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

%% BIGROI
if strcmp(ROI_input, 'BigROI.mat')
    
    %% load ROI
    idx = strfind(DataFolder, filesep);
    pathFixed = [DataFolder(1:idx(end-1)) 'Normoxia_1'];
    if exist([pathFixed filesep ROI_input], 'file')
        load([pathFixed filesep ROI_input]);
    else
        disp(['No ' ROI_input ' found'])
        return
    end
    
    %% get data
    %     fid = fopen([DataFolder 'fChanCor.dat']);
    fid = fopen([DataFolder 'HbO.dat']);
    dat = fread(fid, inf, '*single');
    dat = reshape(dat, 192,192, []);
    
    load([DataFolder 'MaskC.mat']); %get specific mask per acquisition to make sure you dont get seeds that are outliers or on window artefacts
    %     Mask = load([DataFolder(1:idx(end-1)) 'Mask.mat']); %get general mask of mouse
    Mask = Mask; %was Mask.Mask...?
    clear idx
    
    dat = dat.*Mask;
    dat(dat == 0) = NaN;
    
    %% GSR
    if GSR == 1
        
        dims = size(dat);
        dat = reshape(dat,[], dims(3));
        mS = mean(dat,1, 'omitnan');
        
        X = [ones(size(mS)); mS];
        B = X'\dat';
        A = (X'*B)';
        dat = dat./A;
        %     dat = reshape(dat,dims);
        clear h Mask mS X B A;
        
    else
        dims = size(dat);
        dat = reshape(dat,[], dims(3));
    end
    
    %%
    FN = fieldnames(BigROI);
    Timecourses = zeros(size(FN,1), size(dat,2), 'single');
    
    for ind = 1:size(FN,1)
        eval(['ROI = BigROI.' FN{ind} ';'])
        if (all(ROI == 0))
            timecourse = NaN(1,size(dat,2));
        else
            %ROI is mask now
            
            %% Find Centroid
            % Get centroid of ROI based on weight
            [X, Y] = meshgrid(1:192, 1:192);
            iX = sum(X(:).*ROI(:))/sum(ROI(:));
            iY = sum(Y(:).*ROI(:))/sum(ROI(:));
            iX = round(iX);
            iY = round(iY);
            %expand slightly
            Seed = zeros(192);
            Seed(iY, iX) = 1;
            Seed = conv2(Seed, fspecial('disk',3)>0,'same')>0;
            
            %% Get timecourse
            %         timecourse = mean(dat(Seed(:), :), 1);
            timecourse = mean(dat(Seed(:), :), 1, 'omitnan'); %%NEW 28-3-22
        end
        
        Timecourses(ind,:) = timecourse;
    end
    
    %To exclude Auditory cortex
    Timecourses = [Timecourses(1:2,:); Timecourses(4:7,:); Timecourses(9:10,:)];
    
    if GSR == 1
        save([DataFolder 'TimecoursesHbO.mat'], 'Timecourses');
    else
        save([DataFolder 'TimecoursesHbO_NoGSR.mat'], 'Timecourses');
    end
    
    %% ROI_149
else
    
    %% load ROI
    idx = strfind(DataFolder, filesep);
    pathFixed = [DataFolder(1:idx(end-1)) 'Normoxia_1'];
    if exist([pathFixed filesep ROI_input], 'file')
        load([pathFixed filesep ROI_input]);
    else
        disp(['No ' ROI_input ' found'])
        return
    end
    
    %% get data
    fid = fopen([DataFolder 'HbO.dat']);
    dat = fread(fid, inf, '*single');
    dat = reshape(dat, 192,192, []);
    
    load([DataFolder 'MaskC.mat']);
    %     Mask = load([DataFolder(1:idx(end-1)) 'Mask.mat']); %get general mask of mouse
    Mask = Mask.Mask;
    clear idx
    dat = dat.*Mask;
    dat(dat == 0) = NaN;
    
    %% GSR
    if GSR == 1
        dims = size(dat);
        dat = reshape(dat,[], dims(3));
        mS = mean(dat,1, 'omitnan');
        
        X = [ones(size(mS)); mS];
        B = X'\dat';
        A = (X'*B)';
        dat = dat./A;
        %     dat = reshape(dat,dims);
        clear h Mask mS X B A;
    end
    %%
    Timecourses = zeros(size(ROI_info,2), size(dat,2), 'single');
    
    for ind = 1:size(ROI_info,2)
        
        %% Find Centroid
        % Get centroid of ROI based on weight
        [X, Y] = meshgrid(1:192, 1:192);
        iX = sum(X(:).*ROI_info(ind).Stats.ROI_binary_mask(:))/sum(ROI_info(ind).Stats.ROI_binary_mask(:));
        iY = sum(Y(:).*ROI_info(ind).Stats.ROI_binary_mask(:))/sum(ROI_info(ind).Stats.ROI_binary_mask(:));
        iX = round(iX);
        iY = round(iY);
        %expand slightly
        Seed = zeros(192);
        Seed(iY, iX) = 1;
        Seed = conv2(Seed, fspecial('disk',3)>0,'same')>0;
        
        %% Get timecourse
        timecourse = mean(dat(Seed(:), :), 1);
        Timecourses(ind,:) = timecourse;
    end
    
    if GSR == 1
        save([DataFolder 'TimecoursesHbO.mat'], 'Timecourses');
    else
        save([DataFolder 'TimecoursesHbO_NoGSR.mat'], 'Timecourses');
    end
    
    
end
end