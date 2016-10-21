
Core profiler results
======================

Total objects                 14 objects
Parallelism                    1 thread
Total time                   4.0 seconds
  Core time                  0.7 seconds (16.8%)
    Compiler                 0.1 seconds (1.9%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.1%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.3%)
  Model time                 3.3 seconds/thread (83.2%)
Simulation time              365 days
Simulation speed              31k object.hours/second
Passes completed           35041 passes
Time steps completed       35041 timesteps
Convergence efficiency      1.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep            900 seconds/timestep
Simulation rate         7884000 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
triplex_meter      2.487     74.7%   1243.5
player             0.247      7.4%    123.5
solar              0.200      6.0%    200.0
climate            0.182      5.5%    182.0
inverter           0.168      5.0%    168.0
complex_assert     0.031      0.9%     31.0
double_assert      0.015      0.5%     15.0
================ ======== ======== ========
Total              3.330    100.0%    237.9

