function [Q,ets,cr] = ex_9_4_dynaQplus(alpha,epsilon,gamma,kappa,nPlanningSteps,mz_fn,s_start,s_end,MAX_N_STEPS)

s_start = [ 6, 4 ]; 
s_end   = [ 1, 9 ]; 
alpha = 1e-1; 
% the probability of a random action (non-greedy): 
epsilon = 0.1; 
% the discount factor: 
gamma = 0.95;

% gamma,kappa,nPlanningSteps,mz_fn,s_start,s_end,MAX_N_STEPS)

PLOT_STEPS = 0; 

% function A = makeMazeChapt8(ts,section)

% if section == 1 %ts is the timestep telling us if the maze has changed.  
%     A = zeros(6,9); 
%     A(2:4,3) = 1; %maze one
%     A(1:3,8) = 1; 
%     A(5,6) = 1;
% elseif section ==2
%     if( ts<1000 )
%         A(4,1:8) = 1;  % the first maze
%     else
%         A(4,2:9) = 1;  % the second maze
%     end
% elseif section ==3
%     if( ts<3000 )
%         A(4,2:9) = 1; % the first maze
%     else
%         A(4,2:8) = 1; % the second maze
%     end
% end
% 
% %end
% 
% MZ =A;

MZ = mz_fn(0); % our initial maze
[sideII,sideJJ] = size(MZ);

% the maximal number of states: 
nStates = sideII*sideJJ; 
nActions = 4;

% Q = zeros(nStates,nActions); ??
q = -3*ones(nStates,nActions);

%for planing we need to store the sequence of states experienced. (store
%their indices) and store the sequence of actions in each state
seen_states = [];
act_taken   = zeros(nStates,nActions); %0 action not taken, 1 taken


%model of the environment
Model_ns = zeros(nStates,nActions); % <- next state we will obtain 
Model_nr = zeros(nStates,nActions); % <- next reward we will ob

