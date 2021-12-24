function HypoxPCA(Glist)
MaskLeft = [];
MaskRight = [];
Maps = [];
tformMask = [];
load('MapsHypoxReg.mat');
[iX, iY] = meshgrid(1:5:192, 1:5:192);
index = sub2ind([192 192], iY, iX);
iLeft = index(MaskLeft(index));
iRight = index(MaskRight(index));
for ind = 1:4
    disp([Glist(ind).name ' Starting']);
    if( contains(Glist(ind).name, 'Girlz') )
        continue;
    end
    load([Glist(ind).name filesep 'CoregMask.mat']);
    if( exist([Glist(ind).name filesep 'tformMask.mat']) )
        load([Glist(ind).name filesep 'tformMask.mat']);
        CoregMask = imwarp(CoregMask, tformMask, 'OutputView',imref2d(size(CoregMask)));
        bDoReg = 1;
    else
        bDoReg = 0;
    end
    Maps(:,:,ind) = CoregMask;    
    %Hypox 8%
    disp('Hypox 8');
    SubFunc(8);  
    %Hypox 10
    disp('Hypox 10');
    SubFunc(10);
    %Hypox 12
    disp('Hypox 12');
    SubFunc(12); 
    disp('Done');
end

    function SubFunc(HypxLevel)
        idxFolder = strfind(Glist(ind).name, [filesep 'Normoxia_1']);
        switch(HypxLevel)
            case 8
                sH = [Glist(ind).name(1:idxFolder) 'Hypox_8_1' filesep];
            case 10
                sH = [Glist(ind).name(1:idxFolder) 'Hypox_10' filesep];
            case 12
                sH = [Glist(ind).name(1:idxFolder) 'Hypox_12' filesep];
        end
        fid = fopen([sH 'fChanCor.dat']);
        fseek(fid, 2999*192*192*4, 'bof');
        dat = fread(fid, 192*192*6000, '*single');
        if( bDoReg )
            dat = reshape(dat, 192,192, 6000);
            parfor(indF = 1:size(dat,3), 6)
                dat(:,:,indF) = imwarp(dat(:,:,indF), tformMask, 'OutputView',imref2d(size(CoregMask)));
            end
        end
        dat = reshape(dat, 192*192,[]);
        dat = dat([iLeft; iRight],:);
        Cbefore = corr(dat');
        
        fseek(fid, 14999*192*192*4, 'bof');
        dat = fread(fid, 192*192*6000, '*single');
        if( bDoReg )
            dat = reshape(dat, 192,192, 6000);
            parfor(indF = 1:size(dat,3), 6)
                dat(:,:,indF) = imwarp(dat(:,:,indF), tformMask, 'OutputView',imref2d(size(CoregMask)));
            end
        end
        dat = reshape(dat, 192*192, 6000);
        dat = dat([iLeft; iRight],:);
        CHyp = corr(dat');
    
        save([sH 'CorrGrid.mat'], 'iLeft', 'iRight', 'Cbefore', 'CHyp');
    end
end