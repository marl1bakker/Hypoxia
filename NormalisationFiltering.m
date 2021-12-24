function Hd = NormalisationFiltering(DataFolder, data, lowerthreshold, upperthreshold, bDivide)

dims = size(data);
% Temporal filtering butterworth
Infos = matfile([DataFolder 'fluo_475.mat']);
f = fdesign.lowpass('N,F3dB', 4, lowerthreshold, Infos.Freq); %Fluo lower Freq
lpass = design(f,'butter');
lpSosMat = lpass.sosMatrix;
lpScaleV = lpass.ScaleValues;

f = fdesign.lowpass('N,F3dB', 4, upperthreshold, Infos.Freq);   %Fluo Higher Freq
hpass = design(f,'butter');
hpSosMat = hpass.sosMatrix;
hpScaleV = hpass.ScaleValues;


if( length(size(data)) < 3 )
    data = reshape(data, dims(1), dims(2), []);
end

DQ = parallel.pool.DataQueue;
afterEach(DQ, @UpdateWB);
p = 0;
N = size(data,1);
h = waitbar(0);

Hd = zeros(dims,'single');
if( bDivide )
    parfor ind = 1:dims(1)
        Hd(ind,:,:) = reshape(single(filtfilt(hpSosMat, hpScaleV, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        Hd(ind,:,:) = squeeze(Hd(ind,:,:))./...
            reshape(single(filtfilt(lpSosMat, lpScaleV, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        send(DQ,ind);
    end
    close(h)
else
    parfor ind = 1:dims(1)
        Hd(ind,:,:) = reshape(single(filtfilt(hpSosMat, hpScaleV, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        Hd(ind,:,:) = squeeze(Hd(ind,:,:))-...
            reshape(single(filtfilt(lpSosMat, lpScaleV, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        send(DQ,ind);
    end
    close(h)
end

    function UpdateWB(~)
        p = p + 1;
        waitbar(p/N,h);
    end
end



