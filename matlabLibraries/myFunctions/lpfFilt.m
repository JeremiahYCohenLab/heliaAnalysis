function y = lpfFilt(x)
%LPFFILT Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 8.4 and the DSP System Toolbox 8.7.
% Generated on: 08-Jul-2015 13:27:53

persistent Hd;

if isempty(Hd)
    
    Fpass = 0.03;  % Passband Frequency
    Fstop = 0.04;  % Stopband Frequency
    Apass = 1;     % Passband Ripple (dB)
    Astop = 60;    % Stopband Attenuation (dB)
    Fs    = 20;    % Sampling Frequency
    
    h = fdesign.lowpass('fp,fst,ap,ast', Fpass, Fstop, Apass, Astop, Fs);
    
    Hd = design(h, 'kaiserwin');
    
    
    
    set(Hd,'PersistentMemory',true);
    
end

% y = filter(Hd,x);
y = filtfilt(Hd.Numerator,1,x);


