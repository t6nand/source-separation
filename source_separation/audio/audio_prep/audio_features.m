classdef audio_features
    %AUDIO_FEATURES: Centralised class to keep list of audio features
    %   This class will consist of list of audio features relevant 
    %   to the speech identification and separation and the associated 
    %   methods to access these features.
    
    properties (Access = private)
        gfcc_coeffs % Gammatone Cepstral Coefficients.
        gfcc_delta
        gfcc_delta_delta
        gfcc_locs
        gfcc_features_counter % Number of GFCC features.
        mfcc_coeffs % Mel-Frequency Cepstral Coefficients.
        mfcc_delta
        mfcc_delta_delta
        mfcc_locs
        mfcc_features_counter % Number of MFCC features
        pitch_coeffs % Pitch components in audio.
        pitch_locs
        stft_feats % PSD coefficients after STFT.
        stft_freq % Frequency components after STFT
        window_length % Tunable window length for feature extraction.
        overlap_length % Tunable overlap length for feature extraction.
        combined_features % Combined feature vector.
        normalized_features % Normalised feature vector.
        freq_range % Frequency range to operate on. 
    end
    
    methods (Access = private) % Private methods:
        
        function obj = calc_gfcc(obj, au)
            % Function to evaluate GFCC features.
            [obj.gfcc_coeffs,obj.gfcc_delta,obj.gfcc_delta_delta,obj.gfcc_locs] = gtcc( ...
                                      au.get_sampled_audio_mono(), ...
                                      au.get_sampling_rate(), ...
                                      'NumCoeffs',obj.gfcc_features_counter, ...
                                      'FrequencyRange',obj.freq_range, ...
                                      'WindowLength',obj.window_length, ...
                                      'OverlapLength',obj.overlap_length);
        end

        function obj = calc_mfcc(obj, au)
            % Function to evaluate MFCC features.
            [obj.mfcc_coeffs,obj.mfcc_delta,obj.mfcc_delta_delta,obj.mfcc_locs] = mfcc(...
                               au.get_sampled_audio_mono(), ...
                               au.get_sampling_rate(), ...
                               'NumCoeffs',obj.mfcc_features_counter, ...
                               'WindowLength',obj.window_length, ...
                               'OverlapLength',obj.overlap_length);
        end

        function obj = calc_pitch(obj, au)
            % Function to evaluate pitch features.
            [obj.pitch_coeffs, obj.pitch_locs] = pitch( ...
                au.get_sampled_audio_mono(), ...
                au.get_sampling_rate(), ...
                'WindowLength',obj.window_length, ...
                'OverlapLength',obj.overlap_length, ...
                'Range',obj.freq_range, ...
                'MedianFilterLength',3);
        end
        
        function obj = calc_stft(obj, au)
            % Function to evaluate STFT of audio.
            win = hamming(obj.window_length,'Periodic'); % TODO: Analyse different windows.
            FFTLength = obj.window_length;
            [obj.stft_feats, obj.stft_freq] = stft(...
                au.get_sampled_audio_mono(), ...
                'Window', win, ...
                'OverlapLength',obj.overlap_length, ...
                'FFTLength', FFTLength);
        end
        
    end
    
    methods (Access = public) % Public methods & getters:
        
        function this = audio_features(varargin)
            %   AUDIO_FEATURES CONSTRUCTOR: Construct an instance,
            %   using aud object of class audio_interface, initialises
            %   window length and overlap length required to fetch 
            %   many relevant features.
            %   Also implements many fail safe checks to identify type
            %   of objects & arguments being passed to ensure integrity.
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
        
        %   All the access/get methods use lazy evaluation i.e. calculate
        %   and initialise properties only once when called. Once
        %   initialised only return (without re-calculation, thus being 
        %   memory friendly) on subsequent calls.
        
        function [gfcc_coeff, gfcc_delta, gfcc_delta_delta, gfcc_locs] = get_gfcc(obj, aud)
           % GET_GFCC: Getter function to obtain GTCC coefficients and
           % corresponding sample numbers. Uses Lazy Evaluation. 
           if isempty(obj.gfcc_coeffs)
               obj = obj.calc_gfcc(aud);
           end 
           gfcc_coeff = obj.gfcc_coeffs;
           gfcc_delta = obj.gfcc_delta;
           gfcc_delta_delta = obj.gfcc_delta_delta;
           gfcc_locs = obj.gfcc_locs;
        end
        
        function [mfcc_coeff, mfcc_delta, mfcc_delta_delta, mfcc_locs] = get_mfcc(obj, aud)
           % GET_MFCC: Getter function to obtain MFCC coefficients and
           % corresponding sample numbers. Uses Lazy Evaluation.
           if isempty(obj.mfcc_coeffs)
               obj = obj.calc_mfcc(aud);
           end 
           mfcc_coeff = obj.mfcc_coeffs;
           mfcc_delta = obj.mfcc_delta;
           mfcc_delta_delta = obj.mfcc_delta_delta;
           mfcc_locs = obj.mfcc_locs;
        end
        
        function [pitch_coeff, p_locs] = get_pitch(obj, aud)
           % GET_PITCH: Getter function to obtain Pitch information and
           % corresponding sample numbers. Uses Lazy Evaluation. 
           if isempty(obj.pitch_coeffs)
               obj = obj.calc_pitch(aud);
           end 
           pitch_coeff = obj.pitch_coeffs;
           p_locs = obj.pitch_locs;
        end
        
        function [stft, freqs] = get_stft(obj, aud)
           % GET_STFT: Getter function to obtain STFT and
           % corresponding sample frequencis. Uses Lazy Evaluation.
            if isempty(obj.stft_feats)
                obj = obj.calc_stft(aud);
            end
            stft = obj.stft_feats;
            freqs = obj.stft_freq;
        end
        
        function norm_feat = get_normalised_features(obj, aud)
           % GET_NORMALISED_FEATURES: Getter function to obtain normalised
           % feature vector for an audio to ensure dimensionless and 
           % magnitude vice normalised data. NOTE: Input Data normalization
           % should be handled separately before passing on to Learning
           % Machine.
            if isempty(obj.normalized_features)
                [gfcc, gd, gdd, ~] = obj.get_gfcc(aud);
                normalized_gfcc = gfcc / norm(gfcc);
                [mfcc, md, mdd, ~] = obj.get_mfcc(aud);
                normalized_mfcc = mfcc / norm(mfcc);
                [pitch, ~] = obj.get_pitch(aud);
                normalized_pitch = pitch / norm(pitch);
                [pow_sig, ~] = obj.get_stft(aud);
                pow_sig = log(abs(pow_sig)+eps);
                m_stft = mean(pow_sig(:));
                s_stft = std(pow_sig(:));
                normalized_stft = (pow_sig - m_stft)/s_stft;
            end
            norm_feat = [normalized_gfcc; ...
                         normalized_mfcc; ...
                         normalized_pitch; ...
                         normalized_stft];
        end
    end    
end