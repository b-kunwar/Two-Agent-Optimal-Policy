clc
clear
close all

% Decision epoch
T = [0,1,2,3,4];
Tprime = T+1;
% State space
global S;

S = [1,2,3,4,5,6];

% Action space
% 1: right
% 2: up
% 3: down
A = [1,2,3];
Action = ["Right", "Up", "Down"];
rightArrow = '→';
upArrow = '↑';
downArrow = '↓';
ActionSym = [rightArrow upArrow downArrow];

% Number of elements
tmax = size(T,2);
n = size(S,2);
a = size(A,2);

%% Multiagent
S_2A = allcomb(S,S);
A_2A = allcomb(A,A);
n_2A = size(S_2A,1);
a_2A = size(A_2A,1);


penalty = -2500;
terminal_reward = 5000;

% Value evaluation
V_2A = zeros(n_2A,tmax);

reward = zeros(n_2A,tmax);

des_state_A1 = 3;
des_state_A2 = 4;
reward =  RewardAtStateAndTime(des_state_A1,des_state_A2,tmax,n,terminal_reward,reward);
V_2A(:,tmax) = reward(:,tmax);


%
INIT_TransitionProbabilityAndRewards

posible_actions = 1:a_2A;

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

            next_state_A1 = SelectNextState(P,current_state_A1,action_A1);
            next_state_A2 = SelectNextState(P,current_state_A2,action_A2);

            if next_state_A1 == next_state_A2
                
                % There can be a nominal reward distribution rt(s',s,a)
                % Reward_A1 dependent on the future states that are known
                % ahead of time 

                % There is a special dynamic reward (or penalty) Spec_Reward_A1 when the future state
                % of agents coincide

                % There can be stationary reward (bad or good states) 

                Spec_Reward_A1 = Reward_A1;
                Spec_Reward_A2 = Reward_A2;

                Spec_Reward_A1(next_state_A1,current_state_A1,action_A1) = penalty;
                R_A1 = sum(P(:,current_state_A1,action_A1).*Spec_Reward_A1(:,current_state_A1,action_A1));
                Spec_Reward_A2(next_state_A2,current_state_A2,action_A2) = penalty;
                R_A2 = sum(P(:,current_state_A2,action_A2).*Spec_Reward_A2(:,current_state_A2,action_A2));
                R = R_A1 + R_A2;
            else
                R = 0;
            end

            if tc == 1 && current_state_A1 == current_state_A2
                R = NaN; 
            end

            Q_2A(s_i,a_i,tc) = R +  sum(P_2A(:,s_i,a_i).*V_2A(:,tc+1));

        end
        V_2A(s_i,tc) = max(Q_2A(s_i,:,tc));
        dstar{s_i,tc} = find(V_2A(s_i,tc)==Q_2A(s_i,:,tc));
        dNA{s_i,tc} = setdiff(posible_actions,dstar{s_i,tc});

        optActionSetIndices = dstar{s_i,tc};
        optimalActionSet = A_2A(optActionSetIndices,:);
        numIterations = length(optActionSetIndices);
        actionDisp = cell(numIterations,1 );
        for i = 1: numIterations
            actionDisp{i,:} = ActionSym(optimalActionSet(i,:));
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