function PreProcessing(folderpath)

%% Image Classification and Hemodynamic correction
% Mice = {'Tom','Nick', 'Jane','Katy'}
Mice = {'Tom'}
acquisition = '/Normoxia_1';
colours = {'green','red', 'amber','fluo_475'};

for ind = 1:size(Mice,2)
    mouse = Mice{ind}
    
    try  % to make sure one error doesnt disrupt everything
        %get to right folder
        datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
        datafolder = strcat(datafolder, mouse, acquisition);
        cd(datafolder);
        mkdir Figures;
        
        %% Image classification
        ImagesClassification(datafolder, datafolder, 1, 1, 1, 0);
        
        %% Coregistration within mouse (for movement correction)
        IntraCoRegistration(datafolder);
        disp('Movement correction done')
        T = 0;
        Demons = 0;
        load('IntraCoReg.mat');
        
        for index = 1:size(colours,2)
            %First step: Affine2D transform
            datname = strcat(colours{index},'.dat');
            fid = fopen(datname);
            dat = fread(fid, inf, '*single');
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
            
            fid = fopen(datname,'w');
            fwrite(fid,dat,'*single');
            fclose(fid);
        end
        
        %% Hemo Correction
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
    catch ME
        disp(ME)
    end
end


