%% Custom Functions
function P = AssignTransitionProability(i_inc,i,p)
global S
num_states = length(S);
istart = i(1);
iend = i(end);
P = zeros(num_states,num_states);
for i=istart:iend
    next_state = i + i_inc;
    current_state = i;
    % if next state falls outside of the grid, the probability of
    % exiting the grid becomes the probaility of staying at the last
    % cell in that direction
    if next_state > num_states
        next_state = num_states;
    end

    if next_state < 1
        next_state = 1;
    end 
    P(next_state,current_state) = p;
end
