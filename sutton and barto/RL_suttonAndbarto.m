%%
% incremental average : a simple bandit algorithm
% a = 1;
k = 10;
Q(1:k,1) = 0;
N(1:k,1) = 0;
epsilon = [0,0.5,0.9];
%A = [1,2,2,2,3];
%R2 = [-1,1,-2,2,0];
% alpha(1:k,1) = 0;
Rtot(1,1:3) = 0;

for i = 1:length(epsilon)
    for t= 2:100
        if randi(100) <= (1-epsilon(i))*100 
            [M,a] = max(Q(t));
    %         a = find(max(Q(t)));
            if size(a) >= 2
               a = randi(k);
               N(a) = N(a) +1;
               R = normrnd(0,0.01);
               Q (a,t) = R+ (1/N(a))*(R- Q(a,t-1)); 
               Rtot(t,i) = Rtot(t-1,i) + sum(Q(:,t));
            else
                N(a) = N(a) +1;
                R = normrnd(0,0.01);
                Q (a,t) = R+ (1/N(a))*(R- Q(a,t-1));
                Rtot(t, i) = Rtot(t-1) + sum(Q(:,t));
            end
         else
            a = randi(k);
            N(a) = N(a) +1;
            R = normrnd(0,0.01);
            Q (a,t) = R+ (1/N(a))*(R- Q(a,t-1));
            Rtot(t,i) = Rtot(t-1) + sum(Q(:,t));
         end
    end
end
t = 1000;
hold on;
plot(t, Rtot(:,1), 'Color', [1 0 0], 'MarkerSize', 20); 
hold on
plot(t, Rtot(:,2), 'Color', [0.7 0.5 0.5],'MarkerSize',20); 
hold on
plot(t, Rtot(:,3), 'Color', [0.7 0.5 1], 'MarkerSize',20); 
legend('greedy', '0.5','0.9');
%%
%CH4. exercise 4.7, Jack's car removal, max car 20 at each loc. 10rew for
%each car rental, cannot move between locations more than 5 cars.
%try this new the last one is such a mess
clear;
Req_L1_lamda = 3;
Ret_L1_lamda = 3;
Req_L2_lamda = 4;
Ret_L2_lamda = 2;
gamma = 0.9;
day = 15;
sCurr_val = ones(21,21);
stateCurr(1,1) = 10;
stateCurr(1,2) = 10;
stateCurr(1,3) = 0;
stateCurr(1,4) = 0;
stateCurr(1,5) = 0;
v = 0:5;
v1 = [0:20,0:20];
v1 = nchoosek(v1,2);
v1 = unique(v1,'rows');
acts = nchoosek(v,2);
act = [acts(:,2),acts(:,1)];
acts = [acts(:,1:2);act;0,0;1,1;2,2;3,3;4,4;5,5]; 
next_act = [0,0];
R = 0;
temp_1_all = [];
temp_2_all = [];
rew_tempall = [];
L1 = 10;
L2 = 10;
next_act(441,2,7) = 0;
%calculate value function for each state for each policy (freeze it). try a
%few policy (3-4) should converge soon.

