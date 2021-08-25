%% Image Classification and Hemodynamic correction
Mice = {'Tom','Nick', 'Jane','Katy'}
datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
acquisition = '/Normoxia_3';

for ind = 1:size(Mice,2)
    mouse = Mice{ind}
    
    try  % to make sure one error doesnt disrupt everything
        %get to right folder
        datafolder = strcat(datafolder, mouse, acquisition);
        cd(datafolder);
        mkdir Figures;
        
        %% Image classification
        ImagesClassification(datafolder, datafolder, 1, 1, 1, 0);
        
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


