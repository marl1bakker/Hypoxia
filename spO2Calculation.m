%% SPO2 calculation 
% ManualInput 1 = overwrite any files that are already there
% ManualInput 0 = Dont overwrite files that are there, skip those
% acquisitions

function spO2Calculation(DataFolder, ManualInput)
%maak datafolder goed, met file seperator erachter
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

%check eerst of je hbo en hbr hebt
if( ~exist([DataFolder 'HbO.dat'], 'file') )
    disp([DataFolder ' HbO and HbR not calculated'])
    return
end

%bij geen manual input doe niet overwriten
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

% als je niet wil overschrijven als hij bestaat, en hij bestaat, return
if( ManualInput == 0 ) && ( exist([DataFolder 'spO2.dat'], 'file') )  
    disp([DataFolder ' spO2 already calculated'])
    return;
end
    
%load data
% HbO = load([DataFolder, 'HbO.mat']);
% HbO = HbO.HbO + 60;
fid = fopen([DataFolder 'HbO.dat']);
HbO = fread(fid,  inf, '*single');
HbO = reshape(HbO, 192, 192, []);
HbO = HbO + 60;
% HbR = load([DataFolder, 'HbR.mat']);
% HbR = HbR.HbR + 40;
fid = fopen([DataFolder 'HbR.dat']);
HbR = fread(fid,  inf, '*single');
HbR = reshape(HbR, 192, 192, []);
HbR = HbR + 40;
% Mask = load([DataFolder, 'MaskC.mat']); %load MaskC because that one is coregistered
% Mask = Mask.Mask;
% Mask = double(Mask);
% Mask(Mask==0) = NaN;
% HbO = HbO .* Mask;
% HbR = HbR .* Mask;

HbT = HbO + HbR;

spO2 = HbO ./ HbT;
clear HbO HbT Mask

%save spo2
fid = fopen([DataFolder 'spO2.dat'],'w');
fwrite(fid, spO2,'single');

% disp([DataFolder 'done'])
end