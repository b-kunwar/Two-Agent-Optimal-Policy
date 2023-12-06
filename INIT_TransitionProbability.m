
%% Transition Probability 
%% Action: right 
% along 
% P(s|s,right)
i = S;
i_inc = 0;  probability = p_along;
Pf_along = AssignTransitionProability(i_inc,i,probability);

% wind 
% P(s+1|s,right) 
i = S;
i_inc = 1; probability = p_wind;
Pf_wind = AssignTransitionProability(i_inc,i,probability);

Pf = Pf_along + Pf_wind;

%% Action: up 
% along 
% P(s-1|s,up)
i = S;
i_inc = -1;  probability = p_along;
Pf_along = AssignTransitionProability(i_inc,i,probability);

% wind 
% P(s|s,up) 
i = S;
i_inc = 0; probability = p_wind;
Pf_wind = AssignTransitionProability(i_inc,i,probability);

Pu = Pf_along + Pf_wind;

%% Action: down 
% along 
% P(s+1|s,down)
i = S;
i_inc = 1;  probability = p_along;
Pf_along = AssignTransitionProability(i_inc,i,probability);

% wind 
% P(s+2|s,down) 
i = S;
i_inc = 2; probability = p_wind;
Pf_wind = AssignTransitionProability(i_inc,i,probability);

Pd = Pf_along + Pf_wind;

%% Transition Proabibility for Agent 1
% Action = ["Right", "Up", "Down"];

P(:,:,1) = Pf;
P(:,:,2) = Pu;
P(:,:,3) = Pd;

% P_2A([s1p,s2p]|[s1,s2],a) = P(s1p|s1,a) * P(s2p|s2,a);
%% Joint Transition Probability for Agent 1 and Agent 2
for a_i = 1:a_2A
    a_A1 = A_2A(a_i,1);
    a_A2 = A_2A(a_i,2);
for sprime_i = 1:n_2A
        next_state_A1 = S_2A(sprime_i,1);
        next_state_A2 = S_2A(sprime_i,2);
        for s_i = 1:n_2A
        current_state_A1 = S_2A(s_i,1);
        current_state_A2 = S_2A(s_i,2);

            P_2A(sprime_i,s_i,a_i) = P(next_state_A1,current_state_A1,a_A1).*P(next_state_A2,current_state_A2,a_A2);
        end 
end 
end 




