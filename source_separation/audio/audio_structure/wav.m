classdef wav < audio_interface
    properties 
    end
    methods
        function obj = wav(file_path)
            obj.audio_file_path = file_path;
            [obj.sampled_audio, obj.sampling_rate] = audioread(file_path);
        end
        function wav_read = get_sampled_audio(obj)
            wav_read = obj.sampled_audio;
        end
        function sampling_rate = get_sampling_rate(obj)
            sampling_rate = obj.sampling_rate;
        end
    end
end