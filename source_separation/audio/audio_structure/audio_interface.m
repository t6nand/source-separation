classdef audio_interface
   properties (Access = protected)
      audio_file_path % Disk Path to audio file
      sampled_audio_original % Original sampled audio
      sampled_audio_mono % Mono channel sampled audio.
      sampling_rate % Audio's sampling rate.
   end
   methods (Abstract)
      % This function returns the sampled audio from the raw audio. 
      get_sampled_audio(obj)
      % This function returns the mono channel sampled audio from the raw audio.
      get_sampled_audio_mono(obj)
      % This function returns the sampling rate of the audio.
      get_sampling_rate(obj)
      % This function returns the file path on local system.
      get_audio_file_path(obj)
   end
end