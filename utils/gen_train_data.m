function [train_data_struct, val_data_struct] = gen_train_data(clean_path, noise_path, samples, val_perc, val_snr, train_snr, save)
    % GEN_TRAIN_DATA: This method generates training and validation data;
    validation_samples = floor(val_perc * samples);
    train_data_struct = double.empty();
    val_data_struct = double.empty();
    skip_add_train = false;
    speech=audioDatastore(clean_path,'IncludeSubfolders',true,...
        'FileExtensions','.wav'); %Extract the speech dataset
    noise=audioDatastore(noise_path,'IncludeSubfolders',true,'FileExtensions','.wav');...
        %Extract the noise dataset
    for i=1:samples
        if mod(i, validation_samples) == 0 && validation_samples ~=0
            [mix_data_struct, clean_data_struct, noise_data_struct] = gen_noisy_audio(speech, noise, val_snr);
            val_data_struct = [val_data_struct; mix_data_struct clean_data_struct noise_data_struct];
            validation_samples = validation_samples - 1;
            skip_add_train = true;
        end
        if ~skip_add_train
            [mix_data_struct, clean_data_struct, noise_data_struct] = gen_noisy_audio(speech, noise, train_snr); 
            train_data_struct = [train_data_struct; mix_data_struct clean_data_struct noise_data_struct];
        else
            skip_add_train = false;
        end
    end
    if save
        save("../data/training_seq.mat",train_data_struct);
        save("../data/validation_seq.mat", val_data_struct);
    end
end