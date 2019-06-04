function [] = gfcc_plot(coeff, loc, fs)
% GFCC_PLOT: This function plots GTCC features for visualization.
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Gammatone Cepstral Coefficients')
end

