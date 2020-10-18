function [rew] = determineReward(phv,dhv)

if( phv>21 ) % player went bust
  rew = -1; 
  return; 
end
if( dhv>21 ) % dealer went bust
  rew = +1; 
  return; 
end
if( phv==dhv ) % a tie
  rew = 0; 
  return;
end
if( phv>dhv ) % the larger hand wins
  rew = +1; 
else
  rew = -1; 
end
end