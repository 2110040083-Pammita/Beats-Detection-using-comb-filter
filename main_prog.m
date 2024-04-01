clc
clear all
close all
% Load the audio file
x = audioread('ad2.wav');
audio=x(:,1);
% Define parameters
window_size = 1024; % Size of the analysis window
hop_size = 512;    % Hop size between analysis windows
threshold = 0.5;   % Adjust this threshold for beat detection sensitivity

% Initialize an array to store the comb-filtered signal
comb_filtered_signal = zeros(size(audio));

% Process the audio with a comb filter
for t = window_size+1:hop_size:length(audio)-window_size
    % Extract the current window
    window = audio(t - window_size/2 : t + window_size/2);
    
    % Calculate the autocorrelation of the window
    autocorrelation = xcorr(window, 'coeff');
    
    % Find the peak in the autocorrelation
    [~, locs] = findpeaks(autocorrelation);
    
    % Estimate the tempo (beats per minute)
    if length(locs) >= 2
        tempo = 60 / (locs(2) - locs(1)) * (hop_size / 44100);
        
        % Check if the tempo is within the beat range (adjust this range as needed)
        if tempo >= 0.0050 && tempo <= 10
            % Mark the beats in the comb-filtered signal
            comb_filtered_signal(t - hop_size/2 : t + hop_size/2) = 1;
        end
    end
end

% Apply a threshold to the comb-filtered signal to detect beats
beat_detection = comb_filtered_signal > threshold;

% Plot the original audio and beat detection result
time = (1:length(audio)) / 44100;
subplot(2,1,1);
plot(time, audio);
title('Original Audio');
xlabel('Time (s)');
subplot(2,1,2);
plot(time, beat_detection);
title('Beat Detection');
xlabel('Time (s)');
% Play the audio with beats marked
sound(audio .* beat_detection, 44100);

