function [] = test_baseline(clean_files, noise_files)
    
    [train_data_struct, validation_data_struct] = gen_train_data(clean_files, noise_files, 500, 0.15, 0, 0, false);
    
    % 1. Load training data.
    train_data_mix = train_data_struct(:,1);
    train_data_clean = train_data_struct(:,2);
    train_data_noise = train_data_struct(:,3);
    
    % 2. Load Validation data.
    validation_data_mix = validation_data_struct(:,1);
    validation_data_clean = validation_data_struct(:,2);
    validation_data_noise = validation_data_struct(:,3);
    
    % 3. Extract training features & estimate training mask.
    [train_data_features, maskTrain] = struct2features(train_data_mix,...
                                                            train_data_clean,...
                                                            train_data_noise);
    train_data_features = train_data_features';
    
    % 4. Extract validation features & estimate validation mask.
    [validation_data_features, maskValidation] = struct2features(validation_data_mix,...
                                                validation_data_clean,...
                                                validation_data_noise);
    validation_data_features = validation_data_features';
    
    % 5. Pre process data.
    framesize     = 480;
    maskFrameSize = 480;
    seqLen        = 5;
    seqOverlap    = 2;
    
    N      = 1 + framesize/2;
    M      = 1 + maskFrameSize/2;
    mixSequences  = zeros(N,seqLen,1,0);
    maskSequences = zeros(M,seqLen,1,0);

    loc = 1;
    while loc < size(train_data_features,2) - seqLen
        mixSequences(:,:,:,end+1)  = train_data_features(:,loc:loc+seqLen-1); 
        loc                        = loc + seqOverlap;
    end
    
    loc = 1;
    while loc < size(maskTrain,2) - seqLen
        maskSequences(:,:,:,end+1) = maskTrain(:,loc:loc+seqLen-1);
        loc                        = loc + seqOverlap;
    end
    
    mixValSequences  = zeros(N,seqLen,1,0);
    maskValSequences = zeros(M,seqLen,1,0);
    
    seqOverlap       = seqLen;
    
    loc = 1;
    while loc < size(validation_data_features,2) - seqLen
        mixValSequences(:,:,:,end+1)  = validation_data_features(:,loc:loc+seqLen-1);
        loc                           = loc + seqOverlap;
    end
    
    loc = 1;
    while loc < size(maskValidation,2) - seqLen
        maskValSequences(:,:,:,end+1)  = maskValidation(:,loc:loc+seqLen-1);
        loc                            = loc + seqOverlap;
    end
%     disp(size(mixSequences));
%     disp(size(mixValSequences));
%     disp(size(maskSequences));
%     disp(size(maskValSequences));
%     return;
    % 6. Finally, train the baseline model.
    [speech_separation_net, validation_seq] = dnn_baseline(N*seqLen,...
                                         M*seqLen, ...
                                         mixSequences, ...
                                         mixValSequences, maskSequences, ...
                                         maskValSequences,...
                                         true);
end