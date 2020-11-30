function [root, sep] = currComputer()

if ismac
    root = '/Users/heliaseifikar/Documents/heliaData/';
  %  root = '/Volumes/bbari1/';
    sep = '/';
elseif ispc
%     root = 'X:\';
    root = 'C:\Users\Helia\Documents\heliaData\ompa\';
    sep = '\';
end