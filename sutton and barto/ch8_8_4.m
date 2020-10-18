numStates = 1000;
compTime = 5000;
b = 2;
VgreedyS0 = 
epsilon = 0.1;
pTerm = 0.1;
tTeminal = false;
actions = 2;
tMatx(numStates,3) = [];
q(numStates, 2);

for i = 1: compTime
    if randn >= pTerm
        for s = 1:numStates
            if s == 1
                a(1) = randi(2);
            else a(s) = find(max(q(s)),2);
                if a(s) == 2
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
        
        