%Matlab script to read binary data saved from the small animal monitoring
%platform.
%Make sure tu run the script in the directory of the data.

%Read ECG data and convert to mV
fid=fopen('ECG1.bin','r'); %ECG external leads
data = uint8(fread(fid));
ECG1 = double(swapbytes(typecast(data,'int32')))/8388608*2400/3;
fclose(fid);
fid=fopen('ECG2.bin','r'); %ECG LA-RA
data = uint8(fread(fid));
ECG2 = double(swapbytes(typecast(data,'int32')))/8388608*2400/3;
fclose(fid);
fid=fopen('ECG3.bin','r'); %ECG LL-RA
data = uint8(fread(fid));
ECG3 = double(swapbytes(typecast(data,'int32')))/8388608*2400/3;
fclose(fid);
fid=fopen('ECG4.bin','r'); %ECG LL-LA
data = uint8(fread(fid));
ECG4 = double(swapbytes(typecast(data,'int32')))/8388608*2400/3;
fclose(fid);

%Read resp data
fid=fopen('resp.bin','r');
data = uint8(fread(fid));
Resp = double(swapbytes(typecast(data,'int16')));
fclose(fid);

%Read temperature data
fid=fopen('temperature1.bin','r');
data = uint8(fread(fid));
Temp1 = double(swapbytes(typecast(data,'int16')));
B25_50 = 3380; voltage = Temp1./25./2.^10.*3.3/2; res = voltage./((3.3-voltage)./10e3); num = (log(10e3)-log(res));
Temp1 = ( 1./(273.15+25) - num./B25_50 ).^-1 - 273.15;  
fclose(fid);
fid=fopen('temperature2.bin','r');
data = uint8(fread(fid));
Temp2 = double(swapbytes(typecast(data,'int16')));
B25_50 = 3950; voltage = Temp2./25./2.^10.*3.3; res = voltage./((3.3-voltage)./10e3); num = (log(10e3)-log(res));
Temp2 = ( 1./(273.15+25) - num./B25_50 ).^-1 - 273.15;  
fclose(fid);
fid=fopen('temperature3.bin','r');
data = uint8(fread(fid));
Temp3 = double(swapbytes(typecast(data,'int16')));
B25_50 = 3380; voltage = Temp3./25./2.^10.*3.3/2; res = voltage./((3.3-voltage)./10e3); num = (log(10e3)-log(res));
Temp3 = ( 1./(273.15+25) - num./B25_50 ).^-1 - 273.15;  
fclose(fid);

%Read breathing rate
fid=fopen('breathingRate.bin','r');
data = uint8(fread(fid));
BR = double(swapbytes(typecast(data,'int16')));
fclose(fid);

%Read heart rate
fid=fopen('HeartRate.bin')
data = uint8(fread(fid));
HR = double(swapbytes(typecast(data,'int16')));
fclose(fid);

%Read SpO2 data (red and infrared LEDs)
fid=fopen('SpO2Infrared.bin','r');
data = uint8(fread(fid));
SPO2_IR = double(swapbytes(typecast(data,'int32')));
fclose(fid);
fid=fopen('SpO2Red.bin','r');
data = uint8(fread(fid));
SPO2_R = double(swapbytes(typecast(data,'int32')));
fclose(fid);

fid=fopen('SpO2.bin','r');
data = uint8(fread(fid));
SPO2 = double(swapbytes(typecast(data,'int16')));
fclose(fid);

%Read BP data
fid=fopen('BloodPressure.bin','r');
data = uint8(fread(fid));
BP = double(swapbytes(typecast(data,'int32')));
BP = (BP-8388608) / 8388608 * 10 * 1000 / 5 / 5;
fclose(fid);

%Read CO2 data
fid=fopen('CO2.bin','r');
data = uint8(fread(fid));
CO2 = double(swapbytes(typecast(data,'int16')));
fclose(fid);

%Temperature2 (rectal) has no /2 anymore. Old data has to be adapted.
% fid=fopen('temperature2 - Old.bin','r');
% data = uint8(fread(fid));
% Temp2 = double(swapbytes(typecast(data,'int16')));
% Temp2 = Temp2 / 2;
% dataNew=(typecast(swapbytes(int16(Temp2)),'uint8'));
% fclose(fid);
% fid=fopen('temperature2.bin','w');
% fwrite(fid,dataNew)
% fclose(fid);

%Make sure vectors are the same length
if size(Temp1,1) > size(Temp2,1)
    Temp2(end+1:size(Temp1,1)) = Temp2(end);
elseif size(Temp2,1) > size(Temp1,1)
    Temp1(end+1:size(Temp2,1)) = Temp1(end);
end
if size(BR,1) > size(HR,1)
    HR(end+1:size(BR,1)) = HR(end);
elseif size(HR,1) > size(BR,1)
    BR(end+1:size(HR,1)) = BR(end);
end

%Display some graphs
figure;
TempFreq = 10; RateFreq = 1;
TempRange = double(1:size(Temp2,1))'./TempFreq./60;
RateRange = double(1:size(BR,1))'./RateFreq./60;

[AX,H1,H2] = plotyy([TempRange],[Temp2],[RateRange RateRange],[BR HR]); %Display 1 temp & 2 rate
leg1 = legend(AX(1), 'Rectal temperature (ºC)', 'Location', 'NorthWest');
leg2 = legend(AX(2), 'Breathing rate (BPM)', 'Heart rate (BPM)', 'Location', 'NorthEast');
set(leg2, 'color', 'white');
xlabel('Time in minutes')
axis(AX(1),'tight');axis(AX(2),'tight');set(AX(2),'XTick',[])

