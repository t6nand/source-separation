function [train_data_struct, val_data_struct, test_data_struct, num_test] = ...
                                                    gen_train_data(clean_path,...
                                                    noise_path,...
                                                    samples,...
                                                    val_perc,...
                                                    test_perc,...
                                                    snr,...
                                                    save)
    % GEN_TRAIN_DATA: This method generates training and validation data;
    validation_samples = floor(val_perc * samples);
    test_samples = floor(test_perc * samples);
    num_test = test_samples;
    train_samples = samples - (validation_samples + test_samples);
    train_data_struct = double.empty();
    val_data_struct = double.empty();
    test_data_struct = double.empty();
    skip_add_train = false;
    speech=audioDatastore(clean_path,'IncludeSubfolders',true,...
        'FileExtensions','.wav'); %Extract the speech dataset
    noise=audioDatastore(noise_path,'IncludeSubfolders',true,'FileExtensions','.wav');...
        %Extract the noise dataset
    
    for i=1:validation_samples
            [mix_data_struct, clean_data_struct, noise_data_struct] = gen_noisy_audio(speech, noise, snr);
            val_data_struct = [val_data_struct; mix_data_struct clean_data_struct noise_data_struct];
    end
    
    for i=1:train_samples
            [mix_data_struct, clean_data_struct, noise_data_struct] = gen_noisy_audio(speech, noise, snr); 
            train_data_struct = [train_data_struct; mix_data_struct clean_data_struct noise_data_struct];
    end
    
    for i=1:test_samples
        [mix_data_struct, clean_data_struct, ~] = gen_noisy_audio(speech, noise, snr); 
        test_data_struct = [test_data_struct; mix_data_struct clean_data_struct noise_data_struct];
    end
    if save
        save("../data/training_seq.mat",train_data_struct);
        save("../data/validation_seq.mat", val_data_struct);
        save("../data/test_seq.mat", test_data_struct);
    end
end