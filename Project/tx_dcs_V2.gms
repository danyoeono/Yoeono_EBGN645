* Texas Data Center Optimization Model - Linear Version (LP)
* This model optimizes capacity continuously rather than in discrete steps.
* --- VERSION: NO CAPITAL COSTS ---

* ==========================================
* 1. SETS AND INDICES
* ==========================================
Sets
    i   'Potential Data Center Locations' / Dallas, Houston, Austin, SanAntonio /
    j   'Demand Regions'                  / Dal_Reg, Hou_Reg, Aus_Reg, SA_Reg, ElPaso, Lubbock, CC /;

* ==========================================
* 2. PARAMETERS AND DATA
* ==========================================
Parameters
    demand(j) 'Required compute units per region'
    / Dal_Reg 800, Hou_Reg 1000, Aus_Reg 600, SA_Reg 600, ElPaso 300, Lubbock 200, CC 300 /

    elecRate(i) 'Variable electricity rate ($ per MW)'
    / Dallas 50, Houston 55, Austin 48, SanAntonio 52 /

    latencyPenalty 'Cost per mile per unit shipped' / 0.05 /;

* Linearized Costs
* Note: Capital Cost has been removed from this version.

* Large Power (50MW) / Large Cap (1500) = ~0.0333
Scalar unitPower 'MW required per unit of compute capacity' / 0.0333 /;

Table distance(i, j) 'Distance matrix (miles)'
                   Dal_Reg  Hou_Reg  Aus_Reg  SA_Reg  ElPaso  Lubbock  CC
    Dallas           10      240      195      275     635     345    410
    Houston         240       10      165      197     745     520    210
    Austin          195      165       10       80     575     375    220
    SanAntonio      275      197       80       10     550     410    145;

* ==========================================
* 3. VARIABLES
* ==========================================
Positive Variables
    capacityBuilt(i) 'Exact size of DC built at location i (Continuous)'
    flow(i, j)       'Amount of compute units shipped from i to j';

Variable
    z                'Total Cost (Objective Function)';

* ==========================================
* 4. EQUATIONS
* ==========================================
Equations
    ObjFunction      'Minimize Total Linear Cost'
    DemandSat(j)     'Demand satisfaction constraint'
    CapacityCon(i)   'Production cannot exceed built capacity';

* ==========================================
* 5. EQUATION DEFINITIONS
* ==========================================

* Objective: 
* 1. Linear Power Cost (ElecRate * UnitPower * Size)
* 2. Latency Cost (Penalty * Dist * Flow)
* Note: Capital Cost term removed.
ObjFunction..
    z =e= sum(i, elecRate(i) * unitPower * capacityBuilt(i))
        + sum((i, j), latencyPenalty * distance(i, j) * flow(i, j));

* 1. Demand Satisfaction: Each region must receive required demand
DemandSat(j)..
    sum(i, flow(i, j)) =e= demand(j);

* 2. Capacity Constraint: The total flow leaving i must be supported by built capacity
CapacityCon(i)..
    sum(j, flow(i, j)) =l= capacityBuilt(i);

* ==========================================
* 6. MODEL AND SOLVE
* ==========================================
Model TexasLinear /all/;

* Solved using Linear Programming (LP)
Solve TexasLinear using LP minimizing z;

* ==========================================
* 7. DISPLAY RESULTS
* ==========================================
Parameter Report_Build(i);
Report_Build(i) = capacityBuilt.l(i);

Parameter Report_Flow(i, j);
Report_Flow(i, j) = flow.l(i, j);

Display Report_Build, Report_Flow, z.l;

* Export to GDX for analysis
execute_unload "texas_linear_results.gdx", Report_Build, Report_Flow, z;