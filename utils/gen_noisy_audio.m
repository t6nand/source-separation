function [noisy_mixture_struct, clean_struct, noise_struct] = gen_noisy_audio(clean_ads, noise_ads, snr)
    % GEN_NOISY_AUDIO: Thsi method generates and saves the randomly created
    % noisy speech audio files using clean speech and noise interferers.
    [s, n] = randomize(clean_path, noise_path); % Randomly pick up a speech and noise object.
    clean_aud = s.get_sampled_audio_mono();
    noisy_aud = n.get_sampled_audio_mono();
    
    if n.get_sampling_rate() ~= s.get_sampling_rate()
        [P,Q] = rat(s.get_sampling_rate()/n.get_sampling_rate());
        noisy_aud = resample(n.get_sampled_audio_mono(), P, Q);
    end
    
    L = min(length(clean_aud),length(noisy_aud));
    clean_aud = clean_aud(1:L);
    noisy_aud = noisy_aud(1:L);
    clean_aud = clean_aud/norm(clean_aud);
    noisy_aud = noisy_aud/norm(noisy_aud);
    ampAdj = max(abs([clean_aud; noisy_aud]));
    clean_aud = clean_aud/ampAdj;
    noisy_aud = noisy_aud/ampAdj;

    if snr ~= 0
        noisy_mixture = signal_at_snr(clean_aud, noisy_aud, snr);
    else
        noisy_mixture = noisy_aud + clean_aud;
    end
    
    clean = clean_aud;
    noise = noisy_aud;
end

function [desired_sig] = signal_at_snr(sig, noise, SNR)
    signal_power = (1/length(sig))*sum(sig.*sig);
    noise_variance = signal_power / ( 10^(SNR/10) ); 
    desired_sig = sig + sqrt(noise_variance)/std(noise)*noise(1:length(sig));
end