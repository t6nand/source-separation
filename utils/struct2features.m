function [normalised_feature] = struct2features(audio_struct)
    normalised_feature = zeros(10000,500);
    new_row = 1;
    col_idx = 0;
    for i=1:length(audio_struct)
        a_f = audio_features(audio_struct(i,1));
        norm_feats = a_f.get_normalised_features(audio_struct(i,1));
        cur_row = size(norm_feats,1);
        col_idx = size(norm_feats,2);
        normalised_feature(new_row:(new_row-1)+cur_row, 1:col_idx) = norm_feats;
        new_row = (new_row - 1) + cur_row + 1;
    end
    normalised_feature = normalised_feature(1:new_row-1,1:col_idx);
end