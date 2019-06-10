classdef wav < audio_interface % This class inherits AUDIO_INTERFACE
    properties 
        num_channels % Number of channels in the audio file.
    end
    methods
        function obj = wav(file_path, audio)
            % WAV CONSTRUCTOR: Constructs the concrete implementation to
            % the AUDIO_INTERFACE superclass. Initialises the 
            % data and enables WAV objects to implement abstract methods of
            % AUDIO_INTERFACE.
            if ~isempty(file_path)
                obj.audio_file_path = file_path;
                [obj.sampled_audio_original, obj.sampling_rate] = ...
                audioread(file_path);
            end
            if ~isempty(audio) && isempty(file_path)
                obj.sampled_audio_original = audio;
            end
            [~, obj.num_channels] = size(obj.sampled_audio_original); 
        end
        
        function wav_read = get_sampled_audio(obj)
            % GET_SAMPLED_AUDIO: Concrete implementation of the abstract
            % method defined in AUDIO_INTERFACE. Returns original sampled
            % audio.
            wav_read = obj.sampled_audio_original;
        end
        
        function mono_channel_audio = get_sampled_audio_mono(obj)
            % GET_SAMPLED_AUDIO_MONO: Concrete implementation of the abstract
            % method defined in AUDIO_INTERFACE. Returns MONO channel audio
            % for the given audio file. Uses LAZY EVALUATION.
            if isempty(obj.sampled_audio_mono)
                if obj.num_channels > 1 % Original Audio is sterephonic
                    mono = double.empty();
                    for ch = 1:obj.num_channels
                        if isempty(mono) % This statement must execute only once when ch = 1
                            mono = obj.sampled_audio_original(:,ch);
                        else
                            mono = mono + ... % Executed depending on number of channels in audio.
                                obj.sampled_audio_original(:,ch);
                        end
                    end
                    mono = mono / obj.num_channels; % Average to get mono channel data
                    mono_channel_audio = mono;
                    obj.sampled_audio_mono = mono_channel_audio;
                else % Audio is already mono channel. Return this audio.
                    mono_channel_audio = obj.get_sampled_audio();
                    obj.sampled_audio_mono = mono_channel_audio;
                end
            end
            mono_channel_audio = obj.sampled_audio_mono;
        end
        
        function sampling_rate = get_sampling_rate(obj)
            % GET_SAMPLING_RATE: Concrete implementation of the abstract
            % method defined in AUDIO_INTERFACE. Returns the sampling rate
            % of the audio.
            sampling_rate = obj.sampling_rate;
        end
        
        function path = get_audio_file_path(obj)
            % GET_AUDIO_FILE_PATH: Concrete implementation of the abstract
            % method defined in AUDIO_INTERFACE. Returns the filepath
            % of the audio.
            path = obj.audio_file_path;
        end
    end
end