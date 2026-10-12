close all;
clear all;

%system('fswebcam  -d /dev/video4 -r 640x480 --no-banner /tmp/klatka.jpg')
img = imread('cameraframe.jpg');

NC=4;
load('nuand2.mat');
X=double(X);
Xlen=size(X,1);


fc = f_nominal_reader;
c  = 299792458;

lambda_sygnalu=c/fc;
lambda = 2*(249-83)/1000; 

k = 2*pi/lambda;

ref_ch = 1;

figure

a1=abs(X(:,1));

fa1 = movmax(a1,1000);
fnoise1=fa1>max(fa1(:))/10; 

t=(0:length(X(:,1))-1)/fs;

subplot(3,1,1)
plot(t,abs(X(:,1)))
title('absolute value of the channel')
subplot(3,1,2)
plot(t,fa1)
title('maximum value moving filter')
subplot(3,1,3)
hold on;

roznice = diff(fnoise1);
indeks_narastajace = find(roznice == 1, 1) + 1;
indeksy_zboczy = find(roznice == -1) + 1;
pozycja_startowa =  indeks_narastajace + 0.2*Fs;
indeksy_zboczy = indeksy_zboczy(indeksy_zboczy > pozycja_startowa);
indeks_opadajace = indeksy_zboczy(1);

%plot([indeks_narastajace indeks_narastajace]/fs, [0 1.2],'--','LineWidth',3)
%plot([indeks_opadajace   indeks_opadajace  ]/fs, [0 1.2],'--','LineWidth',3)

noise_axis_data=X(indeks_narastajace:indeks_opadajace,:);
mean_cross_correlation = mean(noise_axis_data .* conj(noise_axis_data(:, ref_ch)), 1);
phase_errors = angle(mean_cross_correlation); 
cal_vector = exp(-1j * phase_errors);
[M, num_channels] = size(X);
cal_matrix = repmat(cal_vector, M, 1);
X = X .* cal_matrix;

plot(t,fnoise1,'r')
title('binary output')
xlabel('time [s]')

noise_axis_data=X(indeks_narastajace:indeks_opadajace,:);
mean_cross_correlation = mean(noise_axis_data .* conj(noise_axis_data(:, ref_ch)), 1);


X(1:indeks_opadajace+round(Fs*0.3),:)=0;

detektor_amp = abs(X(:,1));


figure
boundary=15000;
th_amp=max(detektor_amp)*0.7;
signal_th=X(:,1)>th_amp;
index_first = find(signal_th == 1, 1, 'first')- boundary;
index_last  = find(signal_th == 1, 1, 'last') + boundary;

X=X(index_first:index_last,:);

t=(0:length(X(:,1))-1)/fs;
for nr=1:NC
    subplot(2*NC,1,nr*2-1)
    plot(t,real(X(:,nr)))
    ylabel(sprintf('I ch:%d',nr));
    axis([0 3 -32768 32768])
    subplot(2*NC,1,nr*2)
    plot(t,imag(X(:,nr)))
    ylabel(sprintf('Q ch:%d',nr));
    axis([0 3 -32768 32768])
end

xlabel('time [s]')


x=X; 

N = size(x,1);

% REMOVE DC
for ch = 1:NC
    x(:,ch) = x(:,ch) - mean(x(:,ch));
end

% CHANNEL AMPLITUDE NORMALIZATION
for ch = 1:NC
    pwr = sqrt(mean(abs(x(:,ch)).^2));
    if pwr > 0
        x(:,ch) = x(:,ch)/pwr;
    end
end

% DESIGN BACKSCATTER FILTER
iq_signal = x(1:70000+boundary*2,:);

% BLF Filter
BLF = 640e3;        
M = 8;              
BW_signal = BLF / M;
BW_signal = BW_signal*3; 


F_low  = BLF - (BW_signal / 2);
F_high = BLF + (BW_signal / 2); 

Transition_Width = 10e3;

N_taps = round(5.5 * Fs / Transition_Width);
if mod(N_taps, 2) == 0
    N_taps = N_taps + 1;
end
b_bandpass = fir1(N_taps - 1, [F_low F_high] / (Fs/2), 'bandpass', blackman(N_taps));

figure
[H, f] = freqz(b_bandpass, 1, 2^16, Fs);

subplot(2,1,1);
grid on; hold on;
plot(f/1e3, 20*log10(abs(H)), 'LineWidth', 1.5, 'Color', [0 0.4470 0.7410]);

xline(((F_high-F_low)/2+F_low) /1e3, '--r', 'Miller-8 modulation (640 kHz)', 'LabelVerticalAlignment', 'bottom');

xline(F_low/1e3, ':k'); xline(F_high/1e3, ':k');
title(sprintf('Amplitude Characteristics of the FIR Band-Pass Filter (Fs = %d MSPS)', Fs/1e6));
xlabel('Frequency [kHz]');
ylabel('Attenuation [dB]');

subplot(2,1,2);
plot(f/1e3, unwrap(angle(H)) * (180/pi), 'LineWidth', 1.5, 'Color', [0.8500 0.3250 0.0980]);
grid on;
title('Phase Characteristics (Perfectly linear phase in the passband)');
xlabel('Frequency [kHz]');
ylabel('Phase [degrees]');

