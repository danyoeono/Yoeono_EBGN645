option PROFILE=1
set j "jellybeans" /yellow,blue,green,orange,purple/ ; 
*jellybean color
set i "machines" /X1,X2/ ;
*machine 1 and 2
set v(i,j) "Valid combos of machines of jellybeans";

alias (j, jj) ;

parameter
r(j) "--Net Revenue ($/bean)"
/
yellow 1,
blue 1.05,
green 1.07,
orange 0.95,
purple 0.9,
/

*for part D
v(i,j) = yes ; 

scalar
hbar "--hours-- total hours in a week" /40/ ,
mbar "--beans-- total amount of beans per hour" /100/ ,
wkbar "--Max prod per machine per week in jellybeans" ;

wkbar = hbar * mbar;

*Variables
positive variable X(i,j) 'Quantity of beans color j produced on machine i' ;

variable Z 'Total net revenue' ;


equation
eq_objfn "maximize total revenue"
*eq_hourlimit "no more than 40 hours per week"
*eq_machinelimit "no more than 100 jb's per hour"
eq_cap(i) "Machine Capacity in a week constraint" ;

eq_objfn.. Z =e= sum((i,j)$v(i,j), r(j) * X(i,j)) ;

eq_cap(i).. wkbar =g= sum(j$v(i,j), X(i,j));

*eq_hourlimit(i).. hbar * h =g= sum(j,X(i,j)) ;
*eq_machinelimit(i).. wkbar =g= sum(j$v(i,j), X(i,j)) ;

*part b
model juneb /eq_objfn, eq_cap/;

*part C
Equations
    eq_ProdLimit_Upper(j,jj) 'Production of j is at most 1.05x production of jj',
    eq_ProdLimit_Lower(j,jj) 'Production of j is at least 0.95x production of jj';
model junec /   / ;
model juned /   / ;

*sw_maxdev =0 ; 
solve juneb using lp maximizing Z;

*sw_maxdev =1 ;
*solve junec using lp maximizing Z;

*sw_maxdev =2 ;
*solve juned using lp maximinzing Z;