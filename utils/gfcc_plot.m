function [] = gfcc_plot(coeff, loc, fs)
% GFCC_PLOT: This function plots GTCC features for visualization.
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Gammatone Cepstral Coefficients')
legend('logE','1','2','3','4','5','6','7','8','9','10','11','12','13','Location','northeastoutside');
end

