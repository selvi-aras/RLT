% Main optimization function used in the first experiments of Appendix B.1
function [rlt, rltsdp, our, D, Q] = optim(n , rhs)
%% Generate daa
rhs = 1; %delete this if you would like to use a different rhs
D = diag(rand(n,1)*1);  %diagonal matrix -- same as we used in Main/optim.m
[Q,~] = qr(randn(n));   %uniform rotation matrix
L = D*Q;                
%% RLT (traditional)
x = sdpvar(n,1); %decision vector
X = sdpvar(n);   %decision matrix
Mat = L'*L;      %L'*L is the only information we need of L in the objective
Objective = X(:).'*reshape(Mat.',[],1) +  (sum(log(rhs-x)) + sum(log(rhs+x))); %Objective of RLT
Constraints = [x(:) <= rhs, x(:) >= -rhs]; %hypercube constraints (original)
for i=1:n %add RLT constraints below
    for j=1:n
        Constraints = [Constraints, X(i,j) - rhs*(x(i) + x(j)) + rhs^2 >=0, ...
        -X(i,j) - rhs*(x(i) - x(j)) + rhs^2 >=0, X(i,j) + rhs*(x(i) + x(j)) + rhs^2 >=0];
    end
end %note: the above RLT constraint generation can be improved for the hypercube case, this is a generic one
            %but it does not matter as we save the solver times, not the
            %problem formulation times
Sol = optimize(Constraints, -Objective, sdpsettings('solver','mosek','verbose', 0)); %optimize by using MOSEK
rlt(1) = value(Objective); rlt(2) = Sol.solvertime; %save the relaxation and the solver time
%% RLTSDP (traditional)
Constraints = [Constraints, [X, x; x', 1]>= 0]; %same as before + the psd cut constraint. This may be tighter than RLT.
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek','verbose',0)); %Optimize via MOSEK
rltsdp(1) = value(Objective); rltsdp(2) = Sol.solvertime; %save the approximation and the solvertime
yalmip clear;
%% Our method
x = sdpvar(2^n,1); %decision vector has the size of the extreme points of the hypercube
V = 2*rhs*(dec2bin(0:2^n-1)-'0') - rhs; %decimal representation of every nr *2 -1 -- for the vertices
V = V'; %transpose, since a column is an extreme point
M = V'*L';
Objective = sum(M.*M,2)'*x +  (sum(log(rhs-V*x)) + sum(log(rhs+V*x))); %objective function
Constraints = [x >= 0, sum(x) == 1]; %constraints are now just simplex
Sol = optimize(Constraints, -Objective, sdpsettings('solver','mosek', 'verbose', 0)); %Optimize via MOSEKs
our(1) = value(Objective); our(2) = Sol.solvertime; %save our solution
end

