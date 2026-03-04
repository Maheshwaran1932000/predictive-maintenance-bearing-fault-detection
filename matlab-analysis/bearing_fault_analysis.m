% Load your sensor data 

data = readtable('Scope Project Final.csv');
sensorData = table2array(data(7:end, 2)); % Adjust the range for longer data

% Clean sensorData
sensorData = sensorData(~isnan(sensorData) & isfinite(sensorData));
if ~isnumeric(sensorData)
    sensorData = str2double(sensorData);
end

% Convert acceleration from g to m/s² 
sensorData = sensorData * 9.81; 

Fs = 10000; % Sampling frequency (10 kHz)
t = (0:length(sensorData)-1)/Fs;

% Plot raw signal (first few seconds for visualization)
figure;
plot(t, sensorData);
xlabel('Time (s)');
ylabel('Acceleration (m/s²)');
title('Raw Signal: Sensor Data');
xlim([0 10]); % Show first 10 seconds for clarity

% Compute and plot FFT (for the entire dataset)
N = length(sensorData);
Y = fft(sensorData);
P2 = abs(Y) / N;
P1 = P2(1:N/2); % Ensure correct length
f = (0:(N/2)-1) * (Fs/N);  % Frequency axis (0 to 5 kHz)

% Calculate bearing fault frequencies (KP004 bearing)
Nb = 9; % Number of balls
fr = 25; % Rotational frequency in Hz (1500 rpm / 60)
Bd = 7.94; % Ball diameter in mm
Pd = 33.5; % Pitch diameter in mm 
theta = 0; % Contact angle (0 for deep groove ball bearings)

BPFO = (Nb * fr / 2) * (1 - (Bd / Pd) * cosd(theta)); % Ball Pass Frequency Outer Race
BPFI = (Nb * fr / 2) * (1 + (Bd / Pd) * cosd(theta)); % Ball Pass Frequency Inner Race
BSF = (Pd / (2 * Bd)) * (1 - (Bd / Pd * cosd(theta))^2); % Ball Spin Frequency
FTF = (fr / 2) * (1 - (Bd / Pd) * cosd(theta)); % Fundamental Train Frequency

fprintf('BPFO: %.2f Hz\n', BPFO);
fprintf('BPFI: %.2f Hz\n', BPFI);
fprintf('BSF: %.2f Hz\n', BSF);
fprintf('FTF: %.2f Hz\n', FTF);

% Plot FFT with fault frequencies (0 to 5 kHz)
figure;
plot(f, P1);
hold on;
xline(BPFO, 'r', 'LineWidth', 1.5, 'DisplayName', 'BPFO');
xline(BPFI, 'g', 'LineWidth', 1.5, 'DisplayName', 'BPFI');
xline(BSF, 'b', 'LineWidth', 1.5, 'DisplayName', 'BSF');
xline(FTF, 'm', 'LineWidth', 1.5, 'DisplayName', 'FTF');
title('FFT with Bearing Fault Frequencies');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
xlim([0 5000]); % Extend frequency range to 5 kHz
legend;
grid on;

%Number of points for the FFT
points=2^15
delta_f=Fs/points

% Compute and plot spectrogram (waterfall chart)
window = points*2; % Window size for spectrogram
noverlap = points; % Overlap between windows
nfft = points*2; % Number of FFT points

% Compute spectrogram
%omega is PI
%[s, omega, time] = spectrogram(sensorData,window, noverlap, nfft, Fs, 'yaxis');
[s, omega, time] = spectrogram(sensorData, window, noverlap, nfft);
% Draw the frequency axis in rad
figure(100)
waterfall(time, omega, 20*log10(abs(s)))
axis xy;
xlabel('Time (s)');
ylabel('Normalized frequency (rad)');
zlabel('Magnitude (dB)')
title('Waterfall Chart');

% Calculate the frequencies
Ts=1/Fs;
frequency = omega/(2*pi*Ts);

% Draw the frequency axis in Hz
figure(101)
%The Magnitude in db must be calculated wit 20*log10(abs(s)) it is an
%engergy signal and not the power
waterfall(time, frequency, 20*log10(abs(s)))
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
zlabel('Magnitude (dB)')
title('Waterfall Chart');

