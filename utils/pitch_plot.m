function [] = pitch_plot(y, freqs, loc)
% PITCH_PLOT: This function plots pitch components in an audio along with
% aplitude plot.
subplot(2,1,1);
plot(y);
ylabel('Amplitude');
title('Amplitude Plot');

subplot(2,1,2);
plot(loc,freqs);
ylabel('Pitch (Hz)');
xlabel('Sample Number');
title('Pitch Plot');
end

