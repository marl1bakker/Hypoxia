%% HbO/HbR
% voor oude versie zie hbohbr.m of HbOHbR_OLD
% Give datafolder and IgnoreExistingFiles
% 0 = Do not ignore existing files, if HbO and HbR already exist, exit this
% function
% 1 = Ignore existing files, if HbO and HbR already exist, overwrite


function HbOHbRCalculation(DataFolder, IgnoreExistingFiles)

% disp(DataFolder);
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

if( exist([DataFolder 'HbO.mat'], 'file') && IgnoreExistingFiles == 0 )
    disp('HbO/HbR already done, function exited')
    return
end 

%% Do we have the needed data?
anaReg = matfile([DataFolder 'anaReg.mat'] ,'Writable',true);
varlist = who(anaReg,'ImagesClassification');
if( isempty(varlist) || ~isfield(anaReg.ImagesClassification, 'ended') ) %|| is "or" maar kijkt eerst of de eerste klopt voordat het naar de tweede kijkt %did we run hypoxpipeline first?
    disp('Run HypoxPipeline before running HbOHbR')
    throw(MException('No Imagesclass'))
elseif( contains(DataFolder, 'Normoxia_1') ) %is it normoxia 1, then we dont have intercoreg because this is the reference image
    disp('No Intercoreg - Normoxia 1')
elseif( ~isfield(anaReg.InterCoregApp, 'ended') )
    disp('Do InterCoregApp before running HbOHbR')
    throw(MException('No InterCoregApp'))
end
    
%% Load the data
Infos = matfile([DataFolder 'fluo_475.mat']);
dims = [Infos.datSize(1,1), Infos.datSize(1,2), Infos.datLength];

AcqInfoStream = ReadInfoFile(DataFolder);
fid = fopen([DataFolder 'red.dat']);
datr = fread(fid,inf,'*single');
datr = reshape(datr,AcqInfoStream.Width,AcqInfoStream.Height,[]);
fclose(fid);
datr = -log(datr./mean(datr(:,:,1:12000),3));
C = datr(:);
clear datr;

fid = fopen([DataFolder 'green.dat']);
datg = fread(fid,inf,'*single');
datg = reshape(datg,AcqInfoStream.Width,AcqInfoStream.Height,[]);
datg = -log(datg./mean(datg(:,:,1:12000),3));
C = [C, datg(:)];
clear datg;

fid = fopen([DataFolder 'yellow.dat']);
daty = fread(fid,inf,'*single');
daty = reshape(daty,AcqInfoStream.Width,AcqInfoStream.Height,[]);
fclose(fid);
daty = -log(daty./mean(daty(:,:,1:12000),3));
C = [C, daty(:)];
clear daty;
 
%% calculate stuff
eps = ioi_epsilon_pathlength('Hillman', 100, 60, 40, 0); %get pathlengths
Ainv = pinv(eps); %pseudoinverse of eps matrix (inverse niet mogelijk, want niet vierkant, dus soort benadering - Moore-penrose))

Hbs = Ainv*C';

HbO = reshape(Hbs(1,:), dims(1),dims(2),[]);
HbR = reshape(Hbs(2,:), dims(1),dims(2),[]);
clear Hbs C
        
% Normalisation and filtering
% HbO = NormalisationFiltering(HbO, 1/120, 1/10, 1); %nul is voor delen door, 1 is voor min voor hbo/hbr

% colours = {'green', 'yellow', 'red'};
%     
% for ind = 1:size(colours,2)
%     dataname = strcat(DataFolder, colours{ind}, '.dat')
%     fid = fopen(dataname);
%     dat = fread(fid,inf,'*single');
%     Infos = matfile(dataname);
%     dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
%     fclose(fid);
%     clear Infos fid
% 
% end


if  contains(DataFolder, 'Normoxia_1')
    disp('Normoxia 1 acquisition, so no coregistration')
elseif ( exist([DataFolder 'tform.mat'], 'file') )
    load([DataFolder 'tform.mat'])
    for ind = 1:size(HbO,3)
        HbO(:,:,ind) = imwarp(squeeze(HbO(:,:,ind)), tform, 'OutputView',imref2d([size(HbO,1), size(HbO,2)]));
        HbR(:,:,ind) = imwarp(squeeze(HbR(:,:,ind)), tform, 'OutputView',imref2d([size(HbR,1), size(HbR,2)]));
    end
else
    disp('No tform.mat found! Double check Intercoreg')
    return
end
        
imshowpair(HbO(:,:,1),HbR(:,:,1));

HbR = HbR*1e6; %ga van mol naar micromol
HbO = HbO*1e6;

%% Save the data
save([DataFolder 'HbO.mat'], 'HbO', '-v7.3');
save([DataFolder 'HbR.mat'], 'HbR', '-v7.3');

close all

end
    


