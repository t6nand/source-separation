function [speech_separation_net, mix_sequences_validation]  = ...
                                cnn1(num_nodes,...
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
    dropoutProb = 0.2;
    numFilters=12;
    % 2. Define a DNN with 5 layers. Input to the network being a matrix
    % of size 1x1xnum_nodes.
    % Each hidden layer having num_nodes neurons and reLU activation and finally
    % an output fully connected layer with final_nodes neurons
    % as a regression layer.
    layers_cnn =[ 
        
    imageInputLayer([1 1 num_nodes])

    convolution2dLayer(3,numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(3,'Stride',2,'Padding','same')

    convolution2dLayer(3,2*numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(3,'Stride',2,'Padding','same')

    convolution2dLayer(3,4*numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(3,'Stride',2,'Padding','same')

    convolution2dLayer(3,4*numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    convolution2dLayer(3,4*numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer

    
    dropoutLayer(dropoutProb)
    fullyConnectedLayer(final_nodes)
    regressionLayer];
%Set the training options
    miniBatchSize = 128;
    
    options_cnn = trainingOptions('adam', ...
    'InitialLearnRate',3e-4, ...
    'MaxEpochs',5, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'ValidationData',{mix_sequences_validation,mask_sequence_validation}, ...
    'ValidationFrequency',floor(size(mix_sequences_training,4)/miniBatchSize), ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'ExecutionEnvironment', 'gpu');
    
    if do_training
%         analyzeNetwork(layers_cnn);
        speech_separation_net = trainNetwork(mix_sequences_training, ...
                                             mask_sequence_training,...
                                             layers_cnn,...
                                             options_cnn);
        save(dnn_name,'speech_separation_net'); 
    else
        s = load(dnn_name);
        speech_separation_net = s.speech_separation_net;
    end
end