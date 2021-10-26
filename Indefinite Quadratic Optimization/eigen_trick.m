function [A, B] = eigen_trick(P)
% Decomposes the given matrix as the difference of two PSD matrices (A, B)
[V,D] = eig(P);
V = real(V); D = real(D);
[~,ind] = sort(diag(D), 'descend');
k = sum(diag(D)>=0); %number of nonzero elements
D = D(ind,ind);
V  = V(:,ind);

D_plus_diag = diag(D);
D_plus_diag(k+1:end) = 0;
D_plus = diag(D_plus_diag);


D_minus_diag = diag(D);
D_minus_diag(1:k) = 0;
D_minus = diag(-D_minus_diag);

A = V*D_plus*V';
B = V*D_minus*V';
end