% Plot spectrogram with extended frequency range
figure(200);
imagesc(time, omega, 20*log10(abs(s))); % Convert to dB scale for better visualization
axis xy; % Ensure the frequency axis is correctly oriented
colorbar;
xlabel('Time (s)');
ylabel('Normalized frequency (rad)');
title('Spectrogram (Waterfall Chart)');
%ylim([5 5000]); % Show frequencies above 5 Hz and up to 5 kHz
%set(gca, 'YScale', 'log'); 

% Plot spectrogram with frequency axis
figure(201);
imagesc(time, frequency, 20*log10(abs(s))); % Convert to dB scale for better visualization
axis xy; % Ensure the frequency axis is correctly oriented
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram (Waterfall Chart)');
%ylim([5 5000]); % Show frequencies above 5 Hz and up to 5 kHz
colorbar;
%set(gca, 'YScale', 'log'); 

% Compute and plot envelope spectrum
[pEnv, fEnv, xEnv, tEnv] = envspectrum(sensorData, Fs);

% Plot envelope spectrum with fault frequencies (0 to 5 kHz)
figure;
plot(fEnv, pEnv);
hold on;
xline(BPFO, 'r', 'LineWidth', 1.5, 'DisplayName', 'BPFO');
xline(BPFI, 'g', 'LineWidth', 1.5, 'DisplayName', 'BPFI');
xline(BSF, 'b', 'LineWidth', 1.5, 'DisplayName', 'BSF');
xline(FTF, 'm', 'LineWidth', 1.5, 'DisplayName', 'FTF');
xlim([0 5000]); % Extend frequency range to 5 kHz
xlabel('Frequency (Hz)');
ylabel('Peak Amplitude');
title('Envelope Spectrum with Bearing Fault Frequencies');
legend;
grid on;

% Compute kurtosis
kurt = kurtosis(sensorData);

% Plot raw signal with kurtosis
figure;
plot(tEnv, sensorData);
xlabel('Time (s)');
ylabel('Acceleration (m/s²)');
title(['Raw Signal: Sensor Data, kurtosis = ' num2str(kurt)]);
xlim([0 10]); % Show first 10 seconds for clarity

% Compute and plot kurtogram
level = 9;
figure;
kurtogram(sensorData, Fs, level);

% Compute and plot spectral kurtosis
wc = 128;
figure;
pkurtosis(sensorData, Fs, wc);

% Compute and plot spectrogram and spectral kurtosis
helperSpectrogramAndSpectralKurtosis(sensorData, Fs, level);

% Design bandpass filter based on kurtogram
[~, ~, ~, fc, ~, BW] = kurtogram(sensorData, Fs, level);
bpf = designfilt('bandpassfir', 'FilterOrder', 200, 'CutoffFrequency1', fc-BW/2, ...
    'CutoffFrequency2', fc+BW/2, 'SampleRate', Fs);
sensorDataBpf = filter(bpf, sensorData);

% Compute and plot envelope spectrum of bandpass filtered signal
[pEnvBpf, fEnvBpf, xEnvBpf, tEnvBpf] = envspectrum(sensorDataBpf, Fs);

figure;
subplot(2, 1, 1);
plot(t, sensorData, tEnv, xEnv);
ylabel('Acceleration (m/s²)');
title(['Raw Signal: Sensor Data, kurtosis = ', num2str(kurt)]);
xlim([0 10]); % Show first 10 seconds for clarity
legend('Signal', 'Envelope');

subplot(2, 1, 2);
kurtBpf = kurtosis(sensorDataBpf);
plot(t, sensorDataBpf, tEnvBpf, xEnvBpf);
ylabel('Acceleration (m/s²)');
xlim([0 10]); % Show first 10 seconds for clarity
xlabel('Time (s)');
title(['Bandpass Filtered Signal: Sensor Data, kurtosis = ', num2str(kurtBpf)]);
figure;
plot(fEnvBpf, pEnvBpf);
xlim([0 5000]); % Extend frequency range to 5 kHz
xlabel('Frequency (Hz)');
ylabel('Peak Amplitude');
title('Envelope Spectrum of Bandpass Filtered Signal: Sensor Data');
legend('Envelope Spectrum');
