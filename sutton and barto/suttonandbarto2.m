ch6:%%this is more of a Q learnign because i get action prime as greedy. the
%%policy is greedy.

clear;
startingCor = [1,4];
endingcor = [7,4];
indend = sub2ind([10,7], 7,4);
nStates = prod(10,7);
actions = [-1,-1;-1,0;-1,1;0,-1;0,1;1,-1;1,0;1,1];
nActs = 8;
nstates = 70; % 7 =y axis, 10 = x axis
iter = 1000000;
Q (1:nstates,1:8) = -2.6;
V(1:nstates,1:iter) = 0;
V(indend,1:iter) = 0;
firstSARewCnt = zeros(nstates,nActs);
firstSARewSum = zeros(nstates,nActs);
pos = [repmat(0,7,3), repmat(1,7,3), repmat(2,7,2), repmat(1,7,1),repmat(0,7,1)];
corner1 = 1:10;
corner2 = 1:7;


for  i = 1:iter
     st = 0;
     currStates = startingCor;
     indxpi = sub2ind([10,7], currStates(end,1),currStates(end,2));
     while indxpi  ~= indend
        if randi(100) > 10
                indxpi = sub2ind([10,7], currStates(end,1),currStates(end,2));
                greedyChoice = find(actions(:,2) <=  7-(pos(currStates(end,2),currStates(end,1)) +currStates(end,2)));
                greedyChoice1 = find(actions(:,2) >=  1-(pos(currStates(end,2),currStates(end,1)) +currStates(end,2)));
                greedyChoice2 = find(actions(:,1) <= 10 - currStates(end,1));
                greedyChoice3 = find(actions(:,1) >= 1 - currStates(end,1));
                greedyChoice = greedyChoice(ismember(greedyChoice, greedyChoice1));
                greedyChoice2 = greedyChoice2(ismember(greedyChoice2,greedyChoice3));
                greedyChoice = greedyChoice(ismember(greedyChoice,greedyChoice2));
                if isempty(greedyChoice)
                    [dum,greedychoice2] = max(Q(indxpi,greedyChoice2),[],1,'linear');
                    greedyChoice2 = greedyChoice2(greedychoice2);
                    greedyChoice2 = greedyChoice2(randi(length(greedyChoice2)),1);
                    currStates(end+1,:) = [currStates(end,1)+  actions(greedyChoice2,1), currStates(end,2)];
                    indx = sub2ind([10,7], currStates(end,1),currStates(end,2));
                    greedyChoice = greedyChoice2;
                    polY(currStates(end-1,2)) = currStates(end,2) - currStates(end-1,2);
                    polX(currStates(end-1,1)) = actions(greedyChoice,1);
                else
                    [dum,greedychoice] = max(Q(indxpi,greedyChoice),[],1,'linear');
                    greedyChoice = greedyChoice(greedychoice);
                    greedyChoice = greedyChoice(randi(length(greedyChoice)),1);
                    if isempty(greedyChoice)
                          indx = sub2ind([10,7], currStates(end,1),currStates(end,2));
                    else
                      currStates(end+1,:) = [currStates(end,1)+  actions(greedyChoice,1); currStates(end,2)+ pos(currStates(end,2),currStates(end,1)) +  actions(greedyChoice,2)];
                      indx = sub2ind([10,7], currStates(end,1),currStates(end,2));
                    end
                    polX(indxpi,i) = actions(greedyChoice,1);
                    polY(indxpi,i) = currStates(end,2) - currStates(end-1,2);
                end
                if length(currStates) < 20 
                    if indx ~= indend
                        [dumm,greedyChoicePrime] = max(Q(indx,:));
                        greedyChoicePrime = greedyChoicePrime(randi(length(greedyChoicePrime)),1); 
                        error =  -1+ Q(indx,greedyChoicePrime) - Q(indxpi,greedyChoice);
                        errorS = -1+ V(indx,i) - V(indxpi,i);
                        Q(indxpi, greedyChoice) =  Q(indxpi,greedyChoice)+ (0.5)*error;
                        V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                        st = st +1;
                        firstSARewCnt(indxpi,i) = st; 
                    else
                        error =  - Q(indxpi,greedyChoice);
                        errorS =  - V(indxpi,i);
                        Q(indxpi, greedyChoice) =  Q(indxpi,greedyChoice)+ (0.5)*error;
                        V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                        st = st +1;
                        firstSARewCnt(indxpi,i) = st; 
                    end
                else
