function [hv,usableAce] = handValue(hand)
% compute 1:13 indexing for each card: 
values = mod( hand - 1, 13 ) + 1; 
% map face cards (11,12,13)'s to 10's: 
values = min( values, 10 );
sv     = sum(values); 
% Promote soft ace
if (any(values==1)) && (sv<=11)
   sv = sv + 10;
   usableAce = 1; 
else
   usableAce = 0; 
end

hv = sv; 

end