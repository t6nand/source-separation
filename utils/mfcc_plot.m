function [] = mfcc_plot(coeff, loc, fs)
% MFCC_PLOT: This function plots MFCC features for visualization.
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Mel Frequency Cepstral Coefficients')
legend('logE','1','2','3','4','5','6','7','8','9','10','11','12','13','Location','northeastoutside');
end

