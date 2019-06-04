function [a,b,mix]=normalize_mix(x,y)
    %Normalize a&b
    a=x/norm(x);
    b=y/norm(y);
    ampAdj  = max(abs([a;b]));
    %Adjust amplitudes such that they lie between 0 and 1
    a = a/ampAdj;
    b = b/ampAdj;
    %Adjust the size for mixing
    if (size(a)>size(b))
        a=a(1:size(b));
    else
        b=b(1:size(a));
    end
    mix     = a + b; %Mix the sound
    mix     = mix ./ max(abs(mix)); %Normalize the amp between 0 and 1
end