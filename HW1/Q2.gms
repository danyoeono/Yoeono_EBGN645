option PROFILE=1
set j "jellybeans" /yellow,blue,green,orange,purple/ ; 
*jellybean color
set i "machines" /X1,X2/ ;
*machine 1 and 2
set v(i,j) "Valid combos of machines of jellybeans";

alias (j, jj) ;

parameters
r(j) "--Net Revenue ($/bean)"
/
yellow 1,
blue 1.05,
green 1.07,
orange 0.95,
purple 0.9
/ ;

*for part b-c
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

*part b
model juneb /eq_objfn, eq_cap/;

*part C
Equations
    eq_prodlimit_upper(j,jj) 'Production of j is at most 1.05x production of jj',
    eq_prodlimit_lower(j,jj) 'Production of j is at least 0.95x production of jj';

* The total production of color j must be <= 1.05 times the production of color jj
eq_prodlimit_upper(j,jj).. SUM(i, X(i,j)) =l= 1.05 * SUM(i, X(i,jj));

* The total production of color j must be >= 0.95 times the production of color jj
eq_prodlimit_lower(j,jj).. SUM(i, X(i,j)) =g= 0.95 * SUM(i, X(i,jj));

model junec /eq_objfn, eq_cap, eq_prodlimit_upper, eq_prodlimit_lower/ ;

model juned /eq_objfn, eq_cap, eq_prodlimit_upper, eq_prodlimit_lower/ ;

*sw_maxdev =0 ; 
solve juneb using lp maximizing Z;

execute_unload 'juneb.gdx' ;

*sw_maxdev =1 ;
solve junec using lp maximizing Z;

execute_unload 'junec.gdx' ;

*sw_maxdev =2 ;
v(i,j) = yes ;
v("X1","yellow") = yes ;
v("X1","blue") = yes ;
v("X1","green") = yes ;
v("X1","orange") = no ;
v("X1","purple") = no ;
v("X2","yellow") = yes ;
v("X2","blue") = no ;
v("X2","green") = no ;
v("X2","orange") = yes ;
v("X2","purple") = yes ;

solve juned using lp maximizing Z;

execute_unload 'juned.gdx' ;

*problems: part c is producing decimal aamounts of beans, part d is breaking the wkbar constraint