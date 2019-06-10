function DNN(miniBatchSize,epochs)
    % regression neural 
    layers = [
    imageInputLayer([246,5])

    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(1024)
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(64)
    regressionLayer
    ];

    maxEpochs     = 3;
    miniBatchSize = 64;
    
    options = trainingOptions("adam", ...
        "MaxEpochs",maxEpochs, ...
        "InitialLearnRate",1e-4,...
        "MiniBatchSize",miniBatchSize, ...
        "Shuffle","every-epoch", ...
        "Plots","training-progress", ...
        "Verbose",true, ...
        "ValidationPatience",Inf,...
        "ValidationFrequency",30,...
        "LearnRateSchedule","piecewise",...
        "LearnRateDropFactor",0.9,...
        "LearnRateDropPeriod",1,...
        "ValidationData",{cv_datas,cv_labels})

    doTraining = true;
    if doTraining
        CocktailPartyNet = trainNetwork(mixSequencesT,maskSequencesT,layers,options);
    else
        s = load("CocktailPartyNet.mat");
        CocktailPartyNet = s.CocktailPartyNet;
    end
    [DNN, train_information] = trainNetwork(train_datas,train_targets,layers,options);

    output = predict(DNN , test_datas);

    [test_perf, test_perf_str] = Performance_IRM(output,test_label,DFI,small_mix_cell, small_speech_cell,0);

    save([save_path DNN_name '.mat'],'DNN','options','train_information','output'); 
end
