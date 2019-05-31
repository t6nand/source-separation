classdef wav < audio_interface
    properties 
        num_channels
    end
    methods
        function obj = wav(file_path)
            obj.audio_file_path = file_path;
            [obj.sampled_audio_original, obj.sampling_rate] = audioread(file_path);
            [~, obj.num_channels] = size(obj.sampled_audio_original); 
        end
        
        function wav_read = get_sampled_audio(obj)
            wav_read = obj.sampled_audio_original;
        end
        
        function mono_channel_audio = get_sampled_audio_mono(obj)
            if isempty(obj.sampled_audio_mono)
                if obj.num_channels > 1
                    mono = double.empty();
                    for ch = 1:obj.num_channels
                        if isempty(mono)
                            mono = obj.sampled_audio_original(:,ch);
                        else
                            mono = mono + ...
                                obj.sampled_audio_original(:,ch);
                        end
                    end
                    mono = mono / obj.num_channels;
                    mono_channel_audio = mono;
                    obj.sampled_audio_mono = mono_channel_audio;
                else 
                    mono_channel_audio = obj.get_sampled_audio();
                    obj.sampled_audio_mono = mono_channel_audio;
                end
            else
                mono_channel_audio = obj.sampled_audio_mono;
            end
        end
        
        function sampling_rate = get_sampling_rate(obj)
            sampling_rate = obj.sampling_rate;
        end
    end
end