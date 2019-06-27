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
        mfcc_coeffs % Mel-Frequency Cepstral Coefficients.
        mfcc_delta
        mfcc_delta_delta
        mfcc_locs
        pitch_coeffs % Pitch components in audio.
        pitch_locs
        spect %Spectrogram
        stft_feats % PSD coefficients after STFT.
        stft_freq % Frequency components after STFT
        coch % Cochleagram
        window_length % Tunable window length for feature extraction.
        overlap_length % Tunable overlap length for feature extraction.
        normalized_features % Normalised feature vector.
        freq_range % Frequency range to operate on. 
    end
    
    methods (Static)
      function out = setgetFilterBank(obj)
         persistent gamma_filt_bank;
         if nargin
            disp("Creating Gammatone filter bank");
            gamma_filt_bank = gammatoneFilterBank(obj.freq_range, 64, 8000);
         end
         out = gamma_filt_bank;
      end
    end
   
    methods (Access = private) % Private methods:
        
        function obj = calc_gfcc(obj, au)
            % Function to evaluate GFCC features.
            [obj.gfcc_coeffs,obj.gfcc_delta,obj.gfcc_delta_delta,obj.gfcc_locs] = gtcc( ...
                                      au.get_sampled_audio_mono(), ...
                                      au.get_sampling_rate(), ...
                                      'FrequencyRange',obj.freq_range, ...
                                      'WindowLength',obj.window_length, ...
                                      'OverlapLength',obj.overlap_length);
        end
        
        
        function obj=calc_spectrogram(obj,au)
            %Function to get spectrogram of a sequence
            win = hann(obj.window_length,'Periodic');
            FFTLength=obj.window_length;
            obj.spect=spectrogram(au.get_sampled_audio_mono(), ...
                win,obj.overlap_length, FFTLength);
        end
                
            
        function obj = calc_mfcc(obj, au)
            % Function to evaluate MFCC features.
            [obj.mfcc_coeffs,obj.mfcc_delta,obj.mfcc_delta_delta,obj.mfcc_locs] = mfcc(...
                               au.get_sampled_audio_mono(), ...
                               au.get_sampling_rate(), ...
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
            win = hann(obj.window_length,'Periodic'); % TODO: Analyse different windows.
            FFTLength = obj.window_length;
            [obj.stft_feats, obj.stft_freq] = stft(...
                au.get_sampled_audio_mono(), ...
                'Window', win, ...
                'OverlapLength',obj.overlap_length, ...
                'FFTLength', FFTLength);
            N      = 1 + FFTLength/2;
            obj.stft_feats = obj.stft_feats(N-1:end,:);
        end
        
        function obj = calc_cochleagram(obj, au)
            % Function to evaluate cochleagram of audio.
            if isempty(audio_features.setgetFilterBank())
                audio_features.setgetFilterBank(obj);
            end
            if isempty(audio_features.setgetFilterBank())
                gtgf = audio_features.setgetFilterBank(obj);
            else
                gtfb = audio_features.setgetFilterBank();
            end
            aud_res = gtfb(au.get_sampled_audio_mono());
            obj.coch = cochleagram(aud_res', obj.window_length);
        end
        
        function obj = calc_normalised_features(obj,aud)
           % GET_NORMALISED_FEATURES: Getter function to obtain normalised
           % feature vector for an audio to ensure dimensionless and 
           % magnitude vice normalised data. NOTE: Input Data normalization
           % should be handled separately before passing on to Learning
           % Machine.
%             if isempty(obj.gfcc_coeffs)
%                 obj = obj.calc_gfcc(aud);
%             end
%             if isempty(obj.mfcc_coeffs)
%                 obj = obj.calc_mfcc(aud);
%             end
%            if isempty(obj.stft_feats)
%                obj = obj.calc_stft(aud);
%            end
            
            if isempty(obj.spect)
                obj = obj.calc_spectrogram(aud);
            end

%             if isempty(obj.pitch_coeffs)
%                 obj = obj.calc_pitch(aud);
%             end
%             
%             norm_pitch = [obj.pitch_coeffs zeros(size(obj.pitch_coeffs, 1), 83)];
%            norm_stft = log(abs(obj.stft_feats) + eps);
%            norm_stft = norm_stft';
            norm_spectrogram = log(abs(obj.spect) + eps);
            norm_spectrogram = norm_spectrogram';

%             if isempty(obj.coch)
%                 obj = obj.calc_cochleagram(aud);
%             end
%            obj.normalized_features = [norm_stft];
            obj.normalized_features = [norm_spectrogram];
            
            m = mean(obj.normalized_features(:));
            s = std(obj.normalized_features(:));
            obj.normalized_features = (obj.normalized_features - m) ./ s;
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
                    au = varargin{1};
                    obj_class = class(au);
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
                            this.window_length = floor(30e-3 * au.get_sampling_rate());
                            this.overlap_length = floor(0.25*this.window_length);
                            this.freq_range = [50 4000];
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
        function spectro = get_spectrogram(obj, aud)
           % GET_STFT: Getter function to obtain Spectrogram. Uses Lazy Evaluation.
            if isempty(obj.spect)
                obj = obj.calc_spectrogram(aud);
            end
            spectro = obj.spect;
            
        end

        
        function norm_feat = get_normalised_features(obj, aud)
           % GET_NORMALISED_FEATURES: Getter function to obtain normalised
           % feature vector for an audio to ensure dimensionless and 
           % magnitude vice normalised data. 
            if isempty(obj.normalized_features)
                obj = obj.calc_normalised_features(aud);
            end
            norm_feat = obj.normalized_features;
        end
        
        function coch = get_cochleagram(obj, aud)
           % GET_COCHLEAGRAM: Getter function to obtain cochleagram
           % of an audio.
            if isempty(obj.coch)
                obj = obj.calc_cochleagram(aud);
            end
            coch = obj.coch;
        end
    end    
end