for pi = 1:7
    ret_l1 = poissrnd(Ret_L1_lamda);
    req_l1 = poissrnd(Req_L1_lamda);
    ret_l2 = poissrnd(Ret_L2_lamda);
    req_l2 = poissrnd(Req_L2_lamda);
            %initialize a policy ,0,0
    next_act(:,1,1) = 0;
    next_act(:,2,1)=  0;
    for i = 1:length(v1)
        n = 3;   
        for k = 2:n
            loc1(i) = v1(i,1);
            loc2(i) = v1(i,2);
            loc1(i+1) = loc1(i) + next_act(i,1,pi); %taking an action
            loc2(i+1) = loc2(i) + next_act(i,2,pi);
            carMoved = next_act(i,1,pi) + next_act(i,2,pi);
            R =  10*(req_l1) -2*(carMoved);
            R = R+ 10 *(req_l2) - 2*(carMoved);
            if req_l1 >= ret_l1 + loc1(i+1) || req_l2 >= ret_l2 + loc2(i+1)
                R = 0;
            end
            loc1(i+1) = loc1(i) + ret_l1- req_l1; %resulting state
            loc2(i+1) = loc2(i) + ret_l2- req_l2;
            if loc1(i+1)>= 21 
                loc1(i+1)= 20;
            elseif loc1(i+1) <= -1
                loc1(i+1)= 0;
            end
            if loc2(i+1) >= 21 
                loc2(i+1) = 20;
            elseif loc2(i+1) <=-1
                loc2(i+1) = 0;
            end %resulting state value for all possible states using policy 0
            sCurr_val(loc1(i)+1,loc2(i)+1) = R + (gamma*(sCurr_val(loc1(i+1)+1,loc2(i+1)+1)));
    %                 stateCurr(k,1)= L1(k); stateCurr(k,2) = L2(k);
    %                 stateCurr(k,3) = next_act(1); stateCurr(k,4) = next_act(2);
               L1(k) = loc1(i);
               L2(k) = loc2(i);
               tempSval = sCurr_val(loc1(i)+1,loc2(i)+1);
                for a = 1:length(acts) %improve  and evaluate 
                    temp_1(a) = L1(k) - acts(a,1) + acts(a,2);
                    temp_2(a) = L2(k) - acts(a,2) + acts(a,1);
                    carMoved = acts(a,2)+ acts(a,1);
                    if temp_1(a) <= 20 && temp_1(a) >= 0 && temp_2(a) <= 20 && temp_2(a) >= 0
%                     if temp_1(a) >= 21
%                        temp_1(a) = 20;
%                     elseif temp_1(a) <= -1
%                         temp_1(a) = 0;
%                     end
%                     if temp_2(a) >= 21
%                        temp_2(a) = 20;
%                     elseif temp_2(a) <= -1
%                        temp_2(a) = 0;
%                     end
                        carMoved = temp_1(a) + temp_2(a) - L2(k) - L1(k);
                        R =  (10*req_l1) + (10* req_l2) - (2*carMoved) ; 
                        if req_l1 >= ret_l1 + temp_1(a) || req_l2 >= ret_l2 + temp_2(a)
                            R = 0;
                        end
                        val_ac(a) =   R + gamma*(sCurr_val(temp_1(a) +1, temp_2(a) +1)); 
                        sCurr_val(L1(k)+1, L2(k)+1) = R + (gamma*(sCurr_val(temp_1(a)+1, temp_2(a)+1)));
                        rew_tempall = [rew_tempall val_ac(a)];
                    else
                        val_ac(a) = 0;
                        rew_tempall = [rew_tempall val_ac(a)];
                        carMoved = [];
                    end
                end
                if max(rew_tempall) ~= 0
%                    temp_1(k) = 0;
%                    temp_2(k)= 0;
%                    aa = 1;
                    aa=  find(rew_tempall == max(rew_tempall),1);
                    temp_1(k) = temp_1(aa);
                    temp_2(k) = temp_2(aa);
                end
                next_act(i,1,pi) = acts(aa,1);
                next_act(i,2,pi) = acts(aa,2);        
                nextK1 = temp_1(k)+1+ret_l1-req_l1;
                if nextK1 <=0
                    nextK1 = 0;
                elseif nextK1 >=20
                    nextK1 = 20;
                end
                nextK2 = temp_2(k)+1+ret_l2-req_l2;
                if nextK2 <=0
                    nextK2 = 0;
                elseif nextK2 >=20
                    nextK2 = 20;
                end
                sCurr_val(temp_1(k)+1, temp_2(k)+1) = max(rew_tempall) + (gamma*(sCurr_val(nextK1 +1,nextK2 +1)));
    %                             stateCurr(k,5) =  sCurr_val(temp_1+1, temp_2+1);
                rew_tempall = [];
                temp_1_all = [];
                temp_2_all = [];
                if tempSval == sCurr_val(temp_1(k)+1, temp_2(k)+1)
                    k = n;
                    temp_1 = [];
                    temp_2 = [];
                else
                    n = n+1;
                end
        end
