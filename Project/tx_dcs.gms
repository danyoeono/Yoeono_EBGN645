* Texas Data Center Optimization Model
* Based on the R code formulation

* ==========================================
* 1. SETS AND INDICES
* ==========================================
Sets
    i   'Potential Data Center Locations' / Dallas, Houston, Austin, SanAntonio /
    j   'Demand Regions'                  / Dal_Reg, Hou_Reg, Aus_Reg, SA_Reg, ElPaso, Lubbock, CC /
    k   'Data Center Sizes'               / Small, Medium, Large /;

* ==========================================
* 2. PARAMETERS AND DATA
* ==========================================
Parameters
    demand(j) 'Required compute units per region'
    / Dal_Reg 800, Hou_Reg 1000, Aus_Reg 600, SA_Reg 600, ElPaso 300, Lubbock 200, CC 300 /

    powerDemand(k) 'Electricity capacity required (MW)'
    / Small 10, Medium 25, Large 50 /

    capacity(k) 'Max compute units per size'
    / Small 400, Medium 900, Large 1500 /

    elecRate(i) 'Variable electricity rate ($ per MW)'
    / Dallas 50, Houston 55, Austin 48, SanAntonio 52 /

    latencyPenalty 'Cost per mile per unit shipped' / 0.05 /;

Scalar M 'Big M for linking constraints (Total Demand)';
M = sum(j, demand(j));

* Fixed Table alignment to prevent "Overlapping row name" error
Table distance(i, j) 'Distance matrix (miles)'
                   Dal_Reg  Hou_Reg  Aus_Reg  SA_Reg  ElPaso  Lubbock  CC
    Dallas           10      240      195      275     635     345    410
    Houston         240       10      165      197     745     520    210
    Austin          195      165       10       80     575     375    220
    SanAntonio      275      197       80       10     550     410    145;

* ==========================================
* 3. VARIABLES
* ==========================================
Binary Variables
    od(i, k) '1 if DC at location i is built with size k'
    oa(i, j) '1 if DC i ships to region j';

Positive Variable
    flow(i, j) 'Amount of compute units shipped from i to j';

Variable
    z        'Total Cost (Objective Function)';

* ==========================================
* 4. EQUATIONS
* ==========================================
Equations
    ObjFunction      'Minimize Total Cost'
    DemandSat(j)     'Demand satisfaction constraint'
    CapacityCon(i)   'Capacity constraint at each DC'
    OneSizeCon(i)    'At most one size per location'
    LinkFlow(i, j)   'Link flow to route opening (oa)'
    LinkOpen(i, j)   'Link route opening (oa) to DC existence (od)';

* ==========================================
* 5. EQUATION DEFINITIONS
* ==========================================

* Objective: Min Sum(Variable Elec) + Sum(Latency Cost)
ObjFunction..
    z =e= sum((i, k), elecRate(i) * powerDemand(k) * od(i, k))
        + sum((i, j), latencyPenalty * distance(i, j) * flow(i, j));

* 1. Demand Satisfaction: Each region must receive required demand
DemandSat(j)..
    sum(i, flow(i, j)) =e= demand(j);

* 2. Capacity: Flow out of i cannot exceed capacity of chosen size
CapacityCon(i)..
    sum(j, flow(i, j)) =l= sum(k, capacity(k) * od(i, k));

* 3. One Size Per Location: Can't build Small AND Large at same site
OneSizeCon(i)..
    sum(k, od(i, k)) =l= 1;

* 4. Link Flow to oa: if flow > 0, then oa must be 1
LinkFlow(i, j)..
    flow(i, j) =l= M * oa(i, j);

* 5. Link oa to od: Can't ship from i if no DC exists at i
LinkOpen(i, j)..
    oa(i, j) =l= sum(k, od(i, k));

* ==========================================
* 6. MODEL AND SOLVE
* ==========================================
Model TexasDC /all/;

Solve TexasDC using MIP minimizing z;

* ==========================================
* 7. DISPLAY RESULTS
* ==========================================
* Define a parameter to hold a clean report of built locations
Parameter Report_Build(i, k);
Report_Build(i, k) = od.l(i, k);

* Define a parameter to show active flows
Parameter Report_Flow(i, j);
Report_Flow(i, j) = flow.l(i, j);

Display Report_Build, Report_Flow, z.l;

* ==========================================
* 8. GDX EXPORT
* ==========================================
* Dump the reporting parameters and objective value to a GDX file
execute_unload "texas_results.gdx", Report_Build, Report_Flow, z;