%                     disp('greater than 20');
                   [dumm,greedyChoicePrime] = max(Q(indx,:));
                    greedyChoicePrime = greedyChoicePrime(randi(length(greedyChoicePrime)),1); 
                    error =  -1+ Q(indx,greedyChoicePrime) - Q(indxpi,greedyChoice);
                    errorS = -1+ V(indx,i) - V(indxpi,i);
                    Q(indxpi, greedyChoice) =  Q(indxpi,greedyChoice)+ (0.5)*error;
                    V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                    currStates = [];
                    currStates(1,:) = startingCor;
                    st = st +1;
                end    
         else
                Choice = find(actions(:,2) <=  7-(pos(currStates(end,2),currStates(end,1)) +currStates(end,2)));
                Choice1 = find(actions(:,2) >=  1-(pos(currStates(end,2),currStates(end,1)) +currStates(end,2)));
                Choice2 = find(actions(:,1) <= 10 - currStates(end,1));
                Choice3 = find(actions(:,1) >= 1 - currStates(end,1));
                Choice = Choice(ismember(Choice,Choice1));
                Choice2 = Choice2(ismember(Choice2,Choice3));
                Choice = Choice(ismember(Choice,Choice2));
                if isempty(Choice)
                    Choice2 = Choice2(randi(length(Choice2)),1);
                    currStates(end+1,:) = [currStates(end,1)+  actions(Choice2,1); currStates(end,2)];
                    indx = sub2ind([10,7], currStates(end,1),currStates(end,2));
                    Choice = Choice2;
                    polY(indxpi,i) = currStates(end,2) - currStates(end-1,2);
                    polX(indxpi,i) = actions(Choice,1);
                else
                    Choice = Choice(randi(length(Choice),1));
                    currStates(end+1,:) = [currStates(end,1)+  actions(Choice,1); currStates(end,2)];
                    indx = sub2ind([10,7], currStates(end,1),currStates(end,2));
                end
                if length(currStates) < 20 
                    if indx ~= indend
%                         greedyChoicePrime = greedyChoicePrime(randi(length(greedyChoicePrime)),1); %for q learning we use optimal not for sarsa
%                         error =  -1+ Q(indx,greedyChoicePrime) - Q(indxpi,Choice);
                        error =  -1+ Q(indx,Choice) - Q(indxpi,Choice);
                        Q(indxpi, Choice) =  Q(indxpi,Choice)+ (0.5)*error;
                        errorS = -1+ V(indx,i) - V(indxpi,i);
                        V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                    else
                        error =  - Q(indxpi,Choice);
                        errorS =  - V(indxpi,i);
                        Q(indxpi, greedyChoice) =  Q(indxpi,Choice)+ (0.5)*error;
                        V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                        st = st +1;
                        firstSARewCnt(indxpi,i) = st; 
                    end

                else
%                         disp('greater than 20');
                        error =  -1 + Q(indx,Choice) - Q(indxpi,Choice);
                        Q(indxpi, Choice) =  Q(indxpi,Choice)+ (0.5)*error;
                        errorS = -1+ V(indx,i) - V(indxpi,i);
                        V(indxpi,i) = V(indxpi,i)+ (0.5)*errorS;
                        currStates = [];
                        currStates(1,:) = startingCor;
                        
                end   
        end
     end
     firstSARewCnt(:,i) = st - firstSARewCnt(:,i);
     firstSARewCnt(indend,i) = 0;
     step(i) = length(currStates);
     figure();
     plot(corner1(:),repmat(corner1(1),10,1),repmat(corner1(1),7,1),corner2(:),repmat(corner1(end),7,1), corner2(:), corner1(:),repmat(corner2(end),10,1));
     hold on;
     title('iteration i');
     hold on; plot(currStates(1:end,1),currStates(1:end,1));
     xlim([1,10]);
     ylim([1,7]);
end

%      title('iteration i');plot(corner1(:),repmat(corner1(1),10,1),repmat(corner1(1),7,1),corner2(:),repmat(corner1(end),7,1), corner2(:), corner1(:),repmat(corner2(end),10,1));
%      hold on;
% [iiM,jjM]=meshgrid(1:10,1:7);
% 
% quiver(iiM,jjM,px,-py,0);