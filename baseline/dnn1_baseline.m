function [speech_separation_net, mix_sequences_validation]  = ...
                                dnn1_baseline(num_nodes,...
                                final_nodes,...
                                mixture_sequences, ...
                                mixture_validation_sequences, ... 
                                mask_sequence_training, ...
                                mask_sequence_validation, ...
                                do_training)
    % 1. Reshape data which will be fed to the neural network based on
    % input
    mix_sequences_training  = reshape(mixture_sequences,    [1 1 num_nodes size(mixture_sequences,4)]);
    mix_sequences_validation  = reshape(mixture_validation_sequences, [1 1 num_nodes size(mixture_validation_sequences,4)]);
    mask_sequence_training = reshape(mask_sequence_training,   [1 1 final_nodes size(mask_sequence_training,4)]);
    mask_sequence_validation = reshape(mask_sequence_validation,[1 1 final_nodes size(mask_sequence_validation,4)]);
    % 2. Define a DNN with 5 layers. Input to the network being a matrix
    % of size 1x1xnum_nodes.
    % Each hidden layer having num_nodes neurons and reLU activation and finally
    % an output fully connected layer with final_nodes neurons
    % as a regression layer.
    layers_dnn1 = [...
    imageInputLayer([1 1 num_nodes],"Normalization","None")

    fullyConnectedLayer(num_nodes)
    BiasedSigmoidLayer(6)
    batchNormalizationLayer
    dropoutLayer(0.1)
    
    fullyConnectedLayer(num_nodes)
    BiasedSigmoidLayer(6)
    batchNormalizationLayer
    dropoutLayer(0.1)
    
    fullyConnectedLayer(num_nodes)
    BiasedSigmoidLayer(6)
    batchNormalizationLayer
    dropoutLayer(0.1)
    
    fullyConnectedLayer(num_nodes)
    BiasedSigmoidLayer(6)
    batchNormalizationLayer
    dropoutLayer(0.1)
    
    fullyConnectedLayer(final_nodes)
    BiasedSigmoidLayer(0)
    regressionLayer
    ];

    maxEpochs     = 10; % Number of training epochs
    miniBatchSize = 32; % mini Batch size.
    options_dnn1 = trainingOptions("adam", ...
        "MaxEpochs",maxEpochs, ...
        "MiniBatchSize",miniBatchSize, ...
        "SequenceLength","longest", ...
        "Shuffle","every-epoch",...
        "Verbose",0, ...
        "Plots","training-progress",...
        "ValidationFrequency",floor(size(mix_sequences_training,4)/miniBatchSize),...
        "ValidationData",{mix_sequences_validation,mask_sequence_validation},...
        "LearnRateSchedule","piecewise",...
        "LearnRateDropFactor",0.9, ...
        "LearnRateDropPeriod",1, ...
        "ExecutionEnvironment", 'gpu');
    
    if do_training
        speech_separation_net = trainNetwork(mix_sequences_training, ...
                                             mask_sequence_training,...
                                             layers_dnn1,...
                                             options_dnn1);
        save("dnn_ex_2_snr2.mat",'speech_separation_net'); 
    else
        s = load("dnn_ex_2_snr2.mat");
        speech_separation_net = s.speech_separation_net;
    end
end