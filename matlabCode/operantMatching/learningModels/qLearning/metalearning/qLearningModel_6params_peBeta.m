function [LH, probChoice, Q, pe, beta, R] = qLearningModel_6params_peBeta(startValues, choice, outcome)

alphaNPE = startValues(1);
alphaPPE = startValues(2);
alphaForget = startValues(3);
betaMin = startValues(4);
betaMax = startValues(5);
betaRate = startValues(6);

trials = length(choice);
Q = zeros(trials,2);
beta = zeros(trials,1);
R = zeros(trials,1);

% Call learning rule
for t = 1 : (trials-1)
    if choice(t, 1) == 1 % right choice
        Q(t+1, 2) = alphaForget*Q(t, 2);
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
    R(t+1) = R(t) + betaRate * pe(t);
    beta(t+1) = betaMin + (betaMax - betaMin) * R(t);
end

if choice(t, 1) == 1
    pe(trials) = outcome(end, 1) - Q(end, 1);
else
    pe(trials) = outcome(end, 2) - Q(end, 2);
end


% Call softmax  rule

probChoice = logistic([beta.*(Q(:, 1)-Q(:, 2)), ...
                       beta.*(Q(:, 2)-Q(:, 1))]);

% To calculate likelihood:
LH = likelihood(choice,probChoice);
end