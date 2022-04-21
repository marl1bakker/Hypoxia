
% load('Glist.mat')
% for index = 1:size(Glist,2)
%     HypoxPipeline(Glist(index).name, 0)
% end
function HypoxPipeline(DataFolder, ManualInput)
%ManualInput: wil je tijdends het runnen van de pipeline alles doen waarbij
%je dus ook MAsk en ROI moet maken, of wil je hem laten runnen als je er
%niet bij bent?
%1 voor de eerste optie, 0 voor de tweede

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

disp(DataFolder)
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

anaReg = matfile([DataFolder 'anaReg.mat'] ,'Writable',true);
%% ImagesClassification
disp('ImagesClassification');
varlist = who(anaReg,'ImagesClassification');
if( isempty(varlist) || ~isfield(anaReg.ImagesClassification, 'ended') ) %|| is "or" maar kijkt eerst of de eerste klopt voordat het naar de tweede kijkt
  disp('Running...')
    anaReg.ImagesClassification = [];
    ImgClass.started = datestr(now);
    try
        disp(DataFolder);
        ImagesClassification(DataFolder, DataFolder, 1, 1, 0, 0);
        ImgClass.ended = datestr(now);
    catch
        ImgClass.error = datestr(now);
        anaReg.ImagesClassification = ImgClass;
        disp(['ImagescClassification error' DataFolder])
        return;
    end
    anaReg.ImagesClassification = ImgClass;
    clear ImgClass;
else
    disp('already done.');
end
%% Intra-Coregistration
disp('IntraCoregCalc');
varlist = who(anaReg,'IntraCoregCalc');
if( isempty(varlist) || ~isfield(anaReg.IntraCoregCalc, 'ended') )
    disp('Running...')
    anaReg.IntraCoregCalc = [];
    IntraCoregCalc.started = datestr(now);
    try
        IntraCoRegistration(DataFolder);
        IntraCoregCalc.ended = datestr(now);
    catch
        IntraCoregCalc.error = datestr(now);
        anaReg.IntraCoregApp = IntraCoregCalc;
        disp(['IntraCorecCalc error' DataFolder])
        return;
    end
    anaReg.IntraCoregCalc = IntraCoregCalc;
    clear IntraCoregCalc;
else
    disp('already done.');
end

disp('IntraCoregApp');
varlist = who(anaReg,'IntraCoregApp');
if( isempty(varlist) || ~isfield(anaReg.IntraCoregApp, 'ended') )
    disp('Running...')
    anaReg.IntraCoregApp = [];
    IntraCoregApp.started = datestr(now);
    try
        ApplyIntraCoreg(DataFolder);
        IntraCoregApp.ended = datestr(now);
    catch
        IntraCoregApp.error = datestr(now);
        anaReg.IntraCoregApp = IntraCoregApp;
        disp(['IntraCoregApplication error' DataFolder])
        return;
    end
    anaReg.IntraCoregApp = IntraCoregApp;
    clear IntraCoregApp;
else
   disp('already done.');
end

%% HemoCorr
disp('HemoCorr');
varlist = who(anaReg,'HemoCorr');
if( isempty(varlist) || (~isfield(anaReg.HemoCorr, 'ended')) )
    disp('Running...')
    anaReg.HemoCorr = [];
    HemoCorr.started = datestr(now);
    try
        dat = HemoCorrection(DataFolder,{'Green','Red','Yellow'});
        fid = fopen([DataFolder 'fChanCor.dat'],'w');
        fwrite(fid,dat,'*single');
        fclose(fid);
        HemoCorr.ended = datestr(now);
    catch
        HemoCorr.error = datestr(now);
        anaReg.IntraCoregApp = HemoCorr;
        disp(['Hemocorrect error' DataFolder])
        return;
    end
    anaReg.HemoCorr = HemoCorr;
    clear HemoCorr;
else
    disp('already done.');
end
    

%% Mask

if( exist([DataFolder 'Mask.mat'], 'file') )
    load([DataFolder 'Mask.mat']);
else
    if ManualInput == 0 %als je geen manual input wilt doen, geef dan in anaReg aan dat je je Mask not moet doen
        anaReg.Mask = 'ToDo';
        disp(['Do Mask for ' DataFolder])
        return;
    else
        makemask(DataFolder);
        load([DataFolder 'Mask.mat']);
    end
