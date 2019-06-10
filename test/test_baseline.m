function [] = test_baseline(clean_files, noise_files)
   
    [train_data, validation_data] = gen_train_data(clean_files, noise_files, 100, 0.3, 0, -5);
    
    mixTrain = double.empty();
    clean_sequenced = double.empty();
    noise_sequenced = double.empty();
    for i = 1:size(train_data,1)
        noisy_mixture = train_data(i,1);
        clean_aud = train_data(i,2);
        noise_aud = train_data(i,3);
        mixTrain = [mixTrain; noisy_mixture];
        clean_sequenced = [clean_sequenced; clean_aud];
        noise_sequenced = [noise_sequenced; noise_aud];
    end
    
    train_audio_structure = wav([],mixTrain);
    train_audio_featurs = audio_features(train_audio_structure);
    mixValidate = double.empty();
    val_clean_sequenced = double.empty();
    val_noise_sequenced = double.empty();
    for i = 1:size(validation_data,1)
        val_noisy_mixture = validation_data(i,1);
        val_clean_aud = validation_data(i,2);
        val_noise_aud = validation_data(i,3);
        mixValidate = [mixValidate; val_noisy_mixture];
        val_clean_sequenced = [val_clean_sequenced; val_clean_aud];
        val_noise_sequenced = [val_noise_sequenced; val_noise_aud];
    end
    
    Fs            = 16000;
    WindowLength  = 128;
    FFTLength     = WindowLength;
    OverlapLength = 80;
    win           = hann(WindowLength,"periodic");
    
    P_mix0 = stft(mixTrain,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength);
    P_clean    = abs(stft(clean_sequenced,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));
    P_noise    = abs(stft(noise_sequenced,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));
    
    N      = 1 + FFTLength/2;
    P_mix0 = P_mix0(N-1:end,:);
    P_clean    = P_clean(N-1:end,:);
    P_noise    = P_noise(N-1:end,:);
    
    P_mix = log(abs(P_mix0) + eps);
    MP    = mean(P_mix(:));
    SP    = std(P_mix(:));
    P_mix = (P_mix - MP) / SP;

    P_Val_mix0 = stft(mixValidate,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength);
    P_Val_clean    = abs(stft(val_clean_sequenced,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));
    P_Val_noise    = abs(stft(val_noise_sequenced,Fs,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));

    P_Val_mix0 = P_Val_mix0(N-1:end,:);
    P_Val_clean    = P_Val_clean(N-1:end,:);
    P_Val_noise    = P_Val_noise(N-1:end,:);

    P_Val_mix = log(abs(P_Val_mix0) + eps);
    MP        = mean(P_Val_mix(:));
    SP        = std(P_Val_mix(:));
    P_Val_mix = (P_Val_mix - MP) / SP;

    target_power = P_clean;
    noise_power = P_noise;
    val_target_power = P_Val_clean;
    val_noise_power = P_Val_noise;
    
    maskTrain    = (target_power ./ (target_power + noise_power + eps));
    maskValidate = (val_target_power ./ (val_target_power + val_noise_power + eps));

    seqLen        = 20;
    seqOverlap    = 10;
    mixSequences  = zeros(1 + FFTLength/2,seqLen,1,0);
    maskSequences = zeros(1 + FFTLength/2,seqLen,1,0);

    loc = 1;
    while loc < size(P_mix,2) - seqLen
        mixSequences(:,:,:,end+1)  = P_mix(:,loc:loc+seqLen-1); 
        maskSequences(:,:,:,end+1) = maskTrain(:,loc:loc+seqLen-1); 
        loc                        = loc + seqOverlap;
    end
    
    
    mixValSequences  = zeros(1 + FFTLength/2,seqLen,1,0);
    maskValSequences = zeros(1 + FFTLength/2,seqLen,1,0);
    seqOverlap       = seqLen;

    loc = 1;
    while loc < size(P_Val_mix,2) - seqLen
        mixValSequences(:,:,:,end+1)  = P_Val_mix(:,loc:loc+seqLen-1);
        maskValSequences(:,:,:,end+1) = maskValidate(:,loc:loc+seqLen-1);
        loc                           = loc + seqOverlap;
    end

    % Train the baseline model.
    [speech_separation_net, validation_seq] = dnn_baseline(seqLen, mixSequences, ...
                                         mixValSequences, maskSequences, ...
                                         maskValSequences,...
                                         true,...
                                         FFTLength);
end