function [reward] =  RewardAtStateAndTime(des_state_A1,des_state_A2,tc,num_states,reward_value,reward)
row_index = (des_state_A1-1)*num_states+des_state_A2;
reward(row_index,tc) = reward_value;
end 