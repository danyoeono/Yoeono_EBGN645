option PROFILE=1
set j "jellybeans" /yellow,blue,green,orange,purple/ ; 
*jellybean color
set i "machines" /X1,X2/ ;
*machine 1 and 2
v(i,j) "Valid combos of machines of jellybeans"

alias (i,ii)




equation
eq

eq_objfn.. Z =e= sum((i,j)$v(i,j), r(j) * X(i,j)) :

eq_hourliimit(i)).. hbar * h =g= sum(j,X(i,j)) :

model june /all/;
sw_maxdev