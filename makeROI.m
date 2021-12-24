function makeROI(DataFolder)
%laad data
        if ~exist('dat', 'var')
            fid = fopen([DataFolder 'fChanCor.dat']);
            dat = fread(fid,inf,'*single');
            Infos = matfile([DataFolder 'fluo_475.mat']);
            dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
            fclose(fid);
            clear Infos fid 
        end
        
        load([DataFolder 'Mask.mat']);
        
%     if ( exist([path_norm filesep '/ROI_Bregma.mat'], 'file') )
%         load(strcat(path_norm,'/ROI_Bregma.mat'));
%     else
%zorg ervoor dat groene image er goed uit ziet
        fid = fopen([DataFolder 'green.dat']);
        Gimg = fread(fid, 192*192, '*single');
        Gimg = reshape(Gimg,192,192);
        Gimg = Gimg - imgaussfilt(Gimg, 4);
        Gimg = (Gimg - min(Gimg(:)))/(max(Gimg(:)) - min(Gimg(:)));
        Gimg(Gimg<0) = 0;
        Gimg(Gimg>1) = 1;
        Gimg = adapthisteq(Gimg,'Numtiles', [8 8]);
        
        %to check the regions of interest     
        %maak functional map zodat je dubbel kan checken
        FuncMap = sum(abs(dat-1),3);
        P = prctile(FuncMap(Mask(:)),[1 99]);
        FuncMap = (FuncMap - P(1))./(P(2) - P(1));
        FuncMap(FuncMap<0) = 0;
        FuncMap(FuncMap>1) = 1;
        
        answer = 'No';
        
        while( strcmp(answer, 'No') )
            
            obj = ROImanager(Gimg.*Mask);
            waitfor(obj);
            
            load([DataFolder 'ROI_149.mat']);
            
            AtlasMask = zeros(size(dat,1),size(dat,2));
            for ind = 1:size(ROI_info,2)
                AtlasMask(ROI_info(ind).Stats.ROI_binary_mask) = ind;
            end
            
            figh = figure;
            ax1 = axes('Parent', figh);
            ax2 = axes('Parent', figh);
            linkprop([ax1, ax2], {'Position','xlim','ylim'});
            
            % imagesc(ax1, AnaMap);
            imagesc(ax1,FuncMap.*Mask);
            colormap(ax1, 'gray');
            axis(ax1, 'image');
            axis(ax1, 'off');
            
            imagesc(ax2, AtlasMask, 'AlphaData', 0.5*(AtlasMask>0));
            colormap(ax2, 'jet');
            axis(ax2, 'image');
            axis(ax2, 'off');
            clear ax1 ax2 figh;
            clear h;
            
            answer = questdlg('Does it make sense?', ...
                'ROI', ...
                'Yes','No','Yes');
            % Handle response
            switch answer
                case 'Yes'
                    disp('Save ROI');
                    close all
                case 'No'
                    close all
            end
        end
end