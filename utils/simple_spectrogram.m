function [] = simple_spectrogram(sampled_audio, sampling_rate)
    window = round(0.05*sampling_rate());
    overlap = round(0.025*sampling_rate());
    % This function plots the simple spectrogram of a sampled audio
    % vector by calculating STFT of audio.
     spectrogram(sampled_audio, window, overlap, [], sampling_rate, 'yaxis');
     title('Audio Spectrogram');
end
