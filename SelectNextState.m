function [next_state] = SelectNextState(P,st,at)

probabilities = P(:, st, at);
poss_next_state = find(probabilities>0);
prob_next_state = P(poss_next_state,st,at);
x = rand();
A = [prob_next_state, poss_next_state];
  %   Action = ["Stay", "Right", "Up", "Left", "Down"];
cum_prob = 0;
for i =1: length(poss_next_state)
    cum_prob = cum_prob + A(i,1);
if x<cum_prob
    next_state = A(i,2);
    break;
end 
end 
