function [] = simple_spectrogram(sampled_audio, sampling_rate)
    % This function plots the simple spectrogram of a sampled audio
    % vector by calculating STFT of audio.
    window = round(0.05*sampling_rate);
    overlap = round(0.025*sampling_rate);
    spectrogram(sampled_audio, window, overlap, [], sampling_rate, 'yaxis');
    title('Audio Spectrogram');
end