if( PLOT_STEPS )
  figure; imagesc( zeros(sideII,sideJJ) ); colorbar; hold on; 
  plot( s_start(2), s_start(1), 'x', 'MarkerSize', 10, 'MarkerFaceColor', 'k' ); 
  plot( s_end(2), s_end(1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'k' ); 
end

%from githb code
MAX_N_STEPS=30; 
%MAX_N_STEPS=1e3;
MAX_N_STEPS=1e4;
MAX_N_STEPS=1e5;
%MAX_N_STEPS=1e6;
%MAX_N_STEPS=10e6;

% the number of steps to do in planning: 
%nPlanningSteps = 0; 
nPlanningSteps = 5; 
%nPlanningSteps = 50; 
nPSV = [ 0, 5, 50 ]; 

% a factor relating how important revisiting old states is, relative to 
% the past recieved reward coming from these states/action pairs ... 
%kappa = 0.02; 
kappa = 2/sqrt(MAX_N_STEPS); 
%%


% keep track of how many timestep we take per episode:
ets = []; ts=0; 

% for exploration: we need to keep track of the number of timesteps elapsed
% between ??
% each "real" evaluation of this state and action pair:
%nts_since_visit = +Inf*ones(nStates,nActions); 
%nts_since_visit = +10*ones(nStates,nActions);     % <- a very optimistic reward ... to encourage exploration ... 
nts_since_visit = zeros(nStates,nActions);     % <- don't visit a state until we have visited it at least ONCE ... 

%initialize the starting state
st = s_start; sti = sub2ind( [sideII,sideJJ], st(1), st(2) ); 

for tsi = 1:MAX_N_STEPS  %?
  tic; 
%   if( tsi==1 ) 
%     fprintf('working on step %d...\n',tsi);
%   else
%     fprintf('working on step %d (ptt=%10.6f secs)...\n',tsi, toc); tic; 
%   end
  if( 0 && mod(tsi,100)==0 ) 
    fprintf('working on step %d (ptt=%10.6f secs)...\n',tsi, toc); tic; 
  end
  %--
  % Action section:
  %--
  % use an epsilon greedy policy derived FROM Q but modified by how long it has been since we have visited 
  % this state/action pair in a REAL interaction with the environment ... (this is similar to dynaQplus)
  actSelQ = Q + kappa*sqrt( nts_since_visit );
  [dum,at] = max(actSelQ(sti,:));  % at \in [1,2,3,4]=[up,down,right,left]
  if( rand<epsilon )               % we explore ... with a random action 
    tmp=randperm(nActions); at=tmp(1); 
  end

  % for planning: keep track of the states/action seen 
  if( ~ismember(sti,seen_states) ) seen_states = [ sti; seen_states ]; end
  act_taken( sti, at ) = 1; 
  
  % keep track of the number of timesteps since we visited this state: 
  %
  nts_since_visit = nts_since_visit + 1; % increment all non visited state/action pair: 
  nts_since_visit(sti,at) = 0;           % reinitialize the one that we DID visit  
% ; my old code stuff
% start = grid(1,4);
% goal = grid(6, 9);
% barrier = grid(3, 1:8);
% new_barrier = grid(3,2:9);
% propagate to state stp1 and collect a reward rew
  MZ = mz_fn(tsi);             % <- get the current maze for this timestep 
  [rew,stp1,stp1i] = stNac2stp1(st,at,MZ,sideII,sideJJ,s_end); 
  %fprintf('stp1=(%d,%d); rew=%3d...\n',stp1(1),stp1(2),rew);
  
  % update our action-value function: 
  if( ~( (stp1(1)==s_end(1)) && (stp1(2)==s_end(2)) ) ) % stp1 is not the terminal state
    Q(sti,at) = Q(sti,at) + alpha*( rew + gamma*max(Q(stp1i,:)) - Q(sti,at) ); 
  else                                                  % stp1 IS the terminal state ... no Q(s';a') term in the sarsa update
    Q(sti,at) = Q(sti,at) + alpha*( rew - Q(sti,at) ); 
  end
    
  % update our model of the environment: 
  Model_ns(sti,at) = stp1i; 
  Model_nr(sti,at) = rew; 

  %--
  % perform some PLANNING STEPS: 
  %--
  for pi=1:nPlanningSteps,
    % pick a random state we have seen "r_sti": 
    tmp = randperm(length(seen_states)); r_sti = seen_states(tmp(1)); 
    
    % pick a random action from the ones that we have seen (in this state) "r_ati": 
    pro_action = act_taken(r_sti,:)/sum(act_taken(r_sti,:)); % <- the probabilty of each specific action ... 
    r_ati = sample_discrete( pro_action, 1, 1 );
    
    % get our models predition of the next state (and reward) "model_sprimei", "model_rew": 
    model_sprimei   = Model_ns(r_sti,r_ati);
    [ii,jj]         = ind2sub( [sideII,sideJJ], model_sprimei ); 
    model_sprime(1) = ii; model_sprime(2) = jj;
    model_rew       = Model_nr(r_sti,r_ati);
    % use ONLY the modeled reward ...in planning ... just like plane dynaQ: 
    model_rew       = model_rew;
    %fprintf( 'm_sprimei=%10d, m_sprimt=(%10d,%10d)\n', model_sprimei, model_sprime(1), model_sprime(2) ); 
    
    % update our action-value function: 
    if( ~( (model_sprime(1)==s_end(1)) && (model_sprime(2)==s_end(2)) ) ) % model_sprime is not the terminal state
      Q(r_sti,r_ati) = Q(r_sti,r_ati) + alpha*( model_rew + gamma*max(Q(model_sprimei,:)) - Q(r_sti,r_ati) ); 
    else                                                  % model_sprime IS the terminal state ... no Q(s';a') term in the sarsa update
      Q(r_sti,r_ati) = Q(r_sti,r_ati) + alpha*( model_rew - Q(model_sprimei,r_ati) ); 
    end
      
    if( PLOT_STEPS && ts>8000 ) 
      num2act = { 'UP', 'DOWN', 'RIGHT', 'LEFT' }; 
      plot( st(2), st(1), 'o', 'MarkerFaceColor', 'g' ); title( ['action = ',num2act(atp1)] ); 
      plot( stp1(2), stp1(1), 'o', 'MarkerFaceColor', 'k' ); drawnow; 
    end 
    
    %pause; 
  end % end planning loop 
  
  % shift everything by one (this completes one "step" of the algorithm): 
  st = stp1; sti = stp1i; ts=ts+1; 

  % for continual planning ... if we have "solved" our maze we will start over:
  if( ( (stp1(1)==s_end(1)) && (stp1(2)==s_end(2)) ) ) % stp1 is the terminal state
    st = s_start; sti = sub2ind( [sideII,sideJJ], st(1), st(2) ); 
    % record that we took "ts" timesteps to get to the solution (end state)
    ets = [ets; ts]; ts=0; 
    % record that we got to the end: 
    cr(tsi+1) = cr(tsi)+1; 
  else
    % record that we did not get to the end and our cummulative reward count does not change: 
    cr(tsi+1) = cr(tsi);     
  end
  
end % end episode loop 


function [rew,stp1,stp1i] = stNac2stp1(st,act,MZ,sideII,sideJJ,s_end)
% STNAC2STP1 - state and action to state plus one and reward 
%   

% convert to row/column notation: 
ii = st(1); jj = st(2); 

% incorporate any actions and fix our position if we end up outside the grid:
% 
switch act
 case 1, 
  %
  % action = UP 
  %
  stp1 = [ii-1,jj];
 case 2,
  %
  % action = DOWN
  %
  stp1 = [ii+1,jj];
 case 3,
  %
  % action = RIGHT
  %
  stp1 = [ii,jj+1];
 case 4
  %
  % action = LEFT 
  %
  stp1 = [ii,jj-1];
 otherwise
  error(sprintf('unknown value for of action = %d',act)); 
end

% adjust our position of we have fallen outside of the grid:
% 
if( stp1(1)<1      ) stp1(1)=1;      end
if( stp1(1)>sideII ) stp1(1)=sideII; end
if( stp1(2)<1      ) stp1(2)=1;      end
if( stp1(2)>sideJJ ) stp1(2)=sideJJ; end

% if this trasition has placed us at a forbidden place in our maze no transition takes place:
if( MZ(stp1(1),stp1(2))==1 ) 
  stp1 = st; 
end

% convert to an index: 
stp1i = sub2ind( [sideII,sideJJ], stp1(1), stp1(2) ); 

% get the reward for this step: 
% 
if( (ii==s_end(1)) && (jj==s_end(2)) )
  rew=0;
  %rew = 1; 
else
  rew=-1;
  %rew = 0; 
end

end
end
%%my effort lol

% numFinishes = 0;
% 
% numStates = 1000;
% compTime = 3000;
% b = 2;
% n = 10;
% VgreedyS0 = 
% pTerm = 0.1;
% tTeminal = false;
% tMatx(numStates,3) = [];
% actions = ['N', 'E', 'S', 'W'];
% act_len = length(actions);
% 
% 
% 
% for i = 1: compTime
%     if randn >= epsilon
%         for s = 1:numStates
%             a(s) = find(max(q(s,:)));
%         end
% 
%             else a(s) = find(max(q(s)),2);
%                 if a(s) ,:))== 2
%                     s(s+1,2) =  randi(b);
%                     s(s+1,1) = 0;
%                 elseif a(s) == 1
%                     s(s+1,1) =  randi(b);
%                     s(s+1,2) = 0;
%                 end
%                 tMatx(s,1) = s(s(s+1) ~= 0);
%                 tMatx(s,2) = a(s);
%                 mu = 0;
%                 sigm = 1;
%                 tMatx(s,3) = randn;
%                 q(s,a(s)) = tMatx(s,3) + q(s+1,a(s));
%     rew = randn;
%     state(i) = 
%     else
%         tTerminal = true;
%         
%         