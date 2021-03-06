function PreProcessing(acquisition, batch, Mice)
fprintf('start preprocessing')
%% Image Classification and Hemodynamic correction
% Mice = {'Tom','Nick', 'Jane','Katy'}
% Mice = {'Nick', 'Jane','Katy'}
% Mice = {'Nick'}
% Mice = {'227', '552', '087'}
% batch = '/media/mbakker/data1/Hypoxia/TheBoys/';
% batch = '/media/mbakker/data1/Hypoxia/TheGirlz/';
% batch = pwd;

colours = {'green','red', 'yellow','fluo_475'};

for ind = 1:size(Mice,2)
    mouse = Mice{ind}
    
    try  % to make sure one error doesnt disrupt everything
        %get to right folder
%         datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
%         datafolder = '/media/mbakker/data1/Hypoxia/TheGirlz/';
        %         datafolder = strcat(datafolder, mouse, '/', acquisition);
%         datafolder = ;
        datafolder = strcat(batch, '/', mouse, '/', acquisition );
        cd(datafolder);
        mkdir Figures;
        
        %% Image classification
        if( exist('green.dat', 'file') )
            disp('Image Classification already done')
        else
            ImagesClassification(datafolder, datafolder, 1, 1, 1, 0);
        end
        
        %% Coregistration within mouse (for movement correction)
        if( exist('IntraCoReg.mat', 'file') )
            disp('Coregistration within mouse already done')
        else
            
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
                disp('bla')
            end
            
            disp('coregistration applied')
            
            
            %% Hemo Correction
            dat = HemoCorrection(datafolder,{'Green','Red','Yellow'});
            fid = fopen('fChanCor.dat','w');
            fwrite(fid,dat,'*single');
            fclose(fid);
            %         end
        end
        
    catch ME
        disp(ME)
        disp('ging dus iets fout')
    end
end

end
