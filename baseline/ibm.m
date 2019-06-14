function [clean_speech_hard] = ibm(soft_estimate,...
                                          val_Power,...
                                          smm,...
                                          do_plot,...
                                          clean_speech,...
                                          Fs)
                                                  
    % IBM: Ideal Binary Mask. This function thresholds the soft mask
    % estimated by the DNN. 
    
    % TODO : Add SNR based local criterion thresholding. 
    % TODO : Use audio_features class and ask for params like windowlength.
    WindowLength  = floor(30e-3 * Fs);
    FFTLength     = WindowLength;
    OverlapLength = floor(0.25*WindowLength);
    win           = hann(WindowLength,"periodic");
    hard_mask= (smm >= 0.5); % Thresholding to create IBM
    P_clean_hard = val_Power .* hard_mask;
    P_clean_hard = [conj(P_clean_hard(end-1:-1:2,:)) ; P_clean_hard ];

    clean_speech_hard = istft(P_clean_hard, 'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength,'ConjugateSymmetric',true);
    clean_speech_hard = clean_speech_hard / max(clean_speech_hard);
    
    if do_plot
        figure(2);
        subplot(3,1,1);
        stft(clean_speech(range),Fs,'Window',win,'OverlapLength',64,'FFTLength',FFTLength)
        title("Clean STFT (Actual)")
        subplot(3,1,2)
        stft(soft_estimate(range),Fs,'Window',win,'OverlapLength',64,'FFTLength',FFTLength)
        title("Clean STFT (Estimated - SMM)")
        subplot(3,1,3)
        stft(clean_speech_hard(range),Fs,'Window',win,'OverlapLength',64,'FFTLength',FFTLength)
        title("Clean STFT (Estimated - IBM)");    
    end
end