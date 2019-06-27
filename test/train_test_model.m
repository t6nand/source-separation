function [] = train_test_model(clean_files, noise_files, numSamples, val_perc, test_perc, snr, save_model, model_type, model_id)
    % TRAIN_MODEL: Use this function to train model and use the trained
    % model for making predictions.
    % 
    % Parameters:
    % clean_files: Location of the clean speech files on local file system.
    % noise_files: Location of the noise speech files on local file system.
    % numSamples:  Number of samples to train on.
    % val_perc:    Validation percentage i.e. proportion of validation
    %              samples from the numSamples.
    % test_perc:   Test percentage i.e. proportion of test
    %              samples from the numSamples on which prediction is made
    %              post training.
    % snr:         SNR at which clean speech is mixed with the interfering
    %              noise.
    % save_model:  Flag true/false to save trained model on the local file
    %              system.
    % model_type:  Type of model. 1 for DNN, 2 for CNN.
    % model_id:    ID of models to train on as available in the
    %              source_separation/model foldder.
    
    [train_data_struct, validation_data_struct, test_data_struct, test_samples] = ...
            gen_train_data(clean_files, noise_files, numSamples, val_perc, test_perc, snr, save_model);
    
    train = true;
    dnn_name = "dnn_ex_1.mat";
    
    if train
        % 1. Load training data.
        train_data_mix = train_data_struct(:,1);
        train_data_clean = train_data_struct(:,2);
        train_data_noise = train_data_struct(:,3);

        % 2. Load Validation data.
        validation_data_mix = validation_data_struct(:,1);
        validation_data_clean = validation_data_struct(:,2);
        validation_data_noise = validation_data_struct(:,3);

        % 3. Extract training features & estimate training mask.
        tic;[train_data_features, maskTrain] = struct2features_spectrogram(train_data_mix,...
                                                                train_data_clean,...
                                                                train_data_noise);toc;
        % 4. Extract validation features & estimate validation mask.
        tic;[validation_data_features, maskValidation] = struct2features_spectrogram(validation_data_mix,...
                                                    validation_data_clean,...
                                                    validation_data_noise);toc;
        
        % 5. Reshape Training and validation data to be processed.
        mixSequences  = reshape(train_data_features, 1, 1, size(train_data_features,1), size(train_data_features, 2));
        maskSequences = reshape(maskTrain, 1, 1, size(maskTrain,1), size(maskTrain, 2));
        mixValSequences = reshape(validation_data_features, 1, 1, size(validation_data_features,1), size(validation_data_features, 2));
        maskValSequences = reshape(maskValidation, 1, 1, size(maskValidation,1), size(maskValidation, 2));
        inNeurons = size(mixSequences, 3);
        outNeurons = size(maskSequences, 3);

%         disp([size(train_data_features), size(maskTrain)]);
%         disp([inNeurons, outNeurons]);
%         disp([size(mixSequences), size(maskSequences)]);
%         return;

        % 6. Finally, train the model.
        switch model_type
            case 1
                switch model_id
                    case 1
                        [speech_separation_net, ~] = dnn(inNeurons,...
                                                             outNeurons, ...
                                                             mixSequences, ...
                                                             mixValSequences, ...
                                                             maskSequences, ...
                                                             maskValSequences,...
                                                             dnn_name,...
                                                             true);
                    case 2
                        [speech_separation_net, ~] = dnn1(inNeurons,...
                                                             outNeurons, ...
                                                             mixSequences, ...
                                                             mixValSequences, ...
                                                             maskSequences, ...
                                                             maskValSequences,...
                                                             dnn_name,...
                                                             true);
                    otherwise
                        disp("No such DNN model to train!!!");
                        return;
                end
            case 2
                switch model_id
                    case 1
                        [speech_separation_net, ~] = cnn(inNeurons,...
                                                             outNeurons, ...
                                                             mixSequences, ...
                                                             mixValSequences, ...
                                                             maskSequences, ...
                                                             maskValSequences,...
                                                             dnn_name,...
                                                             true);
                    case 2
                        [speech_separation_net, ~] = cnn1(inNeurons,...
                                                             outNeurons, ...
                                                             mixSequences, ...
                                                             mixValSequences, ...
                                                             maskSequences, ...
                                                             maskValSequences,...
                                                             dnn_name,...
                                                             true);
                    otherwise
                        disp("No such CNN model to train!!!");
                        return;
                end
            otherwise
                disp("1 for DNN 2 for CNN .....!!!! Kindly check.");
                return;
        end
    else
        s = load(dnn_name);
        speech_separation_net = s.speech_separation_net;
    end
    
    % 7. Test the model.
     % Load Testing data.
    test_data_mix = test_data_struct(:,1);
    test_data_clean = test_data_struct(:,2);
    write_loc = 'ex10/GFCC/SNR2';
    modelPrediction(test_data_mix, test_data_clean, test_samples, speech_separation_net, write_loc);
end