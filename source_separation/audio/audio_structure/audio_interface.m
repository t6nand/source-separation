classdef audio_interface
   properties
      audio_file_path
      sampled_audio
      sampling_rate
   end
   methods (Abstract)
      % This function returns the sampled audio from the raw audio. 
      get_sampled_audio(obj)
      % This function returns the sampling rate of the audio.
      get_sampling_rate(obj)
   end
end