iq_final=zeros(size(iq_signal));
ii=1;
for n=1:NC
    iq_final(:,n) = filtfilt(b_bandpass, 1, iq_signal(:,n));
end

Nfft = length(iq_signal(:,1));
frequencies = (-Nfft/2 : Nfft/2-1) * (fs / Nfft);

fft_raw      = 20*log10(fftshift(abs(fft(iq_signal(:,1),   Nfft))) / Nfft);
fft_filtered = 20*log10(fftshift(abs(fft(iq_final(:,1),    Nfft))) / Nfft);

figure('Color', 'w');
plot(frequencies/1e3, fft_raw, 'Color', [0.7 0.7 0.7], 'LineWidth', 1); hold on;
plot(frequencies/1e3, fft_filtered, 'Color', [0 0.5 0], 'LineWidth', 1.5);
grid on;

title('Miller-8 band filtering effect');
xlabel('Frequency [kHz]'); ylabel('Amplitude [dB]');
legend('Raw signal', 'Band-pass filtered tag signal');
xlim([0, fs/2]/1e3);

figure
t=(0:length(iq_signal(:,1))-1)/(fs/1000);

subplot(2,1,1);
hold on;
yyaxis left
plot(t,real(iq_signal(:,1)),'b');
axis([0 t(end) -2.5 2.5])

yyaxis right
plot(t,real(iq_final(:,1)),'r');
title('example channel IQ signal (real)');
axis([0 t(end) -0.1 0.1])

legend('acquired signal','filtered backscatter')

subplot(2,1,2);
hold on;
yyaxis left
plot(t,imag(iq_signal(:,1)),'b');
axis([0 t(end) -2.5 2.5])

yyaxis right
plot(t,imag(iq_final(:,1)),'r');
title('example channel IQ signal (imag)');
axis([0 t(end) -0.1 0.1])

legend('acquired signal','filtered backscatter')

xlabel('time [ms]');

iq_signal = x(1:70000+boundary*2,:);

group_delay = (N_taps - 1) / 2;
iq_final=zeros(size(iq_signal,1),NC); 

for n=1:NC
    iq_final(:,n) = filtfilt(b_bandpass, 1, iq_signal(:,n));
end

figure
subplot(3,1,1)
iq_final_abs=abs(iq_final(:,1));
plot(iq_final_abs);
subplot(3,1,2)

iq_obw=movmax(iq_final_abs,1000);
iq_th=iq_obw > max(iq_obw)/2;

plot(iq_obw);
subplot(3,1,3)

hold on;
plot(iq_th);
roznice = diff(iq_th);
zbocza_narastajace = find(roznice == 1) + 1;
zbocza_opadajace = find(roznice == -1) + 1;

indeks_narastajace1 = zbocza_narastajace(1);
indeks_opadajace1   = zbocza_opadajace(1);

plot([indeks_narastajace1 indeks_narastajace1], [0 2],'r--')
plot([indeks_opadajace1   indeks_opadajace1  ], [0 2],'r--')

iq_final1=iq_final(indeks_narastajace1:indeks_opadajace1,:);


indeks_narastajace2 = zbocza_narastajace(2);
indeks_opadajace2   = zbocza_opadajace(2);

plot([indeks_narastajace2 indeks_narastajace2], [0 2],'b--')
plot([indeks_opadajace2   indeks_opadajace2  ], [0 2],'b--')

iq_final2=iq_final(indeks_narastajace2:indeks_opadajace2,:);

calibrated_data = iq_final2;

% --MUSIC--
d = 0.5 * lambda;
ant_pos = [
    0,   0;
    d,   0;
    0,   d;
    d,   d 
    ];

[M, num_channels] = size(calibrated_data);
Rxx = (calibrated_data' * calibrated_data) / M;
[U, S, ~] = svd(Rxx);
En = U(:, 2:4); 

theta_range = -27:1:27; 
phi_range   = -20:1:20; 

P_music = zeros(length(phi_range), length(theta_range));

for p_idx = 1:length(phi_range)
    phi = deg2rad(phi_range(p_idx));

    for t_idx = 1:length(theta_range)
        theta = deg2rad(theta_range(t_idx));

        kx = (2*pi/lambda) * sin(theta) * cos(phi);
        ky = (2*pi/lambda) * sin(phi);

        a = exp(1j * (kx * ant_pos(:,1) + ky * ant_pos(:,2)));

        P_music(p_idx, t_idx) = 1 / (a' * (En * En') * a);
    end
end

figure;
radioobraz=(10*log10(abs(P_music)));
radioobraz_norm=radioobraz-(min(radioobraz));
radioobraz_norm=radioobraz_norm/max(radioobraz_norm(:));

img2=imresize(radioobraz_norm,[480 640]);
mapa_kolorow = jet(256); 
img2_indexed = gray2ind(img2, 256);
img2_rgb = ind2rgb(img2_indexed, mapa_kolorow);
img2_hsv = rgb2hsv(img2_rgb);

img1_gray = rgb2gray(img);
img1_gray_double = im2double(img1_gray);

img2_hsv(:,:,3) = img1_gray_double;

img_fused = hsv2rgb(img2_hsv);

imshow(img_fused);

