function [root, sep] = currComputer_operantMatching()

if ismac
    root = 'heliaseifikar/Documents/heliaData/';
  %  root = '/Volumes/bbari1/';
    sep = '/';
elseif ispc
%     root = 'X:\';
    root = 'C:\Users\Helia\Documents\heliaData\ompa\';
    sep = '\';
end