% Parameters
fs=1000; %فرکانس نمونه برداری
A = 1; % دامنه
f = 10; % فرکانس
w = 2*pi*f;
alpha = 0.5; % عمق فرورفتگی
t1 = 0.1; % تایم شروع ولتاژ سگ
t2 = 0.2; % تایم پایان ولتاژ سگ
T = 1/f; % پریود
t3 = 0.4; %تایم شروع ولتاژ swell
t4 = 0.6; %تایم پایان ولتاژ swell
t5 = 0.8;
t6 = 1;
%Time vector
t = 0:1/fs:2; % Adjust fs as needed
%Sag signal
signal = A*(1-alpha*(heaviside(t-t1)-heaviside(t-t2))).*sin(w*t);

% swell_signal
% swell_signal = linspace(2, A, length(t));
% swell_idx = t >= t3 & t <= t4;
% signal(swell_idx) = signal(swell_idx) .* swell_signal(swell_idx);
% intrupt
% pause_idx = t >= t5 & t <= t6;
% signal(pause_idx) = zeros(size(signal(pause_idx)));

% plot(t,signal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Design low-pass filter
[b_lp, a_lp] = butter(3, 100/(fs/2), 'low');
% Design high-pass filter
[b_hp, a_hp] = butter(5, 100/(fs/2), 'high');

% Filter the signal
filtered_low = filter(b_lp, a_lp, signal);
filtered_high = filter(b_hp, a_hp, signal);

% subplot(2,1,1);
% plot(t,filtered_low)
% xlabel('مقدار x');
% ylabel('sin(x)');
% title('lowpass fillter');
% %%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,1,2);
% plot(t,filtered_high)
% xlabel('مقدار x');
% ylabel('cos(x)');
% title('high pass fillter');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hilbert transform for low-pass filtered signal
ht_low = hilbert(filtered_low);
envelope_low = abs(ht_low);

% Smoothing the envelope
smoothed_low = movmean(envelope_low, 0.01*fs);

% Derivative of the smoothed envelope
derivative_low = diff(smoothed_low);

derivative_low_resized = resize(derivative_low, size(smoothed_low));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,1,1);
% plot(t,derivative_low_resized)
% xlabel('مقدار x');
% ylabel('sin(x)');
% title('lowpass fillter');
% %%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,1,2);
% plot(t,filtered_high)
% xlabel('مقدار x');
% ylabel('cos(x)');
% title('high pass fillter');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Zero-mapping based on derivative
xzh = filtered_high .* (abs(derivative_low_resized) < 0.001);
% 
% Hilbert transform and envelope for high-pass filtered signal
ht_high = hilbert(xzh);
envelope_high = abs(ht_high);

% Smoothing the envelope
smoothed_high = movmean(envelope_high, 0.02*fs);

% subplot(2,1,1);
% plot(t,smoothed_high)
% xlabel('مقدار x');
% ylabel('sin(x)');
% title('lowpass fillter');
% %%%%%%%%%%%%%%%%%%%%%%%%%
% subplot(2,1,2);
% plot(t,filtered_high)
% xlabel('مقدار x');
% ylabel('cos(x)');
% title('high pass fillter');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Threshold for harmonics and oscillatory transients
% threshold_high = 0.05; % Adjust as needed

% Classify based on high-frequency envelope
if smoothed_high > threshold_high
    % Further logic to differentiate between harmonics and oscillatory transients based on duration
end

subplot(2,1,1);
plot(t,smoothed_high)
xlabel('مقدار x');
ylabel('sin(x)');
title('lowpass fillter');
%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,2);
plot(t,filtered_high)
xlabel('مقدار x');
ylabel('cos(x)');
title('high pass fillter');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%