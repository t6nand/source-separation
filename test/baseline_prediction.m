function [] = baseline_prediction(clean_path, noise_path, snr)
    [mixture, clean, ~] = gen_noisy_audio(clean_path, noise_path, snr);
    Fs            = 16000;
    WindowLength  = 128;
    FFTLength     = WindowLength;
    OverlapLength = 80;
    win           = hann(WindowLength,"periodic");
    N      = 1 + FFTLength/2;
    
    P_Val_mix0 = stft(mixture,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength);

    P_Val_mix0 = P_Val_mix0(N-1:end,:);

    P_Val_mix = log(abs(P_Val_mix0) + eps);
    MP        = mean(P_Val_mix(:));
    SP        = std(P_Val_mix(:));
    P_Val_mix = (P_Val_mix - MP) / SP;

    seqLen        = 20;
    mixValSequences  = zeros(1 + FFTLength/2,seqLen,1,0);
    seqOverlap       = seqLen;

    loc = 1;
    while loc < size(P_Val_mix,2) - seqLen
        mixValSequences(:,:,:,end+1)  = P_Val_mix(:,loc:loc+seqLen-1);
        loc                           = loc + seqOverlap;
    end
    
    s = load("speech_separation_net.mat");
    speech_separation_net = s.speech_separation_net; 
    
    validation_seq  = reshape(mixValSequences, [1 1 (1 + FFTLength/2) *... 
                                seqLen size(mixValSequences,4)]);
    % Predict the validation data.
    [soft_estimate, smm_soft, val_psd] = smm(speech_separation_net, P_Val_mix0, false,...
                                     validation_seq);
     % Generate Hard estimates for the predicted data.
     [hard_estimate] = ibm(soft_estimate,...
                                      val_psd, smm_soft, false);
     
     % Evaluate Performance of prediction. 
     [stoi_smm, stoi_ibm] = check_performance(clean, ...
                                              soft_estimate,...
                                              hard_estimate,...
                                              Fs);
     
     % Display the performance evaluation:
     disp(['SMM based STOI - Soft Mask : ', num2str(stoi_smm)]);
     disp(['IBM based STOI - Hard Mask : ', num2str(stoi_ibm)]);
     
     gen_estimated_files = true;
     if gen_estimated_files
         audiowrite('~/noise_mix_train.wav', mixture, 16000);
         audiowrite('~/clean_soft.wav', soft_estimate, 16000);
         audiowrite('~/clean_hard.wav', hard_estimate, 16000);
     end
end