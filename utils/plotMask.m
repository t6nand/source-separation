function plotMask(P,hopLength,F,fs)

plotopts.isFsnormalized = false;
if nargin == 5
    plotopts.cblbl = '';
end

plotopts.freqlocation = 'yaxis';
t = (0:size(P,2)-1) *hopLength / fs;
signalwavelet.internal.convenienceplot.plotTFR(t,F, P,plotopts);