function [] = pitch_plot(y, freqs, loc)
subplot(2,1,1);
plot(y);
ylabel('Amplitude');
title('Aplitude Plot');

subplot(2,1,2);
plot(loc,freqs);
ylabel('Pitch (Hz)');
xlabel('Sample Number');
title('Pitch Plot');
end

