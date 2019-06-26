function r = synthesis(mixture, mask, gammaFiltbank, winLength, fs, fRange) 

filterOrder = 4;     % filter order
winShift = winLength/2;     % frame shift rate (default is 1/2 frame length)
increment = winLength/winShift;     % special treatment for beginning frames
sigLength = length(mixture);
r = zeros(1,sigLength);

[numChan,numFrame] = size(mask);     % number of channels and time frames

for i = 1:winLength     % calculate a raised cosine window
    coswin(i) = (1 + cos(2*pi*(i-1)/winLength - pi))/2;
end

temp1 = gammaFiltbank(mixture);          % first pass through gammatone filterbank
temp1 = temp1';
phase(1:numChan) = zeros(numChan,1);        % initial phases
erb_b = hz2erb(fRange);       % upper and lower bound of ERB
erb = [erb_b(1):diff(erb_b)/(numChan-1):erb_b(2)];     % ERB segment
cf = erb2hz(erb);       % center frequency array indexed by channel
b = 1.019*24.7*(4.37*cf/1000+1);       % rate of decay or bandwidth

midEarCoeff = zeros(1,numChan);     % frequency-dependent mid-ear coefficients
for c = 1:numChan
    midEarCoeff(c) = 10^((loudness(cf(c))-60)/20);
end

% Generating gammatone impulse responses with middle-ear gain normalization
gL = 1024;      % gammatone filter length or 128 ms for 16 kHz sampling rate
gt = zeros(numChan,gL);
tmp_t = [1:gL]/fs;
for c = 1:numChan
    gain = 10^((loudness(cf(c))-60)/20)/3*(2*pi*b(c)/fs).^4;    % loudness-based gain adjustments
    gt(c,:) = gain*fs^3*tmp_t.^(filterOrder-1).*exp(-2*pi*b(c)*tmp_t).*cos(2*pi*cf(c)*tmp_t+phase(c));
end

d = 2^ceil(log2(sigLength+gL));         % used in second path gammatone filtering
for c = 1:numChan
    temp1(c,:) = fliplr(temp1(c,:))/midEarCoeff(c);    % time reverse filter output & normalize out mid-ear coefficients
    temp2 = fftfilt(gt(c,:),temp1(c,:));    % second pass filtering via FFTFILT
    temp1(c,:) = fliplr(temp2(1:sigLength))/midEarCoeff(c);    % time reverse again & normalize out mid-ear coefficients
    
    weight = zeros(1, sigLength);       % calculate weighting
    for m = 1:numFrame-increment/2+1      % mask value can be binary or rational           
        startpoint = (m-1)*winShift;
        if m <= increment/2                % shorter frame lengths for beginning frames or zero padding
            weight(1:startpoint+winLength/2) = weight(1:startpoint+winLength/2) + mask(c,m)*coswin(winLength/2-startpoint+1:end);
        else 
            startIdx = startpoint-winLength/2+1;
            if (startpoint+winLength/2) < sigLength
                endIdx = startpoint+winLength/2;
                weight(startIdx:endIdx) = weight(startIdx:endIdx) + mask(c,m)*coswin;
            else
                endIdx = sigLength;
                coswin_new = coswin(:,1:size(weight(startIdx:endIdx), 2));
                weight(startIdx:endIdx) = weight(startIdx:endIdx) + mask(c,m)*coswin_new;
            end
        end
    end
    
    r = r + temp1(c,:).*weight;
end