end

%% InterCoregCalc
disp('InterCoregCalc')
if( ~contains(DataFolder, 'Normoxia_1') )
    varlist = who(anaReg,'InterCoregCalc');
    if( isempty(varlist) || (~isfield(anaReg.InterCoregCalc, 'ended')) )
        disp('InterCoregCalc');
        idx = strfind(DataFolder, filesep);
        pathFixed = [DataFolder(1:idx(end-1)) 'Normoxia_1'];
        
        anaReg.InterCoregCalc = [];
        InterCoregCalc.started = datestr(now);
        try
            ret = Coregistration(pathFixed, DataFolder, false);
            InterCoregCalc.ended = datestr(now);
        catch
            InterCoregCalc.error = datestr(now);
            anaReg.InterCoregApp = InterCoregCalc;
            disp(['intercoregcalc error' DataFolder])
            return;
        end
        anaReg.InterCoregCalc = InterCoregCalc;
        clear InterCoregCalc pathFixed idx ret
    else
        disp('already done.')
    end
else
    disp('Normoxia 1 - No Intercoreg')
    
    if( exist([DataFolder 'ROI_149.mat'], 'file') )
        load([DataFolder 'ROI_149.mat']);
    else
        if ManualInput == 0  %als je geen manual input wil geven
            anaReg.ROI = 'ToDo';
            disp(['Do ROI for ' DataFolder])
            return;
        else
            disp(DataFolder)
            makeROI(DataFolder); %als je wel manual input wil geven, dus maak roi
        end
    end
end

%% Normalization
disp('Normalization');
varlist = who(anaReg,'Normalization');
if( isempty(varlist) || (~isfield(anaReg.Normalization, 'ended')) )
    anaReg.Normalization = [];
    Normalization.started = datestr(now);
    try 
        if ~exist('dat', 'var')
            fid = fopen([DataFolder 'fChanCor.dat']);
            dat = fread(fid,inf,'*single');
            Infos = matfile([DataFolder 'fluo_475.mat']);
            dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
            fclose(fid);
            clear Infos fid 
        end
        dat = NormalisationFiltering(DataFolder, dat, 0.3, 3, 1);
        fid = fopen([DataFolder 'fChanCor.dat'],'w');
        fwrite(fid,dat,'single');
        fclose(fid);
        
        Normalization.ended = datestr(now);
    catch e
        Normalization.error = datestr(now);
        Normalization.def = e;
        disp('error');
        anaReg.Normalization = Normalization;
        disp(['normalization error' DataFolder])
        return;
    end
    anaReg.Normalization = Normalization;
    clear Normalization fid
else
    disp('already done.')
end

%% InterCoregApp
disp('InterCoregApp')
if( ~contains(DataFolder, 'Normoxia_1') )
    varlist = who(anaReg,'InterCoregApp');
    if( isempty(varlist) || (~isfield(anaReg.InterCoregApp, 'ended')) )
%         disp('InterCoregApp');
        anaReg.InterCoregApp = [];
        InterCoregApp.started = datestr(now);
        try
            tform = affine2d();
            load([DataFolder 'tform.mat'])
            if ~exist('dat', 'var')
                fid = fopen([DataFolder 'fChanCor.dat']);
                dat = fread(fid,inf,'*single');
                Infos = matfile([DataFolder 'fluo_475.mat']);
                dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
                fclose(fid);
                clear Infos fid
            end
            
            parfor( ind = 1:size(dat,3), 4 ) 
                dat(:,:,ind) = imwarp(dat(:,:,ind), tform, 'OutputView',imref2d([192, 192]),'interp','nearest');
            end
            fid = fopen([DataFolder  'fChanCor.dat'],'w');
            fwrite(fid,dat,'*single');
            fclose(fid); %sla coregistered image op als fchancor
            
            %     load([DataFolder 'Mask.mat']);
            %     Mask = imwarp(Mask, tform, 'OutputView',imref2d([192, 192]));
            %     save([DataFolder 'Mask.mat'], 'Mask');
            
            fid = fopen([DataFolder 'green.dat']);
            AnaMap = fread(fid, 192*192 , '*single');
            fclose(fid);
            AnaMap = reshape(AnaMap, 192, 192);
            AnaMap = imwarp(AnaMap, tform, 'OutputView',imref2d([192, 192]));
            save([DataFolder 'AnaMap.mat'], 'AnaMap');
            
            Mask = imwarp(Mask, tform, 'OutputView',imref2d([192, 192])); %geeft streepje maar je hebt mask.mat eerder geladen
            save([DataFolder 'MaskC.mat'], 'Mask');
            InterCoregApp.ended = datestr(now);
            disp('InterCoregApp successful')
        catch e
            disp(['intercoregapp error' DataFolder])
            InterCoregApp.error = datestr(now);
            InterCoregApp.def = e; 
            anaReg.InterCoregApp = InterCoregApp;
            throw(e)
