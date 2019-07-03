function [] = modelPrediction(mixture, clean, num_test_samples,...
                                                            model,...
                                                            write_loc)
        % MODEL_PREDICTION: Make prediction from the trained model. 
        % 
        % Parameters
        % mixture:          mixture audio structures from the test set.
        % clean:            clean audio structures from the test set.
        % num_test_samples: Number of test samples. (TODO: May not be 
        %                    required and remove later.)
        % model:            Trained model to make predictions.
        % write_loc:        Write location on the local file system, where
        %                   the predicted files can be saved for PESQ 
        %                   calculations.
        
        for i=1:num_test_samples
            mix_aud = mixture(i,1);
            clean_aud = clean(i,1);
            Fs           = 8000;
            mixture_feat = audio_features(mix_aud);
            try
                val_feature = mixture_feat.get_normalised_features(mix_aud);
                val_feature = val_feature';
                P_Val_mix0 = mixture_feat.get_stft(mix_aud);
            catch
                continue;
            end
%             val_seq = [val_feature zeros(size(val_feature, 1), size(P_Val_mix0,2)-size(val_feature,2))];
%             val_seq = reshape(val_seq, 1, 1, size(val_seq,1), size(val_seq,2));
            % Predict the validation data.
            [soft_estimate, ~] = irm(model,...
                                        P_Val_mix0,...
                                        false,...
                                        val_feature,...
                                        clean_aud.get_sampled_audio_mono(),...
                                        mix_aud.get_sampled_audio_mono(),...
                                        Fs);
             % Evaluate Performance of prediction. 
             [stoi_irm, ~] = check_performance(clean_aud.get_sampled_audio_mono(), ...
                                                      soft_estimate,...
                                                      [],...
                                                      Fs);

             % Display the performance evaluation:
             disp(['IRM based STOI - Soft Mask : ', num2str(stoi_irm)]);

             gen_estimated_files = true;
             if gen_estimated_files
                 mixture_out = mix_aud.get_sampled_audio_mono() / max(abs(mix_aud.get_sampled_audio_mono()));
                 audiowrite(['~/experiments/', write_loc, '/mix/', num2str(i), '.wav'], mixture_out, Fs);
                 clean_out = clean_aud.get_sampled_audio_mono() / max(abs(clean_aud.get_sampled_audio_mono()));
                 audiowrite(['~/experiments/', write_loc, '/clean/',num2str(i),'.wav'], clean_out, Fs);
                 audiowrite(['~/experiments/', write_loc, '/estimated/', num2str(i), '.wav'], soft_estimate, Fs);
             end
        end
end