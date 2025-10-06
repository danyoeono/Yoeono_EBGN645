option PROFILE=1
set j "jellybeans" /yellow,blue,green,orange,purple/ ; 
*jellybean color
set i "machines" /X1,X2/ ;
*machine 1 and 2
v(i,j) "Valid combos of machines of jellybeans"

alias (i,ii)

parameter
r(j) "--Net Revenue ($/bean)"

v(i,j) = yes ;




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
