% BYTE2_CODE: Code examples from byte2 lecture on linear algebra in matlab 
%
% Notes:
% - \ is a generalization of inv(.) that has lots of uses
% - in practice, \ commenad beats inv(.) by a mile
% - matlab expands some matrix operations, so that non-conformable statements might not create errors
% - vectorization is a way to write compact code, and sometimes a lot faster

%% I use %% to create code cells, each of which can be evaluated with command-enter (on a mac, pc shortcuts similar)
%
% EQUATION SOLVING AND LEAST SQUARES

% A nice matrix that is invertible
X = [1 2; 3 4];

% Some nice Y values
Y = [6;16];

% System Y = X*b is exactly identified. Several ways to solve  for b
b = inv(X)*Y
b = X\Y
b = inv(X'*X)*(X'*Y)

% But we can extended X so that the system is over-identifed -> this
% corresponds to a regression with more observations than RHS variables

X = [X; 5 6];  %This is called "appending a matrix"
Y = [Y;27];

%b = inb(X)*Y; This command no longer works

b = X\Y       %\ is doing OLS to find the closes thing to a solution

b = inv(X'*X)*(X'*Y)  % Standard OLS formula is not numerically efficient


%% AUTOMATIC EXPANSION
%
% Matlab (since roughly 2007) will expand matrices in specific ways.
% This is convenient, but could cause problems because non-conformable
% calculations might not causes errors.

A = [1 2 3];  % A row 

B = [1;2;4];  % A column


%Automatic Expansion
A*B   %Row-times-column, works as expected


B*A  %Column times row, matlab repeats a cols and rows to make it work


%% DOT PRODUCTS AND VECTORIZATION
A = [1 2 3];  % A row 

B = [1;2;4];  % A column

B = reshape(B,size(A));  %Reshape B, so A and B have same dimensions

%Method 1 for element-wise mult
ABtimes1 = zeros(size(A)); %This is an initlization, do before any loop
for jj = 1:3
   ABtimes1(jj) = A(jj)*B(jj);
end
ABtimes1

%Method 2 for element-wise mult: this is called vectorization
ABtimes2 = A.*B


%%
%Vectorization can save a lot of time, though matlab has speed up loops a
%lot in recent releases.

A = linspace(1,10,50000);  % A long vector
B = linspace(4,12,50000);  % Another long vector

%Method 1 (tic-toc used time segment of code)
tic;              
ABtsum1 = 0;
for jj = 1:50000
   ABtsum1 =  ABtsum1+A(jj)*B(jj);
end
ABtsum1
t1 = toc;

%Mehtod 2
tic
ABtsum2 = sum(A.*B)
t2 = toc;

%Time savings: ~1/2 the time
t2/t1