%             return;
        end
        anaReg.InterCoregApp = InterCoregApp;
        clear AnaMap fid ind Mask tform InterCoregApp
    end
else
    load([DataFolder 'Mask.mat']);
    save([DataFolder 'MaskC.mat'], 'Mask');
    disp('Normoxia 1 - no Intercoreg')
end

%% HbO HbR
disp('HbO HbR calculation')
varlist = who(anaReg,'HbOHbR');

if( isempty(varlist) || (~isfield(anaReg.HbOHbR, 'ended')) )
    anaReg.HbOHbR = [];
    HbOHbRvar.started = datestr(now);
    try
        HbOHbRCalculation(DataFolder, 1);  %0 is negeer niet als files al bestaan, 1 is negeer het wel en overwrite
        HbOHbRvar.ended = datestr(now);
    catch e
        disp(['HbOHbR error' DataFolder])
        HbOHbRvar.error = datestr(now);
        HbOHbRvar.def = e;
        anaReg.HbOHbR = HbOHbRvar;
        throw(e)
    end
    anaReg.HbOHbR = HbOHbRvar;
    clear HbOHbRvar 
else
    disp('already done.')
end

%% SpO2 calculation 
disp('spO2 calculation')
varlist = who(anaReg,'spO2');

if( isempty(varlist) || (~isfield(anaReg.spO2, 'ended')) )
    anaReg.spO2 = [];
    spO2var.started = datestr(now);
    try
        spO2Calculation(DataFolder, 1);  %0 is negeer niet als files al bestaan, 1 is negeer het wel en overwrite
        spO2var.ended = datestr(now);
    catch e
        disp(['spO2 error' DataFolder])
        spO2var.error = datestr(now);
        spO2var.def = e;
        anaReg.spO2 = spO2var;
        throw(e)
    end
    anaReg.spO2 = spO2var;
    clear spO2var 
else
    disp('already done.')
end

%% Bigger ROI
disp('Clustering of ROI')
varlist = who(anaReg,'ClusterROI');

if( isempty(varlist) || (~isfield(anaReg.ClusterROI, 'ended')) )
    anaReg.ClusterROI = [];
    ClusterROIvar.started = datestr(now);
    try
        ClusterRois(DataFolder, 1);  %0 is negeer niet als files al bestaan, 1 is negeer het wel en overwrite
        ClusterROIvar.ended = datestr(now);
    catch e
        disp(['spO2 error' DataFolder])
        ClusterROIvar.error = datestr(now);
        ClusterROIvar.def = e;
        anaReg.ClusterROI = ClusterROIvar;
        throw(e)
    end
    anaReg.ClusterROI = ClusterROIvar;
    clear ClusterROIvar 
else
    disp('already done.')
end


%% Seed generator & Timecourse calculator
disp('Generator of Seeds')
varlist = who(anaReg,'SeedGen');

if( isempty(varlist) || (~isfield(anaReg.SeedGen, 'ended')) )
    anaReg.SeedGen = [];
    SeedGenvar.started = datestr(now);
    try
        SeedGenerator(DataFolder, 'BigROI.mat', 1); %can be changed for 'ROI_149.mat'  
        SeedGenvar.ended = datestr(now);
    catch e
        disp(['SeedGenerator error' DataFolder])
        SeedGenvar.error = datestr(now);
        SeedGenvar.def = e;
        anaReg.SeedGen = SeedGenvar;
        throw(e)
    end
    anaReg.SeedGen = SeedGenvar;
    clear SeedGenvar 
else
    disp('already done.')
end
% Girls 10% are not corrected, so hypoxia starts at wrong time there



%% end
disp('Everything done! yay')
close all
clear anaReg DataFolder Mask varlist
% pause(10);
% disp('end of pause')


end
