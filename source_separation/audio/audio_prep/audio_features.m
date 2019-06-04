classdef audio_features
    %AUDIO_FEATURES: Centralised class to keep list of audio features
    %   This class will consist of list of audio features relevant 
    %   to the problem statement and the associated methods to access 
    %   these features.
    
    properties (Access = private)
        gfcc_coeffs
        gfcc_locs
        gfcc_features_counter
        mfcc_coeffs
        mfcc_locs
        mfcc_features_counter
        pitch_coeffs
        pitch_locs
        stft_feats
        stft_freq
        window_length
        overlap_length
        combined_features
        normalized_features
        freq_range
    end
    
    methods (Access = private)
        function obj = calc_gfcc(obj, au)
            [obj.gfcc_coeffs,~,~,obj.gfcc_locs] = gtcc( ...
                                      au.get_sampled_audio_mono(), ...
                                      au.get_sampling_rate(), ...
                                      'NumCoeffs',obj.gfcc_features_counter, ...
                                      'FrequencyRange',obj.freq_range, ...
                                      'WindowLength',obj.window_length, ...
                                      'OverlapLength',obj.overlap_length);
        end

        function obj = calc_mfcc(obj, au)
            [obj.mfcc_coeffs,~,~,obj.mfcc_locs] = mfcc(...
                               au.get_sampled_audio_mono(), ...
                               au.get_sampling_rate(), ...
                               'NumCoeffs',obj.mfcc_features_counter, ...
                               'WindowLength',obj.window_length, ...
                               'OverlapLength',obj.overlap_length);
        end

        function obj = calc_pitch(obj, au)
            [obj.pitch_coeffs, obj.pitch_locs] = pitch( ...
                au.get_sampled_audio_mono(), ...
                au.get_sampling_rate(), ...
                'WindowLength',obj.window_length, ...
                'OverlapLength',obj.overlap_length, ...
                'Range',obj.freq_range, ...
                'MedianFilterLength',3);
        end
        
        function obj = calc_stft(obj, au)
            win = hamming(obj.window_length,'Periodic');
            FFTLength = obj.window_length;
            [obj.stft_feats, obj.stft_freq] = stft(...
                au.get_sampled_audio_mono(), ...
                'Window', win, ...
                'OverlapLength',obj.overlap_length, ...
                'FFTLength', FFTLength);
        end
        
    end
    
    methods (Access = public)
        function this = audio_features(varargin)
            %AUDIO_FEATURES Construct an instance of this class
            %   using aud object of class audio_interface, initialises
            %   window length and overlap length required to fetch 
            %   many relevant features.
            %   Also implements many fail safe checks to identify type
            %   of objects & arguments being passed to ensure flow of 
            %   control as per the requirements.
            %
            %   Example usage: feat_obj = audio_features(wav_audio_obj); 
            
            switch nargin
                case 0
                    aud_fet_ex = MException('Incorrect_Initialization', ...
                                        ' No object provided to feature class');
                    throw(aud_fet_ex);
                case 1
                    aud = varargin{1};
                    obj_class = class(aud);
                    obj_superclass = superclasses(obj_class);
                    if numel(obj_superclass)  > 1 
                        aud_fet_ex = MException('Incorrect_Initialization', ...
                         ' There must be a single audio superclass');
                        throw(aud_fet_ex);
                    else 
                       is_instance_of_audio_interface = strcmp(...
                                                obj_superclass{1}, ...
                                                'audio_interface');
                       if is_instance_of_audio_interface
                            this.window_length = round(0.05*aud.get_sampling_rate());
                            this.overlap_length = round(0.025*aud.get_sampling_rate());
                            this.gfcc_features_counter = 25;
                            this.mfcc_features_counter = 25;
                            this.freq_range = [50 8000];
                       else
                            aud_fet_ex = MException('Incorrect_Initialization', ...
                            ' Incorrect object structure passed for feature extraction');
                            throw(aud_fet_ex);
                       end
                    end
                otherwise
                    aud_fet_ex = MException('Incorrect_Initialization', ...
                            ' Incorrect arguments passed for feature extraction');
                    throw(aud_fet_ex);
            end
        end
        
        %   All the access/get methods use lazy evaluation i.e. fetch
        %   features when requested and only one time.
        
        function [gfcc_coeff, gfcc_locs] = get_gfcc(obj, aud)
           if isempty(obj.gfcc_coeffs)
               obj = obj.calc_gfcc(aud);
           end 
           gfcc_coeff = obj.gfcc_coeffs;
           gfcc_locs = obj.gfcc_locs;
        end
        
        function [mfcc_coeff, mfcc_locs] = get_mfcc(obj, aud)
           if isempty(obj.mfcc_coeffs)
               obj = obj.calc_mfcc(aud);
           end 
           mfcc_coeff = obj.mfcc_coeffs;
           mfcc_locs = obj.mfcc_locs;
        end
        
        function [pitch_coeff, p_locs] = get_pitch(obj, aud)
           if isempty(obj.pitch_coeffs)
               obj = obj.calc_pitch(aud);
           end 
           pitch_coeff = obj.pitch_coeffs;
           p_locs = obj.pitch_locs;
        end
        
        function [stft, freqs] = get_stft(obj, aud)
            if isempty(obj.stft_feats)
                obj = obj.calc_stft(aud);
            end
            stft = obj.stft_feats;
            freqs = obj.stft_freq;
        end
        
        function norm_feat = get_normalised_features(obj, aud)
            if isempty(obj.normalized_features)
                [gfcc, ~] = obj.get_gfcc(aud);
                normalized_gfcc = gfcc / norm(gfcc);
                [mfcc, ~] = obj.get_mfcc(aud);
                normalized_mfcc = mfcc / norm(mfcc);
                [pitch, ~] = obj.get_pitch(aud);
                normalized_pitch = pitch / norm(pitch);
                [stft, ~] = obj.get_stft(aud);
                normalized_stft = stft / norm(stft);
            end
            norm_feat = [normalized_gfcc; ...
                         normalized_mfcc; ...
                         normalized_pitch; ...
                         normalized_stft];
        end
    end    
end