function [rlt, rltsdp, our, D, Q] = optim(n)
%% Generate Data
k = 3;        %cube's size, we use 3 in the paper, but this can be changed here
n = max(n,k); %in case n = 3 is given, as y has size 3 and x has size >= 0
D = diag(rand(n,1)*10);  %diagonal matrix
[Q,~] = qr(randn(n));   %uniform rotation matrix
L = D*Q;                
L1 = L(:, 1:n-k);       %to decompose 
L2 = L(:, n-k+1:n);     %same
%% Constraints  %x>=0, sum(x) <= 1, sum(x) >-1, y <= 1, y >= -1 (in order)
%These matrices will be useful to define our objective functions and
%constraints in compact forms
A = [-eye(n-k) zeros(n-k, k); ones(1, n-k) zeros(1, k); - ones(1, n-k) zeros(1, k); zeros(k,n-k) eye(k);zeros(k,n-k) -eye(k)];
b = [zeros(n-k,1); 1; -1; ones(k,1); ones(k,1)]; %original constraints will be written as Ax <= b, where the constraint
% for the first k variables will define a hypercube and the remaining n-k
% will give a simplex.
TX = [eye(n-k) zeros(n-k,k)]; %multiply TX by x -> x(1:n)
TY = [zeros(k,n-k) eye(k)]; %multiply TX by x -> x(1:n)
MX = [eye(n-k) zeros(n-k,k)]; 
MY = [zeros(k, n -k) eye(k)];
%% RLT
%In the paper we use 'y' for the variable that resides in a hypercube as
%well as 'x' for the variable that resides in a simplex. However, for
%compactness, here we only use 'x' and append those two variables.
%Therefore, in the following we will use some algebra to compactly
%represent this problem without using different variable names separately.
x = sdpvar(n,1); %decision vector
X = sdpvar(n);   %decision matrix
Constraints = [A*x <= b]; %original constraints
for j=1:size(A,1) %RLT constraints
    Constraints = [Constraints, A(1:j,:)*X*A(j,:)' - (b(1:j)*A(j,:) + b(j)*A(1:j,:))*x + b(1:j)*b(j) >=0]; 
end
Objective = trace(L1'*L1*(MX*X*MX')) + trace(L2'*L2*(MY*X*MY')) +  2*trace(L2'*L1*(MX*X*MY')) ... 
    -(2/(n-k))*ones(1,n-k)*L1'*L2*(TY*x) - (2/(n-k))*(TX*x)'*L1'*L1*ones(n-k,1) + (1/(n-k)^2)*ones(1,n-k)*L1'*L1*ones(n-k,1) ...
    + (1/(n-k))*sum(log(TX*x)) + sum(log(1 + TY*x) + log(1 - TY*x)); %the objective of the LRT
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0)); %Solve via MOSEK
rlt = [value(Objective), Sol.solvertime]; %save the solution
%% RLT/SDP
Constraints = [Constraints, [X, x; x' 1] >= 0]; %RLTSDP only appends the LMI constraint
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0));
rltsdp = [value(Objective), Sol.solvertime]; %save the solution
%% our method
yalmip clear;
% find vertices first
v_simplex = eye(n-k);
v_cube = 2*(dec2bin(0:2^k-1)-'0') - 1; %decimal representation of every nr *2 -1
[mm,nn]=ndgrid(1:n-k,1:2^k);
V = [v_simplex(mm,:),v_cube(nn,:)]; V = V'; %all vertices
% solve problem
x = sdpvar(2^k * (n-k), 1); %exponentially many varialbes for the 'y' vector (the one that resides in a hypercube)
% and n-k many variables for the rest
Constraints = [x >= 0, sum(x) == 1]; %simplex constraints as we now reformulated
Objective = trace(L1'*L1*(MX*V*diag(x)*V'*MX')) + trace(L2'*L2*(MY*V*diag(x)*V'*MY')) +  trace(2*L2'*L1*(MX*V*diag(x)*V'*MY')) ... 
    -(2/(n-k))*ones(1,n-k)*L1'*L2*(TY*V*x) - (2/(n-k))*(TX*V*x)'*L1'*L1*ones(n-k,1) + (1/(n-k)^2)*ones(1,n-k)*L1'*L1*ones(n-k,1) ...
    + (1/(n-k))*sum(log(TX*V*x)) + sum(log(1 + TY*V*x) + log(1 - TY*V*x)); %objective function after analytically replacing the matrix
Sol = optimize(Constraints, -Objective, sdpsettings('solver', 'mosek', 'verbose', 0)); %solve via MOSEK
our = [value(Objective), Sol.solvertime]; %save the solution
end