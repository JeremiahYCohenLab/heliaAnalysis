function [st] = stateFromHand(hand,cardShowing)
%
% Returns the state (a three vector of numbers for a given hand of cards)
% [players current sum, dealar showing card, usable ace] 

% Cards are enoumerated 1:52, such that
% 
%  1:13 => A, 2, 3, ..., 10, J, Q, K      (of C)
% 14:26                                   (of D)
%                                         (of H)
%                                         (of S)
[hv,usableAce] = handValue(hand);

cardShowing = mod( cardShowing - 1, 13 ) + 1; 

st = [ hv, cardShowing, usableAce ]; 

% return;
end