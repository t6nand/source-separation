function [normalised_feature, mask_seq] = struct2features(mixture_struct, ...
                                                              clean_struct,...
                                                              noise_struct)
    if length(noise_struct) ~= length(clean_struct)
        disp('ERROR!!! size of both clean and noise data arrays are not same');
        return;
    end
    normalised_feature = zeros(10000,500);
    mask_seq = double.empty();
    new_row = 1;
    col_idx = 0;
    for i=1:length(mixture_struct)
        a_f = audio_features(mixture_struct(i,1));
        c_f = audio_features(clean_struct(i,1));
        n_f = audio_features(noise_struct(i,1));
        [c_power, ~] = c_f.get_stft(clean_struct(i,1));
        [n_power, ~] = n_f.get_stft(noise_struct(i,1));
        norm_feats = a_f.get_normalised_features(mixture_struct(i,1));
        c_power = abs(c_power);
        c_power = c_power.^2;
        n_power = abs(n_power);
        n_power = n_power.^2;
        mask = (c_power ./ (c_power + n_power + eps));
        mask = mask.^0.5;
        mask_seq = [mask_seq mask];
        cur_row = size(norm_feats,1);
        col_idx = size(norm_feats,2);
        normalised_feature(new_row:(new_row-1)+cur_row, 1:col_idx) = norm_feats;
        new_row = (new_row - 1) + cur_row + 1;
    end
    normalised_feature = normalised_feature(1:new_row-1,1:col_idx);
end