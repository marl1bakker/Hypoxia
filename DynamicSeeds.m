function DynamicSeeds(DataFolder)
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

fid = fopen([DataFolder 'fChanCor.dat']);
dat = fread(fid, inf, '*single');
fclose(fid);

dat = reshape(dat,192, 192,[]);
dat = imfilter(dat, fspecial('disk', 2.5),'same','symmetric');
dat = reshape(dat, [], size(dat,3));

idx = strfind(DataFolder, filesep);
NormFolder = [DataFolder(1:idx(end-1)) 'Normoxia_1' filesep];
load([NormFolder 'ROI_149.mat'])

%%  Grid 35 a 170 -> 135  42 a 172 -> 130 
[iX, iY] = meshgrid(1:5:192, 1:5:192);

index = sub2ind([192 192], iY, iX);

Atlas = zeros(192);
for indA = 1:size(ROI_info,2)
    Atlas(ROI_info(indA).Stats.ROI_binary_mask) = indA;
end

idx = arrayfun(@(x) endsWith(ROI_info(x).Name, '_L'), 1:size(ROI_info,2));
RH_Mask = imfill(bwmorph(ismember(Atlas,find(~idx)) ,'close',inf),'holes');
LH_Mask = imfill(bwmorph(ismember(Atlas,find(idx)),'close',inf),'holes');

S = mean(dat(RH_Mask(:)|LH_Mask(:),:),1);
X = [ones(size(S)); S./mean(S)];
B = X'\dat';
A = (X'*B)';
dat = dat - A;

iLH = index(LH_Mask(index));
iRH = index(RH_Mask(index));

sLH = dat(iLH,:);
sRH = dat(iRH,:);
Cleft_N = corr(sLH(:, 3000:9000)', sLH(:,3000:9000)');
Cleft_H = corr(sLH(:, 15000:21000)', sLH(:,15000:21000)');
Cright_N = corr(sRH(:, 3000:9000)', sRH(:,3000:9000)');
Cright_H = corr(sRH(:, 15000:21000)', sRH(:,15000:21000)');
Cinter_N = corr(sLH(:, 3000:9000)', sRH(:,3000:9000)');
Cinter_H = corr(sLH(:, 15000:21000)', sRH(:,15000:21000)');


Gfunc = @(A, mu, sigma, x) A*exp(-((x - mu).^2)./(sigma.^2));
Fhist = figure;
H1 = histogram(Cleft_H(:) - Cleft_N(:),-0.5:0.01:0.5);
hold;
H2 = histogram(Cright_H(:) - Cright_N(:),-0.5:0.01:0.5);
H3 = histogram(Cinter_H(:) - Cinter_N(:),-0.5:0.01:0.5);
F = fit(linspace(-0.5, 0.5, 100)', H1.Values', Gfunc,...
    'StartPoint', [max(H1.Values), 0, 0.25]);
plot(linspace(-0.5,0.5,100)', Gfunc(F.A, F.mu, F.sigma,linspace(-0.5,0.5,100)'),...
    'Color', [0.0 0.45, 0.74], 'LineWidth',4)
Params(:,1) = [F.A, F.mu, F.sigma];

F = fit(linspace(-0.5, 0.5, 100)', H2.Values', Gfunc,...
    'StartPoint', [max(H2.Values), 0, 0.25]);
plot(linspace(-0.5,0.5,100)', Gfunc(F.A, F.mu, F.sigma,linspace(-0.5,0.5,100)'),...
    'Color', [0.85, 0.33, 0.1], 'LineWidth',4)
Params(:,2) = [F.A, F.mu, F.sigma];

F = fit(linspace(-0.5, 0.5, 100)', H3.Values', Gfunc,...
    'StartPoint', [max(H3.Values), 0, 0.25]);
plot(linspace(-0.5,0.5,100)', Gfunc(F.A, F.mu, F.sigma,linspace(-0.5,0.5,100)'),...
    'Color', [0.93, 0.69, 0.13], 'LineWidth',4)
Params(:,3) = [F.A, F.mu, F.sigma];

save([DataFolder 'Params.mat'], 'Params');
savefig(Fhist, [DataFolder 'Histogram.fig']);
saveas(Fhist, [DataFolder 'Histogram.tif'])
% %%
% load([DataFolder 'AnaMap.mat'])
% % AnaMap([iX,iY]) = 0;
% % AnaMap(iLH) = NaN;
% % AnaMap(iRH) = NaN;
% imagesc(AnaMap)
% hold;
% plot(iX(:),iY(:),'.')
% %%
% figure;
% for ind = 1:4800
%    
%     imagesc(reshape(dat(:,ind),192,192),[-0.05 0.05])
%     pause(0.01);
close(Fhist)
end