function [stoi_soft, stoi_hard] = check_performance(clean_audio, ...
                                                    soft_estimate, ...
                                                    hard_estimate, ...
                                                    Fs)
    if length(clean_audio) > length(soft_estimate)
        soft_estimate = [soft_estimate; zeros(length(clean_audio) ...
                            - length(soft_estimate), 1)];
    end
    
    if length(clean_audio) > length(hard_estimate)
        hard_estimate = [hard_estimate; zeros(length(clean_audio) ...
                            - length(hard_estimate), 1)];
    end
    
    clean_speech_est_double = double(soft_estimate);
    clean_speech_est_bin_double = double(hard_estimate);
    
    stoi_soft = stoi(clean_audio, clean_speech_est_double, Fs);
    stoi_hard = stoi(clean_audio, clean_speech_est_bin_double, Fs);
end