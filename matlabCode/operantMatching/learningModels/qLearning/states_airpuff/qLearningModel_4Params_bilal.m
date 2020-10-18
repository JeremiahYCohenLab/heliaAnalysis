function [LH, probChoice, Q, pe] = qLearningModel_4Params_bilal(startValues, choice, outcome)

alphaNPE = startValues(1);
alphaPPE = startValues(2);
alphaForget = startValues(3);
beta = startValues(4);

trials = length(choice);
Q = zeros(trials,2);

% Call learning rule
for t = 1 : (trials-1)
    if choice(t, 1) == 1 % right choice   
        Q(t+1, 2) = alphaForget*Q(t, 2);  %%%should this be two parameters for two different state?
%           Q(t+1, 1) = alphaForget*Q(t, 1) + alphaLearn * (outcome(t, 1) - Q(t, 1));
        pe(t) = outcome(t, 1) - Q(t, 1);
        if pe(t) < 0
            Q(t+1, 1) = alphaForget*Q(t, 1) + alphaNPE * pe(t);
        else
            Q(t+1, 1) = alphaForget*Q(t, 1) + alphaPPE * pe(t);
        end
    else % left choice
        Q(t+1, 1) = alphaForget*Q(t, 1);
        pe(t) = outcome(t, 2) - Q(t, 2);
        if pe(t) < 0
            Q(t+1, 2) = alphaForget*Q(t, 2) + alphaNPE * pe(t);
        else
            Q(t+1, 2) = alphaForget*Q(t, 2) + alphaPPE * pe(t);
        end
    end
end

% Call softmax  rule

probChoice = logistic([beta*(Q(:, 1)-Q(:, 2)), ...
                       beta*(Q(:, 2)-Q(:, 1))]);

% To calculate likelihood:
LH = likelihood(choice,probChoice);
end