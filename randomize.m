function [s,Fs,n]= randomize(a,b)    
% Enter the directory of speech signal in variable a and of noise signal in
% b
    speech=audioDatastore(a,'IncludeSubfolders',true,...
        'FileExtensions','.wav'); %Extract the speech dataset
    noise=audioDatastore(b,'IncludeSubfolders',true,'FileExtensions','.wav');...
        %Extract the noise dataset
    count1=numel(speech.Files); %Count the number of files 
    i1=randi([1,count1],1); %Generate a random integer between 1 and the number...
                          % of files
    count2=numel(noise.Files); %Count the number of files 
    i2=randi([1,count2],1); %Generate a random integer between 1 and the number...
                          % of files

    [s, Fs]= audioread(speech.Files{i1});
    [n]=audioread(noise.Files{i2});