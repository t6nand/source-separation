function [] = gfcc_plot(coeff, loc, fs)
t = loc./fs;
plot(t, coeff);
xlabel('Time (s)')
title('Gammatone Cepstral Coefficients')
end

