function [] = simple_spectrogram(sampled_audio, sampling_rate)
    % This function plots the simple spectrogram of a sampled audio
    % vector by calculating STFT of audio.
     spectrogram(sampled_audio, 512, [], [], sampling_rate, 'yaxis');
     title('Audio Spectrogram');
end
