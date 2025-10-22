*Simple Data Center Location Optimization

Sets
    i   'Potential data center locations'   / SiteA, SiteB, SiteC, SiteD /
    j   'Customer demand zones'             / City1, City2 /
    k   'Data center sizes'                 / Small, Medium, Large /;


Parameters
    capitalCost(i, k) 'Capital cost to build DC (in millions)' /
        SiteA.Small   100, SiteA.Medium  200, SiteA.Large  350
        SiteB.Small   100, SiteB.Medium  200, SiteB.Large  350
        SiteC.Small   120, SiteC.Medium  220, SiteC.Large  380
        SiteD.Small   120, SiteD.Medium  220, SiteD.Large  380 /

    gridCapacity(i) 'Available grid power (MW)' /
        SiteA 50
        SiteB 100
        SiteC 150
        SiteD 80 /

    powerDemand(k) 'Power demand per DC size (MW)' /
        Small  20
        Medium 45
        Large  80 /

    waterAvailability(i) 'Available water (megaliters/yr)' /
        SiteA 150
        SiteB 300
        SiteC 500
        SiteD 200 /

    waterDemand(k) 'Water demand per DC size (megaliters/yr)' /
        Small  50
        Medium 120
        Large  250 /

    maxLatency(j) 'Max allowed latency per city (ms)' /
        City1  20
        City2  22 /

    demand(j) 'Customer demand (compute units)' /
        City1 1000
        City2 1500 /

    capacity(k) 'DC capacity (compute units)' /
        Small   800
        Medium 1800
        Large  3000 /;

Table latency(i, j) 'Latency from site to city (ms)'
          City1  City2
    SiteA  10     25
    SiteB  15     20
    SiteC  22     8
    SiteD  30     12 ;


Positive Variable
    x(i, k) 'FRACTION of DC size k built at site i (0 <= x <= 1)'
    y(i, j) 'Fraction of demand from city j served by site i';

Variable
    TotalCost 'Total upfront capital cost of the network';

Equations
    CostFunction            'Objective: Minimize total upfront capital cost'
    DemandSatisfaction(j)   'Ensure all customer demand is met'
    DataCenterCapacity(i)   'A site cannot serve more demand than its (fractional) capacity'
    OneSizePerLocation(i)   'Total fraction built at a site cannot exceed 1'
    GridLimit(i)            'Power usage must not exceed grid capacity'
    WaterLimit(i)           'Water usage must not exceed availability'
    LatencySLA(i,j)         'Ensure service latency is within acceptable limits'
    
* Add an upper bound constraint for x 
    X_UpperBound(i, k)      'Ensure build fraction x is not greater than 1';



CostFunction.. TotalCost=e=
    sum((i, k), capitalCost(i, k) * x(i, k));

DemandSatisfaction(j)..
    sum(i, y(i, j)) =e= 1;


DataCenterCapacity(i)..
    sum(j, y(i, j) * demand(j)) =l= sum(k, capacity(k) * x(i, k));


OneSizePerLocation(i)..
    sum(k, x(i, k)) =l= 1;


GridLimit(i)..
    sum(k, powerDemand(k) * x(i, k)) =l= gridCapacity(i);

WaterLimit(i)..
    sum(k, waterDemand(k) * x(i, k)) =l= waterAvailability(i);


LatencySLA(i,j)$(latency(i,j) > maxLatency(j))..
    y(i,j) =e= 0;


X_UpperBound(i,k)..
    x(i,k) =l= 1;



Model DataCenterLocator /all/;


Solve DataCenterLocator using LP minimizing TotalCost;


Parameter BuildPlan(i, k) 'Final build plan (fractional or full)';

BuildPlan(i, k) = x.l(i, k)$(x.l(i, k) > 0.001);

Display BuildPlan, TotalCost.l;


Display y.l;

execute_unload 'dc_simp.gdx';
