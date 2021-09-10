%% Once you get the data:
datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
mouse = 'Tom';
% mouse = 'Jane';
mouse = 'Katy';
mouse = 'Nick';

acquisition_norm = '/Normoxia_1';
acquisition_hypox12 = '/Hypox_12';
acquisition_norm2 = '/Normoxia_2';
acquisition_hypox10 = '/Hypox_10';
acquisition_hypox8 = '/Hypox_8';

path_norm = strcat(datafolder, mouse, acquisition_norm);
path_hypox12 = strcat(datafolder, mouse, acquisition_hypox12);
path_norm2 = strcat(datafolder, mouse, acquisition_norm2);
path_hypox10 = strcat(datafolder, mouse, acquisition_hypox10);
path_hypox10 = strcat(datafolder, mouse, acquisition_hypox10);

currentacq = replace(acquisition_hypox10, '/', '');
datafolder = path_hypox10

cd(datafolder);
videoname = mouse;
% videoname = replace(videoname, '_', ' ');

%% Step B. Image Classification. Maak fluorescence als je dat nog niet gedaan hebt
%only have to do these lines once: 
ImagesClassification(datafolder, datafolder, 1, 1, 1, 0);

%% Hemo Correction (step 1)
if( exist('fChanCor.dat', 'file') ) %if youve already done hemocorrection, load file
    fid = fopen('fChanCor.dat');
    dat = fread(fid,inf,'*single');
    Infos = matfile('fluo_475.mat');
    %AcqInfoStream = ReadInfoFile(datafolder);
    dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
    fclose(fid);
else
    dat = HemoCorrection(pwd,{'Green','Red','Yellow'});
    fid = fopen('fChanCor.dat','w');
    fwrite(fid,dat,'*single');
    fclose(fid);
end

dat=permute(dat,[2,1,3]);
dims = size(dat);
videoname = strcat(videoname, ', Hemodynamic Correction')


%% Change names of files, make base picture
%because names changed:
if( exist([pwd filesep 'gChan.dat'], 'file') ) %filesep is / -- werkt bij alle systemen, want windows is / en apple is \
    movefile 'gChan.dat' 'green.dat'
end
if( exist([pwd filesep 'Data_Fluo_475.mat'], 'file') ) %filesep is / -- werkt bij alle systemen, want windows is / en apple is \
    movefile 'Data_Fluo_475.mat' 'fluo_475.mat'
end

fid = fopen('green.dat');

AnaMap = fread(fid, dims(1)*dims(2),'*single');
AnaMap = reshape(AnaMap, dims(1),[])';

clear fid;

%check if the right side is up
imagesc(squeeze(dat(:,:,4)))

%% Make mask in a nice way
imagesc(AnaMap)
h= impoly; %dont close, draw mask

Mask = h.createMask;
Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
Im = Im./max(Im(:));

Mask = bwmorph(Mask&(Im<=0.25),'close',inf);
close all
imagesc(Mask)
% imshowpair(Mask,AnaMap)

save('Mask.mat', 'Mask');

load('Mask.mat');

%% Coregistration -- MAKE SURE IT'S THE CORRECT PATHS
cd(datafolder);

if matches(datafolder, 'path_norm')
    disp('geen coregistration - is normoxia path') %make sure you dont do the coregistration on the first norm path
else
    dat = Coregistration(path_norm, datafolder);
end
     
% datN2 = Coregistration(path_norm, path_norm_2);
% dat = datN2;

fid = fopen([datafolder filesep 'fChanCorCoReg.dat'],'w');
fwrite(fid,dat,'*single');
fclose(fid); %sla coregistered image op als fchancor


%%