function [rlt, rltsdp, our, Q] = optim(n, type)
%% data generate
if type == 1
    eigenvals = rand(n,1)*n - 3*n/4; %sample eigenvalues uniformly -- type 1
else
    eigenvals = rand(n,1)*n - n/2;   %sample eigenvalues uniformly -- type 2
end
D = diag(eigenvals);               %diagonal matrix
[R,~] = qr(randn(n));              %uniform rotation matrix (same as before)
Q = R*D*R';                        %matrix is similarly
[Qplus, Qminus] = eigen_trick(Q);  %decomposition, Qplus, Qminus are both psd and Qplus - Qminus = Q in our setting

%% RLT
x = sdpvar(n,1); %decision vector
X = sdpvar(n);   %decision matrix
Objective = Q(:)'*X(:); %objective function (linearizing via X)
Constraints = [x>=0, sum(x) == 1, sum(X,2) == x, X(:) >= 0]; %RLT constraints
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0)); %solve via MOSEK
rlt = [value(Objective), Sol.solvertime]; %save the solution
%% RLT/SDP
Constraints = [Constraints, [X, x; x', 1] >= 0]; %extra LMI
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0)); %solve via MOSEK
rltsdp = [value(Objective), Sol.solvertime]; %save the solution
%% Our approach
yalmip clear;    %clear variables
x = sdpvar(n,1); %decision vector
Objective = diag(Qplus)'*x - x'*Qminus*x ; %rewrite the objective -- first part is linearized and X = diag(x) is used
Constraints = [x>=0, sum(x) == 1]; %simplex constraints
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0)); %solve the problem
our = [value(Objective), Sol.solvertime]; %save the solution
end