function [train_data_struct, val_data_struct] = gen_train_data(clean_path, noise_path, samples, val_perc, val_snr, train_snr, save)
    % GEN_TRAIN_DATA: This method generates training and validation data;
    clean_ads = audioDatastore(clean_path);
    noise_ads = audioDatastore(noise_path);
    validation_samples = round(val_perc * samples);
    train_data = double.empty();
    val_data = double.empty();
    for i=1:samples
        skip_add_train = false;
        if mod(i, validation_samples) == 0 && validation_samples ~=0
            [mix_data, clean_data, noise_data] = gen_noisy_audio(clean_path, noise_path, val_snr);
            val_data = [val_data; mix_data clean_data noise_data];
            validation_samples = validation_samples - 1;
            skip_add_train = true;
        end
        if ~skip_add_train
            [mix_data, clean_data, noise_data] = gen_noisy_audio(clean_path, noise_path, train_snr); 
            train_data = [train_data; mix_data clean_data noise_data];
        else
            skip_add_train = false;
        end
    end
    if save
        save("../data/training_seq.mat",train_data_struct);
        save("../data/validation_seq.mat", val_data_struct);
    end
end