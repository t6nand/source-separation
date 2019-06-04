function [] = test_baseline(clean_speech_dir, noise_dir)
     
    clean_speech_path = audioDatastore(clean_speech_dir);
    noise_path = audioDatastore(noise_dir);
    
    
    clean_audio_obj_1 = wav(clean_speech_path.Files{1,1});
    noise_audio_obj_1 = wav(noise_path.Files{1,1});

    clean_audio_1 = clean_audio_obj_1.get_sampled_audio_mono();
    noise_audio_1 = noise_audio_obj_1.get_sampled_audio_mono();
    
    L = min(length(clean_audio_1),length(noise_audio_1));  
    clean_audio_1   = clean_audio_1(1:L);
    noise_audio_1 = noise_audio_1(1:L);
    
    clean_audio_obj_2 = wav(clean_speech_path.Files{2,1});
    noise_audio_obj_2 = wav(noise_path.Files{2,1});
    
    clean_audio_2 = clean_audio_obj_2.get_sampled_audio_mono();
    noise_audio_2 = noise_audio_obj_2.get_sampled_audio_mono();
    
    L = min(length(clean_audio_2),length(noise_audio_2));  
    clean_audio_2   = clean_audio_2(1:L);
    noise_audio_2 = noise_audio_2(1:L);
    
    clean_audio_obj_3 = wav(clean_speech_path.Files{3,1});
    noise_audio_obj_3 = wav(noise_path.Files{3,1});

    clean_audio_3 = clean_audio_obj_3.get_sampled_audio_mono();
    noise_audio_3 = noise_audio_obj_3.get_sampled_audio_mono();
    
    L = min(length(clean_audio_3),length(noise_audio_3));  
    clean_audio_3   = clean_audio_3(1:L);
    noise_audio_3 = noise_audio_3(1:L);
    
    clean_audio_validate_obj = wav(clean_speech_path.Files{50,1});
    noise_audio_validate_obj = wav(noise_path.Files{42,1});

    clean_audio_validate = clean_audio_validate_obj.get_sampled_audio_mono();
    noise_audio_validate = noise_audio_validate_obj.get_sampled_audio_mono();
    
    L1 = min(length(clean_audio_validate),length(noise_audio_validate));  
    clean_audio_validate   = clean_audio_validate(1:L1);
    noise_audio_validate = noise_audio_validate(1:L1);

    clean_audio_1   = clean_audio_1/norm(clean_audio_1);
    noise_audio_1 = noise_audio_1/norm(noise_audio_1);
    ampAdj = max(abs([clean_audio_1;noise_audio_1]));
    clean_audio_1   = clean_audio_1/ampAdj;
    noise_audio_1 = noise_audio_1/ampAdj;
    
    clean_audio_2   = clean_audio_2/norm(clean_audio_2);
    noise_audio_2 = noise_audio_2/norm(noise_audio_2);
    ampAdj = max(abs([clean_audio_2;noise_audio_2]));
    clean_audio_2 = clean_audio_2/ampAdj;
    noise_audio_2 = noise_audio_2/ampAdj;
    
    clean_audio_3 = clean_audio_3/norm(clean_audio_3);
    noise_audio_3 = noise_audio_3/norm(noise_audio_3);
    ampAdj = max(abs([clean_audio_3;noise_audio_3]));
    clean_audio_3 = clean_audio_3/ampAdj;
    noise_audio_3 = noise_audio_3/ampAdj;

    clean_audio_validate   = clean_audio_validate/norm(clean_audio_validate);
    noise_audio_validate = noise_audio_validate/norm(noise_audio_validate);
    ampAdj               = max(abs([clean_audio_validate;noise_audio_validate]));
    clean_audio_validate   = clean_audio_validate/ampAdj;
    noise_audio_validate = noise_audio_validate/ampAdj;

    clean_sequenced = [clean_audio_1; clean_audio_2; clean_audio_3];
    noise_sequenced = [noise_audio_1; noise_audio_2; noise_audio_3];
    mixTrain = clean_sequenced + noise_sequenced;
    mixTrain = mixTrain / max(mixTrain);

    mixValidate = clean_audio_validate + noise_audio_validate;
    mixValidate = mixValidate / max(mixValidate);

    WindowLength  = 128;
    FFTLength     = 128;
    OverlapLength = 128-1;
    Fs            = 8000;
    win           = hann(WindowLength,"periodic");

    P_mix0 = stft(mixTrain,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength);
    P_clean    = abs(stft(clean_sequenced,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));
    P_noise    = abs(stft(noise_sequenced,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));

    N      = 1 + FFTLength/2;
    P_mix0 = P_mix0(N-1:end,:);
    P_clean    = P_clean(N-1:end,:);
    P_noise    = P_noise(N-1:end,:);

    P_mix = log(abs(P_mix0) + eps);
    MP    = mean(P_mix(:));
    SP    = std(P_mix(:));
    P_mix = (P_mix - MP) / SP;

    P_Val_mix0 = stft(mixValidate,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength);
    P_Val_clean    = abs(stft(clean_audio_validate,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));
    P_Val_noise    = abs(stft(noise_audio_validate,'Window',win,'OverlapLength',OverlapLength,'FFTLength',FFTLength));

    P_Val_mix0 = P_Val_mix0(N-1:end,:);
    P_Val_clean    = P_Val_clean(N-1:end,:);
    P_Val_noise    = P_Val_noise(N-1:end,:);

    P_Val_mix = log(abs(P_Val_mix0) + eps);
    MP        = mean(P_Val_mix(:));
    SP        = std(P_Val_mix(:));
    P_Val_mix = (P_Val_mix - MP) / SP;

    maskTrain    = P_clean ./ (P_clean + P_noise + eps);
    maskValidate = P_Val_clean ./ (P_Val_clean+ P_Val_noise + eps);

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
    % Predict the validation data.
    [soft_estimate, smm_soft, val_psd] = smm(speech_separation_net, P_Val_mix0, false,...
                                    validation_seq);
     
    % Generate Hard estimates for the predicted data.
     [hard_estimate] = ibm(clean_audio_validate, soft_estimate,...
                                     val_psd, smm_soft, false);
    
    % Evaluate Performance of prediction. 
    [stoi_smm, stoi_ibm] = check_performance(clean_audio_validate, ...
                                             soft_estimate,...
                                             hard_estimate,...
                                             clean_audio_validate_obj.get_sampling_rate());
    
    % Display the performance evaluation:
    disp(['SMM based STOI - Soft Mask : ', num2str(stoi_smm)]);
    disp(['IBM based STOI - Hard Mask : ', num2str(stoi_ibm)]);
    
    gen_estimated_files = false;
    
    if gen_estimated_files
        audiowrite('~/noise_mix_train.wav', mixValidate, 16000);
        audiowrite('~/home/tapansha/clean_soft.wav', soft_estimate, 16000);
        audiowrite('~/home/tapansha/clean_hard.wav', hard_estimate, 16000);
    end
end