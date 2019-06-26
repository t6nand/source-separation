function [clean_speech_est, smm_soft] = irm(neural_net,...
                                            val_Power,...
                                            do_plot_estimate,...
                                            mixSequencesV,...
                                            clean_audio_validate,...
                                            mix_audio,...
                                            Fs) 
    % SMM : This function predicts the neural network response for input
    % and generates a soft mask (in this case a Spectral Magnitude Mask)
    % for clean speech estimation.
    
    % TODO : Use audio_features class for asking parameters like
    % windowlength.
    FFTLength     = floor(30e-3 * Fs);
    OverlapLength    = floor(0.25*FFTLength);
    smm_soft = predict(neural_net,mixSequencesV);
    smm_soft = smm_soft.';
%     smm_soft = reshape(smm_soft, 1+FFTLength/2,numel(smm_soft)/1+FFTLength/2);
    
    desired_len = 2*size(val_Power,2);
    smm_soft = [smm_soft ones(size(smm_soft,1), desired_len-size(smm_soft,2))];
    clean_mask   = complex(smm_soft(:,1:size(val_Power,2)), smm_soft(:,size(val_Power,2) + 1:end)); 
    P_estimate_clean = val_Power.* clean_mask;
    WindowLength  = FFTLength;
    win           = hann(WindowLength,"periodic");
    P_estimate_clean = [conj(P_estimate_clean(end-1:-1:2,:)) ; P_estimate_clean ];
    clean_speech_est = istft(P_estimate_clean, 'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength,'ConjugateSymmetric',true);
%     gtfb = audio_features.setgetFilterBank();
%     clean_speech_est = synthesis(mix_audio, smm_soft, gtfb, FFTLength, Fs, [50 4000]);
    clean_speech_est = clean_speech_est / max(abs(clean_speech_est));
    if do_plot_estimate
        range = (numel(win):numel(clean_speech_est)-numel(win));
        t     = range * (1/Fs);
        figure(1);
        subplot(2,1,1);
        plot(t,clean_audio_validate(range));
        title("Original clean Speech");
        xlabel("Time (s)");
        grid on;
        subplot(2,1,2);
        plot(t,clean_speech_est(range));
        xlabel("Time (s)");
        title("Estimated clean Speech (SSM)");
        grid on;
    end
end