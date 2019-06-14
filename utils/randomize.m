function [s,n]= randomize(a,b)    
% Enter the audiodatastore of speech signal in variable a and of noise 
% signal in b
    count1=numel(a.Files); %Count the number of files 
    i1=randi([1,count1],1); %Generate a random integer between 1 and the number...
                          % of files
    count2=numel(b.Files); %Count the number of files 
    i2=randi([1,count2],1); %Generate a random integer between 1 and the number...
                          % of files
    s = wav(a.Files{i1}, [], []);
    n = wav(b.Files{i2}, [], []);
end