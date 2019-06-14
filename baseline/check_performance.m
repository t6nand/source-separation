function [stoi_soft, stoi_hard] = check_performance(clean_audio, ...
                                                    soft_estimate, ...
                                                    hard_estimate, ...
                                                    Fs)
    % CHECK_PERFORMANCE This function evaluates the performance of clean
    % speech estimated by the baseline DNN. It uses short-time
    % objective intelligibility (STOI) score for evaluation.
    
    if ~isempty(soft_estimate)
        if length(clean_audio) > length(soft_estimate) % DNN estimation may be lossy
            soft_estimate = [soft_estimate; zeros(length(clean_audio) ...
                                - length(soft_estimate), 1)];
        end
        clean_speech_est_double = double(soft_estimate); % To enforce double precision
        stoi_soft = stoi(clean_audio, clean_speech_est_double, Fs);
    else
        stoi_soft = [];
    end
    if ~isempty(hard_estimate)
        if length(clean_audio) > length(hard_estimate) % DNN estimation may be lossy
            hard_estimate = [hard_estimate; zeros(length(clean_audio) ...
                                - length(hard_estimate), 1)];
        end
        clean_speech_est_bin_double = double(hard_estimate); % hard_estimate is a logical matrix.
        stoi_hard = stoi(clean_audio, clean_speech_est_bin_double, Fs);
    else
        stoi_hard = [];
    end
end