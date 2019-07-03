function [speech_separation_net, mix_sequences_validation]  = ...
                                bilstm(num_nodes,...
                                final_nodes,...
                                mixture_sequences, ...
                                mixture_validation_sequences, ... 
                                mask_sequence_training, ...
                                mask_sequence_validation, ...
                                dnn_name, ...
                                do_training)
    % 1. Reshape data which will be fed to the neural network based on
    % input
    mix_sequences_training  = mixture_sequences;
    mix_sequences_validation  = mixture_validation_sequences;
    % 2. Define a DNN with 5 layers. Input to the network being a matrix
    % of size 1x1xnum_nodes.
    % Each hidden layer having num_nodes neurons and reLU activation and finally
    % an output fully connected layer with final_nodes neurons
    % as a regression layer.
    num_Hidden_nodes=200;
    layers_lstm = [ sequenceInputLayer(num_nodes);
        bilstmLayer(num_Hidden_nodes,"OutputMode","sequence");
        bilstmLayer(num_Hidden_nodes,"OutputMode","sequence");
        fullyConnectedLayer(final_nodes)
        regressionLayer];

    maxEpochs=5;
    miniBatchSize=20; %To be decided keeping the sizes of features in mind to ensure minimum padding
    options_lstm = trainingOptions('adam', ...
        'MaxEpochs',maxEpochs, ...
        'MiniBatchSize',miniBatchSize, ...
        'InitialLearnRate',0.01, ...
        'Shuffle','never', ...
        'Plots','training-progress',...
        'Verbose',0,...
        'ValidationData',{mix_sequences_validation,mask_sequence_validation}, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',0.1, ...
        'LearnRateDropPeriod',20,...
        'SequenceLength','longest',...
        'ExecutionEnvironment','gpu');
    
    if do_training
%         analyzeNetwork(layers_cnn);
        speech_separation_net = trainNetwork(mix_sequences_training, ...
                                             mask_sequence_training,...
                                             layers_lstm,...
                                             options_lstm);
        save(dnn_name,'speech_separation_net'); 
    else
        s = load(dnn_name);
        speech_separation_net = s.speech_separation_net;
    end
end