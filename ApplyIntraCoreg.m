function ApplyIntraCoreg(DataFolder)

if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

T = 0;
Demons = 0;
load([DataFolder 'IntraCoReg.mat']);
colours = {'yellow', 'red', 'green', 'fluo_475'};
for index = 1:size(colours,2)
    %First step: Affine2D transform
    datname = strcat(colours{index},'.dat');
    fid = fopen([DataFolder datname]);
    dat = fread(fid, inf, '*single');
    fclose(fid);
    dat = reshape(dat, 192,192,[]);
    if( size(dat,3) > size(T,3) )
        dat = dat(:,:,1:size(T,3));
    end
    dat = flipud(rot90(dat));
    
    parfor indT = 1:size(T,3)
        tform = affine2d; %maak een soort lege matrix met waardes waarmee je elk frame moet verschuiven
        tform.T = T(:,:,indT);
        dat(:,:,indT) = imwarp(dat(:,:,indT), tform, 'OutputView', imref2d([192,192])); %verschuif eerst linear, dus links/rechts voor/achter en roteren
        dat(:,:,indT) = imwarp(dat(:,:,indT), Demons(:,:,:,indT));  %met demons verschuif je op zo'n manier dat bepaalde delen groter worden en andere kleiner.
    end
    
    fid = fopen([DataFolder datname],'w');
    fwrite(fid,dat,'*single');
    fclose(fid);
    disp(['done for: ' colours{index}])
end
end