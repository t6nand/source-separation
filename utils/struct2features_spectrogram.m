function [normalised_feature, mask_seq] = struct2features_spectrogram(mixture_struct, ...
                                                              clean_struct,...
                                                              noise_struct)
    if length(noise_struct) ~= length(clean_struct)
        disp('ERROR!!! size of both clean and noise data arrays are not same');
        return;
    end
    normalised_feature = zeros(100,500);
    mask_seq = double.empty();
    new_col = 1;
    row_idx = 0;
    for i=1:length(mixture_struct)
        a_f = audio_features(mixture_struct(i,1));
        c_f = audio_features(clean_struct(i,1));
        n_f = audio_features(noise_struct(i,1));
        try
            c_power = c_f.get_spectrogram(clean_struct(i,1));
            n_power = n_f.get_spectrogram(noise_struct(i,1));
            norm_feats = a_f.get_normalised_features(mixture_struct(i,1));
        catch
            continue;
         end
        mask = (c_power ./ (c_power + n_power + eps));
        mask = mask.^0.5;
        mask2d = [real(mask) imag(mask)];
        mask_seq = [mask_seq mask2d];
        norm_feats = norm_feats';
        norm_feats_padded = [norm_feats zeros(size(norm_feats,1), size(mask2d,2) - size(norm_feats,2))];
        cur_col = size(norm_feats_padded,2);
        row_idx = size(norm_feats_padded,1);
        normalised_feature(1:row_idx, new_col:(new_col-1)+cur_col) = norm_feats_padded;
        new_col = (new_col - 1) + cur_col + 1;
    end
    normalised_feature = normalised_feature(1:row_idx, 1:new_col-1);
end