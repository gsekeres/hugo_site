% BYTE1_CODE: Code examples from byte1 lecture on floating point arithmetic. 
%
% Notes:
% - Good commenting habits make your code so much better, and saves you time in the long run.
% - This is a matlab script, which distinct from a function
% - To run this code in the command line, type command+enter (on a mac)
% - lines that end with a ';' will not print to screen. Otherwise, the output will print

% A big number with 4 significant digits
big = 1.342e36;

% A small number with 3 signficant digits
small = 4.66e-21;

% When I add big numbers togther, it works...
ok_big = big + big

% And when I add small numbers together, it works.
ok_small = 2*small - small

% But if I add big and small togher, funny things can happen:
big_p_small = (big + small);
woops = big_p_small-big


%Before going on, I want the screent to show more decimals. So I call 
format long


% In floating point math, the constraint is number of significant digits.
% To get a sense of precesions at different order of magnitude, eps command
% is useful.  
eps(0)

eps(1)

eps(10000)

% If you are unsure of how to use a program call e.q. 
% >> help eps
% in the command line