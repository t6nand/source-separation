function [] = mfcc_plot(coeff, loc, fs)
% MFCC_PLOT: This function plots MFCC features for visualization.
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Mel Frequency Cepstral Coefficients')
end

