% Main optimization function called in the experiments
function [rlt, rltsdp, our, D, Q] = optim(n)
% Generate data as explained in Section 3
D = diag(rand(n,1)*10);  %diagonal matrix
[Q,~] = qr(randn(n));    %uniform rotation matrix (see the relevant citations in the paper)
L = D*Q;            
ep = 10^(-10);          %almost 0 -- to deal with rounding
%% RLT
x = sdpvar(n,1); % YALMIP variable x
X = sdpvar(n);   % YALMIP variable X (matrix)
Mat = L'*L;      % Objective function can be simplified after this definition
Objective = X(:).'*reshape(Mat.',[],1) - (2/n)*x'*Mat*ones(n,1) + (1/n^2)*ones(1,n)*Mat*ones(n,1)+ (1/n)*sum(ep + log(x)); %objective
Constraints = [X(:) >= 0, x >=0, sum(x)==1, sum(X,2) == x]; %RLT constraints resulting from the original simplex
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek','verbose',0)); %Optimize via MOSEK
rlt = [value(Objective) Sol.solvertime]; %save the approximation and the solvertime
%% RLTSDP
Constraints = [Constraints, [X, x; x', 1]>= 0]; %same as before + the psd cut constraint. We proved this will not be tighter than RLT.
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek','verbose',0)); %Optimize via MOSEK
rltsdp = [value(Objective) Sol.solvertime]; %save the approximation and the solvertime
%% Our approach
yalmip clear; %clear as we will need to change the structure of the optimization problem (e.g., X is not needed)
x = sdpvar(n,1); %only 'n' variables
Objective = diag(Mat)'*x - (2/n)*x'*Mat*ones(n,1) + (1/n^2)*ones(1,n)*Mat*ones(n,1) + (1/n)*sum(ep + log(x)); %objective if we replace X = diag(x)
Constraints = [x>=0, sum(x) == 1]; %simplex constraints
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek','verbose',0)); %Optimize via MOSEK
our = [value(Objective), Sol.solvertime]; %save our proposed approximation and the solvertime
end