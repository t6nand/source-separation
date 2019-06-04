function [] = gen_noisy_audio(clean_path, noise_path, output_path)
    % GEN_NOISY_AUDIO: Thsi method generates and saves the randomly created
    % noisy speech audio files using clean speech and noise interferers.
    for i=1:20
        curr_time = floor(now); % Used for generaing noisy speech audio file names.
        [s, n] = randomize(clean_path, noise_path); % Randomly pick up a speech and noise object.
        clean_aud = s.get_sampled_audio_mono();
        Fs = s.get_sampling_rate();
        noisy_aud = n.get_sampled_audio_mono();
        noisy_mixture = zeros(length(clean_aud), 1); % Base length of mixture should depend on speech and not noise.
        if length(noisy_aud)> length(noisy_mixture)
            noisy_mixture = noisy_mixture + noisy_aud(1:length(noisy_mixture));
        else
            noisy_mixture = noisy_mixture + [noisy_aud; zeros(...
                            length(noisy_mixture) - length(noisy_aud), 1)];
        end
        noisy_mixture = noisy_mixture + clean_aud;
        noisy_mixture = noisy_mixture / max(abs(noisy_mixture)); % Noisy audio generated.
        filename = [num2str(curr_time), '_', num2str(i), '.wav'];
        out = fullfile(output_path, filename);
        audiowrite(out, noisy_mixture, Fs); % Save noisy audio to a file.
    end
end