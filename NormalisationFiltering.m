function Hd = NormalisationFiltering(data, lowerthreshold, upperthreshold, bDivide)

dims = size(data);
% Temporal filtering butterworth
Infos = matfile('fluo_475.mat');
f = fdesign.lowpass('N,F3dB', 4, lowerthreshold, Infos.Freq); %Fluo lower Freq
lpass = design(f,'butter');
f = fdesign.lowpass('N,F3dB', 4, upperthreshold, Infos.Freq);   %Fluo Higher Freq
hpass = design(f,'butter');

if( length(size(data)) < 3 )
    data = reshape(data, dims(1), dims(2), []);
end

Hd = zeros(dims,'single');
if( bDivide )
    for ind = 1:dims(1)
        disp(ind);
        Hd(ind,:,:) = reshape(single(filtfilt(hpass.sosMatrix, hpass.ScaleValues, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        Hd(ind,:,:) = squeeze(Hd(ind,:,:))./...
            reshape(single(filtfilt(lpass.sosMatrix, lpass.ScaleValues, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
    end
else
    for ind = 1:dims(1)
        disp(ind);
        Hd(ind,:,:) = reshape(single(filtfilt(hpass.sosMatrix, hpass.ScaleValues, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
        Hd(ind,:,:) = squeeze(Hd(ind,:,:))-...
            reshape(single(filtfilt(lpass.sosMatrix, lpass.ScaleValues, double(squeeze(data(ind,:,:))'))'),dims(2),dims(3));
    end
end



