function makemask(DataFolder)

if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

fid = fopen([DataFolder 'green.dat']);
AnaMap = fread(fid, 192*192 , '*single');
fclose(fid);
AnaMap = reshape(AnaMap, 192, 192);

imagesc(AnaMap)
h= impoly; %dont close, draw mask
Mask = h.createMask;
Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
Im = Im./max(Im(:));
Mask = bwmorph(Mask&(Im<=0.25),'close',inf);
close all
obj = imagesc(Mask);
save([DataFolder 'Mask.mat'], 'Mask');
% close all
waitfor(obj)
end
