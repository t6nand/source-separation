function [noisy_mixture, clean, noise] = gen_noisy_audio(clean_path, noise_path, snr)
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

    noisy_mixture = noisy_aud + clean_aud;
    
    if snr ~= 0
        noisy_mixture = signal_at_snr(noisy_mixture, snr);
    end
    
    noisy_mixture = noisy_mixture / max(abs(noisy_mixture)); % Noisy audio generated.
    clean = clean_aud;
    noise = noisy_aud;
end

function [desired_sig] = signal_at_snr(sig, snr)
    desired_sig = awgn(sig, snr, 'measured');
end