%                     next_act(v1(s,1),pi)=  acts(a,1);
%                     next_act(v1(s,2),1,pi)=   acts(a,2);
%         hold on;
%         imagesc( temp_1(a), temp_2(a), acts(a,:)); colorbar; xlabel( 'num at B' ); ylabel( 'num at A' ); 
%         axis xy; drawnow.
    end
end

v1(:,3:4) = next_act(:,:,5)
v1(:,5) = v1(:,3)-v1(:,4)
figure; imagesc(0:20,0:20,sCurr_val); colorbar; xlabel( 'num at B' ); ylabel( 'num at A' );
aaa = reshape(v1(:,5),21,21);
figure; imagesc(0:20,0:20,aaa); colorbar; xlabel( 'num at B' ); ylabel( 'num at A' );
; axis xy; drawnow;
xlim([0,20])
mesh(aaa,sCurr_val)
grid on;
%%
%% %5.2 mc first visit estimation of bj problem
clc
clear

nStates = prod([21-12+1,13,2]);
iteration = 10000;
allStatesRewSum  = zeros(nStates,1);
allStatesNVisits = zeros(nStates,1); 
curr_state = [];


for it = 1:iteration

deck = randperm(52);
d_hand = deck(1:2); deck = deck(3:end);
p_hand = deck(1:2); deck = deck(3:end);


d_hand = mod(d_hand -1,13)+1; d_hand= min(d_hand,10);

cardShowing = d_hand(1);

p_hand =  mod(p_hand -1 ,13) +1; p_hand= min(p_hand,10);

while sum(d_hand) <= 17
  d_hand =  [d_hand  deck(1)];
  deck = deck(2:end);
  d_hand = mod(d_hand -1,13) +1; d_hand= min(d_hand,10);
end

while sum(p_hand) <= 20
  p_hand =  [p_hand  deck(1)];
  deck = deck(2:end);
  p_hand =  mod(p_hand -1,13) +1; p_hand= min(p_hand,10);
  if (sum(p_hand) <= 11) && (ismember(1,p_hand))
      sp = sum(p_hand) +10;
      aceUsable = 1;
  else
      aceUsable = 0;
      sp = sum(p_hand);
  end
  curr_state(end+1,:) = [sp,cardShowing,aceUsable];
end

if sum(p_hand) >= sum(p_hand)
    R = 1;
elseif sum(p_hand) <= sum(p_hand)
    R = -1;
elseif sum(p_hand) == sum(p_hand)
    R = 0;
end

if sum(p_hand) > 21
    R = -1;
end

if sum(d_hand) > 21
    R = 1;
end
 
[a b] = size(curr_state);

for s = 1:a
    if(curr_state(s,1)>=12) && (curr_state(s,1)<=21)
        indx=sub2ind([21-12+1,13,2],(curr_state(s,1)-12+1),(curr_state(s,2)),(curr_state(s,3)+1)); 
        allStatesRewSum(indx)  = allStatesRewSum(indx)+R; 
        allStatesNVisits(indx) = allStatesNVisits(indx)+1;
    end
end


end

mc_value_fn = allStatesRewSum./allStatesNVisits;
mc_value_fn = reshape( mc_value_fn, [21-12+1,13,2]); 


