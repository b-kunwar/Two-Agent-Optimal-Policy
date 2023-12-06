clc
clear
close all

%% Variabile Initialization 
global S;
%% State Space
S = [1,2,3,4,5,6];
n = size(S,2);
%% Action Spaace
% 1: right, 2: up, 3: down
A = [1,2,3];
a = size(A,2);
Action = ["Right", "Up", "Down"];
rightArrow = '→';
upArrow = '↑';
downArrow = '↓';
actionSym = [rightArrow upArrow downArrow];
%% Decision Epoch 
T = [0,1,2,3,4];
tmax = size(T,2);
%% State Space and Action Space : 2 Agents (2A)
S_2A = allcomb(S,S);
A_2A = allcomb(A,A);
n_2A = size(S_2A,1);
a_2A = size(A_2A,1);
jointActionIndex = 1:a_2A;
%% Transition Probability 
p_along = 0.6;
p_wind = 1-p_along;
INIT_TransitionProbability;
%% Reward 
% terminal reward 
terminal_reward = 5000;
terminalRewardVec = zeros(n_2A,tmax);
des_state_A1 = 3;
des_state_A2 = 4;
terminalRewardVec =  RewardAtStateAndTime(des_state_A1,des_state_A2,tmax,n,terminal_reward,terminalRewardVec);

% penalty for collision ( used inside the dynamic programming loop)
penalty = -2500;

% special reward intiialization
special_reward_A1 = zeros(n,n,a); 
special_reward_A2 = zeros(n,n,a); 

% nomianl reward Rnom(s,a)
nominal_reward_SA_A1 = zeros(n,n,a);
nominal_reward_SA_A2 = zeros(n,n,a);

% nominal reward Rnom(s',s,a)
nominal_reward_SSA_A1 = zeros(n,n,a);
nominal_reward_SSA_A2 = zeros(n,n,a);

%%  Value evaluation
V_2A = zeros(n_2A,tmax);
V_2A(:,tmax) = terminalRewardVec(:,tmax);

% At each time step
% 1. For all combination of states, find Q value for all combination of
% actions
% 2. Find maximum Q-value and corresponding action set
for tc = tmax-1:-1:1
    Q_2A = zeros(n_2A,a_2A);
    for s_i = 1:n_2A
        current_state_A1 = S_2A(s_i,1);
        current_state_A2 = S_2A(s_i,2);
        for a_i =1:a_2A
            action_A1 = A_2A(a_i,1);
            action_A2 = A_2A(a_i,2);
            
            % Evaluate next state given the current state and action
            next_state_A1 = SelectNextState(P,current_state_A1,action_A1);
            next_state_A2 = SelectNextState(P,current_state_A2,action_A2);

            if next_state_A1 == next_state_A2
              % Assign penalty for (s',s,a) triplet that results in
              % collision
                spec_Reward_A1 = nominal_reward_SSA_A1;
                spec_Reward_A2 = nominal_reward_SSA_A2;

                spec_Reward_A1(next_state_A1,current_state_A1,action_A1) = penalty;
                R_A1 = sum(P(:,current_state_A1,action_A1).*spec_Reward_A1(:,current_state_A1,action_A1));
                spec_Reward_A2(next_state_A2,current_state_A2,action_A2) = penalty;
                R_A2 = sum(P(:,current_state_A2,action_A2).*spec_Reward_A2(:,current_state_A2,action_A2));
                R = R_A1 + R_A2;
            else
                % Assign reward for (s',s,a) triplet if any such reward
                % exists
                R_SAA_A1 = nominal_reward_SSA_A1(next_state_A1,current_state_A1,action_A1);
                R_SSA_A2 = nominal_reward_SSA_A2(next_state_A2,current_state_A2,action_A2);
                
                
                % Assign reward for (s,a) triplet if any such reward
                % exists
                R_SA_A1 = nominal_reward_SA_A1(current_state_A1,action_A1);
                R_SA_A2 = nominal_reward_SA_A2(current_state_A2,action_A2);

                R = R_SAA_A1 + R_SSA_A2 + R_SA_A1 + R_SA_A2;
            end
            
            % 
            if tc == 1 && current_state_A1 == current_state_A2
                R = NaN; 
            end

            Q_2A(s_i,a_i,tc) = R +  sum(P_2A(:,s_i,a_i).*V_2A(:,tc+1));

        end
        V_2A(s_i,tc) = max(Q_2A(s_i,:,tc));
        dstar{s_i,tc} = find(V_2A(s_i,tc)==Q_2A(s_i,:,tc));
%         rejectedActionSetIndices{s_i,tc} = setdiff(jointActionIndex,dstar{s_i,tc});

        optActionSetIndices = dstar{s_i,tc};

        % just for analysis
%         optActionSetIndices = rejectedActionSetIndices{s_i,tc};
     
        optimalActionSet = A_2A(optActionSetIndices,:);
        numIterations = length(optActionSetIndices);
        actionDisp = cell(numIterations,1 );
        for i = 1: numIterations
            actionDisp{i,:} = actionSym(optimalActionSet(i,:));
        end
        actionDispSing = join(actionDisp,',');
        valueAndAction = [num2str(V_2A(s_i,tc));actionDispSing];
%           V_Array(s_i,tc) = valueAndAction;
        V_Array(s_i,tc) = join(valueAndAction, ', ');

    end
end

disp(V_2A)

disp(V_Array)

V_Table = array2table(V_Array);



% Plot V-values as a heatmap
figure;
heatmap(V_2A, 'Colormap', jet, 'ColorLimits', [min(V_2A(:)), max(V_2A(:))]);
title('V-values for States');
xlabel('Time Step');
ylabel('State Index');
colorbar;