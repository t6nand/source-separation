function [] = baseline_prediction(clean_path, noise_path, snr)
    speech=audioDatastore(clean_path,'IncludeSubfolders',true,...
        'FileExtensions','.wav'); %Extract the speech dataset
    noise=audioDatastore(noise_path,'IncludeSubfolders',true,'FileExtensions','.wav');...
        %Extract the noise dataset
    for i=1:50
        [mixture, clean, ~] = gen_noisy_audio(speech, noise, snr);

        Fs           = 8000;
        mixture_feat = audio_features(mixture);
        frameLength  = 480;
        N = 1 + frameLength/2;
        val_feature = mixture_feat.get_normalised_features(mixture);
        val_feature = val_feature';
        P_Val_mix0 = mixture_feat.get_stft(mixture);
        seqLen        = 5;
        mixValSequences  = zeros(N,seqLen,1,0);
        seqOverlap       = seqLen;

        loc = 1;
        while loc < size(val_feature,2) - seqLen
            mixValSequences(:,:,:,end+1)  = val_feature(:,loc:loc+seqLen-1);
            loc                           = loc + seqOverlap;
        end

        s = load("dnn_ex_1.mat");
        speech_separation_net = s.speech_separation_net; 

        validation_seq  = reshape(mixValSequences, [1 1 (N * seqLen) size(mixValSequences,4)]);
        % Predict the validation data.
        [soft_estimate, ~, ~] = smm(speech_separation_net, P_Val_mix0, false,...
                                         validation_seq, clean.get_sampled_audio_mono(),  Fs);

         % Evaluate Performance of prediction. 
         [stoi_smm, ~] = check_performance(clean.get_sampled_audio_mono(), ...
                                                  soft_estimate,...
                                                  [],...
                                                  Fs);

         % Display the performance evaluation:
         disp(['IRM based STOI - Soft Mask : ', num2str(stoi_smm)]);

         gen_estimated_files = true;
         if gen_estimated_files
             mixture_out = mixture.get_sampled_audio_mono() / max(abs(mixture.get_sampled_audio_mono()));
             audiowrite(['~/ex3/SNR_0/mix/', num2str(i), '.wav'], mixture_out, Fs);
             clean_out = clean.get_sampled_audio_mono() / max(abs(clean.get_sampled_audio_mono()));
             audiowrite(['~/ex3/SNR_0/clean/',num2str(i),'.wav'], clean_out, Fs);
             audiowrite(['~/ex3/SNR_0/estimated/', num2str(i), '.wav'], soft_estimate, Fs);
         end
    end
end