% plot the various graphs:  
% 
figure; mesh( 1:13, 12:21, mc_value_fn(:,:,1) ); 
xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
title( 'no usable ace' ); drawnow; 
%fn=sprintf('state_value_fn_nua_%d_mesh.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
figure; mesh( 1:13, 12:21,  mc_value_fn(:,:,2) ); 
xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
title( 'a usable ace' ); drawnow; 
%fn=sprintf('state_value_fn_ua_%d_mesh.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 

figure;imagesc( 1:13, 12:21, mc_value_fn(:,:,1) ); caxis( [-1,+1] ); colorbar; 
xlabel( 'dealer shows' ); ylabel( 'sum of cards in /hand' ); axis xy; 
title( 'no usable ace' ); drawnow; 
%fn=sprintf('state_value_fn_nua_%d_img.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
figure;imagesc( 1:13, 12:21, mc_value_fn(:,:,2) ); caxis( [-1,+1] ); colorbar; 
xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; 
title( 'a usable ace' ); drawnow; 
%fn=sprintf('state_value_fn_ua_%d_img.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
 %%
 %
% Implements Monte Carlo ES (exploring starts) with first visit estimation to
% compute the action-value function for the black jack example.
% 
% Written by:
% -- 
% John L. Weatherwax                2007-12-07
% 
% email: wax@alum.mit.edu
% 
% Please send comments and especially bug reports to the
% above email address.
% 
%-----

close all;
clc; 

N_HANDS_TO_PLAY=10;     % a numerical approximation of +Inf
% N_HANDS_TO_PLAY=2*1e4;
% N_HANDS_TO_PLAY=5e5;
% N_HANDS_TO_PLAY=5e6;
% %N_HANDS_TO_PLAY=1e7;

rand('seed',0); randn('seed',0); 

%--
% implement hands of bj
%--

nStates       = prod([21-12+1,13,2]);
posHandSums   = 12:21; 
nActions      = 2; % 0=>stick; 1=>hit 
Q             = zeros(nStates,nActions);  % the initial action-value function
%pol_pi        = zeros(1,nStates);         % our initial policy is to always stick "0"
pol_pi        = ones(1,nStates);         % our initial policy is to always hit "1"
%pol_pi        = unidrnd(2,1,nStates)-1;   % our initial policy is random 
firstSARewSum = zeros(nStates,nActions); 
firstSARewCnt = zeros(nStates,nActions); 

for hi=1:N_HANDS_TO_PLAY
  
  stateseen = []; 
  deck = randperm(52);

  % the player gets the first two cards: 
  p = deck(1:2); deck = deck(3:end); phv = handValue(p);
  % the dealer gets the next two cards (and shows his first card): 
  d = deck(1:2); deck = deck(3:end); dhv = handValue(d); cardShowing = d(1); 
  
  % disgard states who's initial sum is less than 12 (the decision is always to hit): 
  while( phv < 12 ) 
    p = [ p, deck(1) ]; deck = deck(2:end); phv = handValue(p); % HIT
  end
  
  % accumulate/store the first state seen: 
  stateseen(1,:) = stateFromHand( p, cardShowing );
    
  % implement the policy specified by pol_pi (keep hitting till we should "stick"):
  si = 1; 
  polInd         = sub2ind( [21-12+1,13,2], stateseen(si,1)-12+1, stateseen(si,2), stateseen(si,3)+1 );
  pol_pi(polInd) = unidrnd(2)-1;      % FOR EXPLORING STARTS TAKE AN INITIAL RANDOM POLICY!!! 
  pol_to_take    = pol_pi(polInd);
  while( pol_to_take && (phv < 22) )
    p = [ p, deck(1) ]; deck = deck(2:end); phv = handValue(p); % HIT
    stateseen(end+1,:) = stateFromHand( p, cardShowing ); 

    if( phv <= 21 ) % only then do we need to querry the next policy action when we have not gone bust
      si = si+1; 
      %[ stateseen(si,1), stateseen(si,2), stateseen(si,3) ] 
      polInd      = sub2ind( [21-12+1,13,2], stateseen(si,1)-12+1, stateseen(si,2), stateseen(si,3)+1 ); 
      pol_to_take = pol_pi(polInd);
    end
  end
  % implement the fixed deterministic policy of the dealer (hit until we have a hand value of 17): 
  while( dhv < 17 )
    d = [ d, deck(1) ]; deck = deck(2:end); dhv = handValue(d); % HIT
  end
  % determine the reward for playing this game:
  rew = determineReward(phv,dhv);
  %fprintf( '[phv, dhv, rew] = \n' ); [ phv, dhv, rew ]  
  
  % accumulate these values used in computing statistics on this action value function Q^{\pi}: 
  for si=1:size(stateseen,1)
    if( (stateseen(si,1)>=12) && (stateseen(si,1)<=21) ) % we don't count "initial" and terminal states
      %[stateseen(si,1)]
      %[stateseen(si,1)-12+1, stateseen(si,2), stateseen(si,3)+1]
      staInd = sub2ind( [21-12+1,13,2], stateseen(si,1)-12+1, stateseen(si,2), stateseen(si,3)+1 ); 
      actInd = pol_pi(staInd)+1; 
      firstSARewCnt(staInd,actInd) = firstSARewCnt(staInd,actInd)+1; 
      firstSARewSum(staInd,actInd) = firstSARewSum(staInd,actInd)+rew; 
      Q(staInd,actInd)             = firstSARewSum(staInd,actInd)/firstSARewCnt(staInd,actInd); % <-take the average 
      [dum,greedyChoice]           = max( Q(staInd,:) );
      pol_pi(staInd)               = greedyChoice-1;
    end
  end  
end % end number of hands loop 

% plot the optimal state-value function V^{*}: 
%
mc_value_fn = max( Q, [], 2 );
mc_value_fn = reshape( mc_value_fn, [21-12+1,13,2]); 
if( 1 ) 
  figure; mesh( 1:13, 12:21, mc_value_fn(:,:,1) ); 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
  title( 'no usable ace' ); drawnow; 
  fn=sprintf('state_value_fn_nua_%d_mesh.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
  figure; mesh( 1:13, 12:21,  mc_value_fn(:,:,2) ); 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
  title( 'a usable ace' ); drawnow; 
  fn=sprintf('state_value_fn_ua_%d_mesh.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
  
  figure;imagesc( 1:13, 12:21, mc_value_fn(:,:,1) ); caxis( [-1,+1] ); colorbar; 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; 
  title( 'no usable ace' ); drawnow; 
  fn=sprintf('state_value_fn_nua_%d_img.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
  figure;imagesc( 1:13, 12:21, mc_value_fn(:,:,2) ); caxis( [-1,+1] ); colorbar; 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; 
  title( 'a usable ace' ); drawnow; 
  fn=sprintf('state_value_fn_ua_%d_img.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
end

% plot the optimal policy: 
%
pol_pi = reshape( pol_pi, [21-12+1,13,2] ); 
if( 1 ) 
  figure; imagesc( 1:13, 12:21, pol_pi(:,:,1) ); colorbar; 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
  title( 'no usable ace' ); drawnow; 
  fn=sprintf('bj_opt_pol_nua_%d_image.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
  figure; imagesc( 1:13, 12:21,  pol_pi(:,:,2) ); colorbar; 
  xlabel( 'dealer shows' ); ylabel( 'sum of cards in hand' ); axis xy; %view([67,5]);
  title( 'a usable ace' ); drawnow; 
  fn=sprintf('bj_opt_pol_ua_%d_mesh.eps',N_HANDS_TO_PLAY); saveas( gcf, fn, 'eps2' ); 
end

return; 
%%
%%off-policy MC
clear;
startingCor = [randi(1),randi(1)];
endinglineY = transpose(randi(1)+3:1:5);
endinglineX = 5;
endingcor = [repmat(endinglineX(1),length(endinglineY),1), endinglineY];
actions = [-1,-1;-1,0;-1,1;0,-1;0,1;1,-1;1,0;1,1;0,0];
nActs = 9;
nstates = 25;
maxVel = 5;
iter = 1000;
%initialize for all S and and A
% WC = zeros(nstates,9);
Q (1:nstates,1:9) = -50;
pi= ones(nstates);
pi_opt = zeros(nstates,2,iter);
currStates(1,1:2) = startingCor;
R = 0;
currVel(1,1:2) = [0,0];
corner1 = transpose(randi(1):1:5);
firstSARewCnt = zeros(nstates,nActs);
firstSARewSum = zeros(nstates,nActs);
firstSARewCntOpt = zeros(nstates,nActs);
boundry = [corner1,repmat(corner1 (1),5,1); repmat(corner1(1),5,1),corner1; corner1, repmat(corner1(end),5,1)];
plot(corner1,repmat(corner1 (1),5,1),repmat(corner1(1),5,1),corner1,corner1, repmat(corner1(end),5,1));
hold on; plot(repmat(corner1(end),length(corner1(1):endinglineY(1)),1),(corner1(1):endinglineY(1)));
hold on; plot((repmat(corner1(end),length(endinglineY(end):corner1(end)),1)),((endinglineY(end):corner1(end))));
w = 1;


for i = 1:iter
    currStates = [];
    currVel = [];
    currVel(1,1:2) = [0,0];
    currStates(1,1:2) = [randi(3),randi(3)];
    startingCor =  currStates(1,1:2) ;
    R = 0;
%     indxpi = sub2ind([10,10], currStates(end,1,i),currStates(end,2,i));
    while sum(sum(currStates(end,:) == endingcor(:,1:2))) < 2
        indxpi = sub2ind([5,5], currStates(end,1),currStates(end,2));
        pi(indxpi) = randi(9);
        currVel(end+1,:) = currVel(end,:) + actions(pi(indxpi),:);
        if ~(currVel(end,1) <= 5 && currVel(end,2) <= 5 && currVel(end,1) > 0 && currVel(end,2) > 0)
            currVel(end,:) = [1,1];
            currStates(end+1,:) = currStates(end,:) +  currVel(end,:);
            if length(currStates) < 60 
                if currStates(end,1) <= min(boundry(:,1)) || currStates(end,2) <= min(boundry(:,2)) || currStates(end,1) > max(boundry(:,1)) || currStates(end,2) > max(boundry(:,2))
                    currStates(end,:) = startingCor;
                    currVel(end,:) = [0,0];
                    R = R-1;
                else
                    R = R -1;
                    indx = sub2ind([5,5], currStates(end,1),currStates(end,2)); %new state
    %                 WC = 1/firstSARewCnt(indxpi,pi(indxpi,i));
                    firstSARewCnt(indxpi,pi(indxpi)) = firstSARewCnt(indxpi,pi(indxpi))+1; 
                    firstSARewSum(indxpi,pi(indxpi)) = firstSARewSum(indxpi,pi(indxpi))+R;
    %                 Q(indx,pi(indx,i))             = (firstSARewSum(indx,pi(indx,i))*WC)/firstSARewCnt(indx,pi(indx,i)); % <-take the average
    %                 [dum,greedyChoice]           = max(Q(indx,:,i));
    %                 pi_opt(indxpi,:,i)                 = actions(greedyChoice,:);
    %                 indxOpt = sub2ind([10,10], (currStates(end,1,i) + currVel(end,:,i)) ,(currStates(end,2,i)+currVel(end,:,i))); %new state            
    %                 hold on; plot(currStates(end,:)+ pi_opt(indx,:),'rs');
    %                 pi(indx)= greedyChoice; 
                 end
                 if sum(sum(currStates(end,:) == endingcor(:,1:2))) > 2
                    for j = 1:length(currStates)
                        indx = sub2ind([5,5], currStates(j,1),currStates(j,2)); %new state
                        indxact = find(actions(:,:) == currVel(j,:));
                        WC = w/(firstSARewCnt(indx,pi(indx))+1);
                        Q(indx,pi(indx))             = ((1+firstSARewSum(indx,pi(indx)))*WC)/(1+firstSARewCnt(indx,pi(indx))); % <-take the average
                        [dum,greedyChoice]           = max(Q(indx,:));
                        pi_opt(indx,:,i)                 = actions(greedyChoice,:); 
                        if pi_opt(indx,:,i) ~= currVel(j,:)
    %                        return
                        else
                           w = w /((firstSARewCnt(indx,pi(indx))+1)/ sum(firstSARewCnt(indx,2)+1));
                        end
                    end
                 end
            else
                disp('greater than 60');
                currStates = [];
                currVel = [];
                currVel(1,1:2) = [0,0];
                currStates(1,1:2) = [randi(3),randi(3)];
                startingCor =  currStates(1,1:2) ;
                R = 0;
            end
        else
            currStates(end+1,:) = currStates(end,:) +  currVel(end,:);
             if length(currStates) < 60 
                if currStates(end,1) <= min(boundry(:,1)) || currStates(end,2) <= min(boundry(:,2)) || currStates(end,1) > max(boundry(:,1)) || currStates(end,2) > max(boundry(:,2))
                    currStates(end,:) = startingCor;
                    currVel(end,:) = [0,0];
                    R = R-1;
                else
                    R = R -1;
                    indx = sub2ind([5,5], currStates(end,1),currStates(end,2)); %new state
    %                 WC = 1/firstSARewCnt(indxpi,pi(indxpi,i));
                    firstSARewCnt(indxpi,pi(indxpi)) = firstSARewCnt(indxpi,pi(indxpi))+1; 
                    firstSARewSum(indxpi,pi(indxpi)) = firstSARewSum(indxpi,pi(indxpi))+R;
    %                 Q(indx,pi(indx,i))             = (firstSARewSum(indx,pi(indx,i))*WC)/firstSARewCnt(indx,pi(indx,i)); % <-take the average
    %                 [dum,greedyChoice]           = max(Q(indx,:,i));
    %                 pi_opt(indxpi,:,i)                 = actions(greedyChoice,:);
    %                 indxOpt = sub2ind([10,10], (currStates(end,1,i) + currVel(end,:,i)) ,(currStates(end,2,i)+currVel(end,:,i))); %new state            
    %                 hold on; plot(currStates(end,:)+ pi_opt(indx,:),'rs');
    %                 pi(indx)= greedyChoice; 
                 end
                 if sum(sum(currStates(end,:) == endingcor(:,1:2))) > 2
                    for j = 1:length(currStates)
                        indx = sub2ind([5,5], currStates(j,1),currStates(j,2)); %new state
                        indxact = find(actions(:,:) == currVel(j,:));
                        WC = w/(firstSARewCnt(indx,pi(indx))+1);
                        Q(indx,pi(indx))             = ((1+firstSARewSum(indx,pi(indx)))*WC)/(1+firstSARewCnt(indx,pi(indx))); % <-take the average
                        [dum,greedyChoice]           = max(Q(indx,:));
                        pi_opt(indx,:,i)                 = actions(greedyChoice,:); 
                        if pi_opt(indx,:,i) ~= currVel(j,:)
    %                        return
                        else
                           w = w /(((firstSARewCnt(indx,pi(indx)))+1)/ sum(firstSARewCnt(indx,2)+1));
                        end
                    end
                 end
             else
               disp('greater than 60');
               currStates = [];
               currVel = [];
               currVel(1,1:2) = [0,0];
               currStates(1,1:2) = [randi(3),randi(3)];
               startingCor =  currStates(1,1:2) ;
               R = 0;
            end    
%             while currVel(end,1) > 5 || currVel(end,2) > 5 || currVel(end,1) <= 0 || currVel(end,2) <= 0
%                   pi(indxpi,i) = randi(9);
%             currVel = currVel(1:end-1,:);
        end
     end
end

figure; plot(corner1,repmat(corner1 (1),5,1),repmat(corner1(1),5,1),corner1,corner1, repmat(corner1(end),5,1));
hold on; plot(repmat(corner1(end),length(corner1(1):endinglineY(1)),1),(corner1(1):endinglineY(1)));
hold on; plot((repmat(corner1(end),length(endinglineY(end):corner1(end)),1)),((endinglineY(end):corner1(end))));

% for l = 1: iter
%     currStatesOpt = [];
%     currVelOpt = [];
%     currVelOpt(1,1:2) = [0,0];
%     currStatesOpt = startingCor;
%     R1 = 0;
%     while sum(sum(currStatesOpt(end,:) == endingcor(:,1:2))) < 2
%             indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2));
%             indxact = find(actions(:,1) == pi_opt(indxr,1,l));
%             indxact2 = find((actions(:,2) == pi_opt(indxr,2,l)));
%             indxact1 = ismember(indxact2,indxact);
%             currVelOpt(end+1,:) = currVelOpt(end,:) + pi_opt(indxr,l);
% %             currVelOpt(end+1,:) = currVelOpt(end,:) + actions(indxact1,:);
%             if ~(currVelOpt(end,1) <= 5 && currVelOpt(end,2) <= 5 && currVelOpt(end,1) > 0 && currVelOpt(end,2) > 0)
%                 currVelOpt(end,:) = [1,1];
%                 currStatesOpt(end+1,:) = currStatesOpt(end,:) +  currVelOpt(end,:);
%                 if length(currStatesOpt) < 60 
%                     if currStatesOpt(end,1) <= min(boundry(:,1)) || currStatesOpt(end,2) <= min(boundry(:,2)) || currStatesOpt(end,1) > max(boundry(:,1)) || currStatesOpt(end,2) > max(boundry(:,2))
%                         currStatesOpt(end,:) = startingCor;
%                         currVelOpt(end,:) = [0,0];
%                         R1 = R1-1;
%                     else
%                         R1 = R1 -1;
%                         indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2)); %new state
%                         firstSARewCntOpt(indxr,indxact1) = firstSARewCntOpt(indxr,indxact1)+1; 
%                         firstSARewSumOpt(indxr,indxact1) = firstSARewSumOpt(indxr,indxact1)+R;
%                         Q_opt(indx,indxact1)             = firstSARewSumOpt(indxr,indxact1)/firstSARewCntOpt(indxr,indxact1); % <-take the average
%     %                  States(end,2,i)+currVel(end,:,i))); %new state   
%                        a = a ;
%                        hold on; plot(currStatesOpt(end,:)+ pi_opt(indx,l),'rs', 'Markersize', a +1);
%                     end
%                 else
%                     disp('greater than 60');
%                     currStatesOpt = [];
%                     currVelOpt = [];
%                     currVelOpt(1,1:2) = [0,0];
%                     currStatesOpt(1,1:2) = startingCor ;
%                     R1 = 0;
%                 end
%          else
%             currStatesOpt(end+1,:) = currStatesOpt(end,:) +  currVelOpt(end,:);
%              if length(currStatesOpt) < 60 
%                 if currStatesOpt(end,1) <= min(boundry(:,1)) || currStatesOpt(end,2) <= min(boundry(:,2)) || currStatesOpt(end,1) > max(boundry(:,1)) || currStatesOpt(end,2) > max(boundry(:,2))
%                     currStatesOpt(end,:) = startingCor;
%                     currVelOpt(end,:) = [0,0];
%                     R1 = R1-1;
%                 else
%                     R1 = R1 -1;
%                     indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2)); %new state
%     %                 WC = 1/firstSARewCnt(indxpi,pi(indxpi,i));
%                     firstSARewCntOpt(indxr,indxact1) = firstSARewCntOpt(indxr,indxact1)+1; 
%                     firstSARewSumOpt(indxr,indxact1) = firstSARewSumOpt(indxr,indxact1)+R;
%                     Q_opt(indxr,indxact1)             = firstSARewSumOpt(indxr,indxact1)/firstSARewCntOpt(indxr,indxact1); % <-take the average         
%                     hold on; plot(currStatesOpt(end,1) + pi_opt(indxr,1),currStatesOpt(end,2 )+ pi_opt(indxr,2),'rs',  'Markersize', a +1);
%     %                 
%                  end
%              else
%                disp('greater than 60');
%                currStatesOpt = [];
%                currVelOpt = [];
%                currVelOpt(1,1:2) = [0,0];
%                currStatesOpt(1,1:2) = startingCor;
%                R1 = 0;
%             end    
% %          