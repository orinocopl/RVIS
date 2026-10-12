close all;
clear all;

f_nominal_reader = 868e6;

Fs = 10e6; %SPS
fs = Fs;
bandwidth=2e6;

sekundy=10;
Xlen=Fs*sekundy; 

gain4=0;

skok=10;

sciezka_skryptu = '/home/user/nuandsdr/nuand2sync.py';
NC=4; 

for nr=0:NC-1
    plik_danych = sprintf('/tmp/nuand%d.bin',nr);

    if exist(plik_danych, 'file')
        delete(plik_danych);
    end
end

system('/home/user/nuandsdr/U/r2');

komenda = sprintf('python3 %s --tuning %d --gain4 %d --sps %d --bandwidth %d --nosamples %d', sciezka_skryptu, f_nominal_reader, gain4, Fs, bandwidth, Xlen);
[status, cmdout] = system(komenda); 
if status ~= 0
    error('Error GNU Radio: %s', cmdout);
end

X=zeros(Xlen,NC);

for nr=0:NC-1
    plik_danych = sprintf('/tmp/nuand%d.bin',nr);
    fid = fopen(plik_danych, 'rb');
    if fid == -1
        error('Nie można otworzyć pliku z danymi.');
    end
    
    surowe_dane = fread(fid, 2 * Xlen, 'short'); 
    fclose(fid);
    
    X(:,1+nr) = surowe_dane(1:2:end) + 1i * surowe_dane(2:2:end);
end

for nn=1:NC/2
    iq_signal=X(:,nn*2-1);
    Nfft = 2^nextpow2(length(iq_signal));
    frequencies = (-Nfft/2 : Nfft/2-1) * (Fs/Nfft);
    signal_fft = fftshift(fft(iq_signal, Nfft));
    [~, max_idx] = max(abs(signal_fft));
    
    delta_f_measured = frequencies(max_idx); 
    ppm_error = (delta_f_measured / f_nominal_reader) *1e6;
    
    fprintf('Zmierzona delta f na 868 MHz: %.2f Hz\n', delta_f_measured);
    fprintf('Wyznaczona stała korekta sprzętowa PPM: %.3f PPM\n\n', ppm_error);
    
    f_sdr_center_new = f_nominal_reader  +delta_f_measured; 
    Fs_new=Fs;

    delta_f_predicted = (ppm_error * f_sdr_center_new) / 1e6;
    
    t_new = (0:Xlen-1)' / Fs_new;
    kompensacja = exp(-1i * 2 * pi * delta_f_predicted * t_new);
    X(:,nn*2-1)   = X(:,nn*2-1)   .* kompensacja;
    X(:,nn*2-1+1) = X(:,nn*2-1+1) .* kompensacja;
end

X=int16(X);
save('nuand2.mat', 'X','Fs','fs','f_nominal_reader','bandwidth','gain4','-v6');
