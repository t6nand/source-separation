function [mask_seq] = mask_seq_gen(clean_arr, noise_arr)
    mask_seq = double.empty();
    if length(noise_arr) ~= length(clean_arr)
        disp('ERROR!!! size of both clean and noise data arrays are not same');
        return;
    end
    for i=1:length(clean_arr)
        disp(i);
        clean_aud_struct = clean_arr(i,1);
        noise_aud_struct = noise_arr(i,1);
        c_f = audio_features(clean_aud_struct);
        n_f = audio_features(noise_aud_struct);
        [c_power, ~] = c_f.get_stft(clean_aud_struct);
        [n_power, ~] = n_f.get_stft(noise_aud_struct);
        c_power = abs(c_power);
        n_power = abs(n_power);
        mask = (c_power ./ (c_power + n_power() + eps));
        mask = mask.^0.5;
        mask_seq = [mask_seq mask];
    end
end