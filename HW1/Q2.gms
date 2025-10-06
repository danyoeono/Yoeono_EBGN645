option PROFILE=1
set j "jellybeans" /yellow,blue,green,orange,purple/ ; 
*jellybean color
set i "machines" /X1,X2/ ;
*machine 1 and 2
set v(i,j) "Valid combos of machines of jellybeans"

alias (j, jj)

parameter
r(j) "--Net Revenue ($/bean)"
/
yellow 1,
blue 1.05,
green 1.07,
orange 0.95,
purple 0.9,
/

v(i,j) = yes ;

scalar
hbar "--hours-- total hours in a week" /40/ ,
mbar "--beans-- total amount of beans per hour" /100/ ,
wkbar "--Max prod per machine per week in jellybeans" ;

wkbar = hbar * mbar;

equation
eq_objfn "target of optimization"
eq_hourlimit "no more than 40 hours per week"\
eq_machinelimit "no more than 100 jb's per hour"

eq_objfn.. Z =e= sum((i,j)$v(i,j), r(j) * X(i,j)) ;

eq_hourlimit(i).. hbar * h =g= sum(j,X(i,j)) ;

eq_machinelimit(i).. 

model june /all/;

sw_maxdev =0 ; 
solve june using lp maximizing Z;

sw_maxdev =1 ;
solve june using lp maximizing Z;
