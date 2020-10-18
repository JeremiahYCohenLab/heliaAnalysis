
firstSARewSumOpt = zeros(nstates,nActs);
firstSARewCntOpt = zeros(nstates,nActs);
a = 3;

for l = 1: 10000
    currStatesOpt = [];
    currVelOpt = [];
    currVelOpt(1,1:2) = [0,0];
    currStatesOpt = startingCor;
    R1 = 0;
    while sum(sum(currStatesOpt(end,:) == endingcor(:,1:2))) < 2
            indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2));
            indxact = find(actions(:,1) == pi_opt(indxr,1,l));
            indxact2 = find((actions(:,2) == pi_opt(indxr,2,l)));
            indxact1 = ismember(indxact2,indxact);
            currVelOpt(end+1,:) = currVelOpt(end,:) + pi_opt(indxr,l);
%             currVelOpt(end+1,:) = currVelOpt(end,:) + actions(indxact1,:);
            if ~(currVelOpt(end,1) <= 5 && currVelOpt(end,2) <= 5 && currVelOpt(end,1) > 0 && currVelOpt(end,2) > 0)
                currVelOpt(end,:) = [1,1];
                currStatesOpt(end+1,:) = currStatesOpt(end,:) +  currVelOpt(end,:);
                if length(currStatesOpt) < 60 
                    if currStatesOpt(end,1) <= min(boundry(:,1)) || currStatesOpt(end,2) <= min(boundry(:,2)) || currStatesOpt(end,1) > max(boundry(:,1)) || currStatesOpt(end,2) > max(boundry(:,2))
                        currStatesOpt(end,:) = startingCor;
                        currVelOpt(end,:) = [0,0];
                        R1 = R1-1;
                    else
                        R1 = R1 -1;
                        indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2)); %new state
                        firstSARewCntOpt(indxr,indxact1) = firstSARewCntOpt(indxr,indxact1)+1; 
                        firstSARewSumOpt(indxr,indxact1) = firstSARewSumOpt(indxr,indxact1)+R;
                        Q_opt(indx,indxact1)             = firstSARewSumOpt(indxr,indxact1)/firstSARewCntOpt(indxr,indxact1); % <-take the average
    %                  States(end,2,i)+currVel(end,:,i))); %new state   
                       a = a ;
                       hold on; plot(currStatesOpt(end,:)+ pi_opt(indx,:,l),'rs', 'Markersize', a +1);
                    end
                else
                    disp('greater than 60');
                    currStatesOpt = [];
                    currVelOpt = [];
                    currVelOpt(1,1:2) = [0,0];
                    currStatesOpt(1,1:2) = startingCor ;
                    R1 = 0;
                end
         else
            currStatesOpt(end+1,:) = currStatesOpt(end,:) +  currVelOpt(end,:);
             if length(currStatesOpt) < 60 
                if currStatesOpt(end,1) <= min(boundry(:,1)) || currStatesOpt(end,2) <= min(boundry(:,2)) || currStatesOpt(end,1) > max(boundry(:,1)) || currStatesOpt(end,2) > max(boundry(:,2))
                    currStatesOpt(end,:) = startingCor;
                    currVelOpt(end,:) = [0,0];
                    R1 = R1-1;
                else
                    R1 = R1 -1;
                    indxr = sub2ind([5,5], currStatesOpt(end,1),currStatesOpt(end,2)); %new state
    %                 WC = 1/firstSARewCnt(indxpi,pi(indxpi,i));
                    firstSARewCntOpt(indxr,indxact1) = firstSARewCntOpt(indxr,indxact1)+1; 
                    firstSARewSumOpt(indxr,indxact1) = firstSARewSumOpt(indxr,indxact1)+R;
                    Q_opt(indxr,indxact1)             = firstSARewSumOpt(indxr,indxact1)/firstSARewCntOpt(indxr,indxact1); % <-take the average         
                    hold on; plot(currStatesOpt(end,1) + pi_opt(indxr,1),currStatesOpt(end,2 )+ pi_opt(indxr,2),'rs',  'Markersize', a +1);
    %                 
                 end
             else
               disp('greater than 60');
               currStatesOpt = [];
               currVelOpt = [];
               currVelOpt(1,1:2) = [0,0];
               currStatesOpt(1,1:2) = startingCor;
               R1 = 0;
            end    
%          
        end
     end
end