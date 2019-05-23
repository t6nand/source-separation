function [] = mfcc_plot(coeff, loc, fs)
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Mel Frequency Cepstral Coefficients')
end

