

%% Nick hypox 10 correction
%was: 48055
%wordt: 48025

load('Mask.mat');

Name = {'fluo_475','green', 'red','yellow'}
deleteframes = []
for ind = 1:size(Name,2)
    fid = fopen([Name{ind} '.dat']);
    dat = fread(fid,inf,'*single');
    dat = reshape(dat, 192,192,[]);
    dat = permute(dat, [2 1 3]);
    dat = diff(dat,1,3);
    dat = dat .* (~Mask);
    
%     entropy(double(abs(dat)));
    E = arrayfun(@(x) entropy(double(abs(dat(:,:,x)))), 1:size(dat,3)); %calculate amount of entropy between frames
    E = zscore(E);
    E = E<-10;
    deleteframes = [deleteframes find(E)];
end

deleteframes = unique(deleteframes)

Name = {'fluo_475','green', 'red','yellow'}
for ind = 1:size(Name,2)
    fid = fopen([Name{ind} '.dat']);
    dat = fread(fid,inf,'*single');
    dat = reshape(dat, 192,192,[]);
    dat(:,:,deleteframes) = [];
    
    datLength = size(dat,3);
    Info = matfile([Name{ind} '.mat'],'Writable',true);
    Info.datLength = datLength;
    
    fid = fopen([Name{ind} '.dat'],'w');
    fwrite(fid, dat, 'single');
end




Name = {'fluo_475','green', 'red','yellow'}

for ind = 1:size(Name,2)
    fid = fopen([Name{ind} '.dat']);

    dat = fread(fid,inf,'*single');
    dat = reshape(dat, 192,192,[]);

%     dat = dat(:,:,[1:12525, 12538:35919 35938:size(dat,3)]);
    dat = dat(:,:,[1:12515, 12545:35910 35945:size(dat,3)]);

    datLength = size(dat,3);
    Info = matfile([Name{ind} '.mat'],'Writable',true);
    Info.datLength = datLength;
    
    fid = fopen([Name{ind} '.dat'],'w');
    fwrite(fid, dat, 'single');
end
% %save in acquisition_information that you deleted files
% fileID = fopen('Acquisition_information.txt','a');
% fprintf(fileID, 'Deleted Before Hypoxia: 13');
% fprintf(fileID, 'Deleted During Hypoxia:');
% fprintf(fileID, 'Deleted After Hypoxia: 19');
% % fprintf(fileID,'%f %f\n',y);
% fclose(fileID);
% type Acquisition_information.txt


%% Tom hypox 10 correction
% Name = 'fluo_475.dat'
% Name = 'green.dat'
% Name = 'red.dat'
Name = {'fluo_475','green', 'red','yellow'}

for ind = 1:size(Name,2)
    fid = fopen([Name{ind} '.dat']);

    dat = fread(fid,inf,'*single');
    dat = reshape(dat, 192,192,[]);
    dat = dat(:,:,[1:35545 35550:size(dat,3)]);

    datLength = size(dat,3);
    Info = matfile([Name{ind} '.mat'],'Writable',true);
    Info.datLength = datLength;
    
    fid = fopen(Name{ind},'w');
    fwrite(fid, dat, 'single');
end