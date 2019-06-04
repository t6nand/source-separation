function [clean_speech_est, smm_soft, validated_psd] = smm(neural_net,...
                                            val_Power,...
                                            do_plot_estimate,...
                                            mixSequencesV) 
    % SMM : This function predicts the neural network response for input
    % and generates a soft mask (in this case a Spectral Magnitude Mask)
    % for clean speech estimation.
    
    % TODO : Use audio_features class for asking parameters like
    % windowlength.
    FFTLength     = 128;
    smm_soft = predict(neural_net,mixSequencesV);
    smm_soft = smm_soft.';
    smm_soft = reshape(smm_soft,1 + FFTLength/2,numel(smm_soft)/(1 + FFTLength/2));
    
    clean_mask   = smm_soft; 
    
    val_Power = val_Power(:,1:size(clean_mask,2));
    
    WindowLength  = 128;
    OverlapLength = 128-1;
    win           = hann(WindowLength,"periodic"); % TODO: use window recommended by Toaha.
    P_estimate_clean = val_Power .* clean_mask;
    P_estimate_clean = [conj(P_estimate_clean(end-1:-1:2,:)) ; P_estimate_clean ];
    clean_speech_est = istft(P_estimate_clean, 'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength,'ConjugateSymmetric',true);
    clean_speech_est = clean_speech_est / max(abs(clean_speech_est));
    
    if do_plot_estimate
        Fs            = 8000;
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
    validated_psd = val_Power;
end