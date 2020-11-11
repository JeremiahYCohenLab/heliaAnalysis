grid(6,9) = [];
MZ = mz_fn(0); 
[sideII,sideJJ] = size(MZ);
% the maximal number of states: 
nStates = sideII*sideJJ; 
A(2:4,3) = 1; 
A(1:3,8) = 1; 
A(5,6) = 1;
nStates = sideII*sideJJ; 
% q(nStates, 4) = 0;
q = -3*ones(nStates,nActions);
seen_states = [];
epsilon = 0.1;
start = grid(1,4);
goal = grid(6, 9);
barrier = grid(3, 1:8);
new_barrier = grid(3,2:9);
act_taken   = zeros(nStates,nActions); 
Model_ns = zeros(nStates,nActions); % <- next state we will obtain 
Model_nr = zeros(nStates,nActions); % <- next reward we will obtain 
ets = []; ts=0; 
numFinishes = 0;


if( PLOT_STEPS )
  figure; imagesc( zeros(sideII,sideJJ) ); colorbar; hold on; 
  plot( s_start(2), s_start(1), 'x', 'MarkerSize', 10, 'MarkerFaceColor', 'k' ); 
  plot( s_end(2), s_end(1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k' ); 
end



numStates = 1000;
compTime = 3000;
b = 2;
n = 10;
VgreedyS0 = 
pTerm = 0.1;
tTeminal = false;
% actions = 2;
tMatx(numStates,3) = [];
actions = ['N', 'E', 'S', 'W'];
act_len = length(actions);



for i = 1: compTime
    if randn >= epsilon
        for s = 1:numStates
            a(s) = find(max(q(s,:)));
        end
        for s = 1:numStates?
            if s == 1?
                
            else a(s) = find(max(q(s)),2);
                if a(s) ,:))== 2
                    s(s+1,2) =  randi(b);
                    s(s+1,1) = 0;
                elseif a(s) == 1
                    s(s+1,1) =  randi(b);
                    s(s+1,2) = 0;
                end
                tMatx(s,1) = s(s(s+1) ~= 0);
                tMatx(s,2) = a(s);
                mu = 0;
                sigm = 1;
                tMatx(s,3) = randn;
                q(s,a(s)) = tMatx(s,3) + q(s+1,a(s));
    rew = randn;
    state(i) = 
    else
        tTerminal = true;
        
        