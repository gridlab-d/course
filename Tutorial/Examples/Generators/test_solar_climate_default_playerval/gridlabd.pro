
Core profiler results
======================

Total objects                 17 objects
Parallelism                    1 thread
Total time                   2.0 seconds
  Core time                  1.1 seconds (55.9%)
    Compiler                 0.0 seconds (1.2%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.0%)
  Model time                 0.9 seconds/thread (44.1%)
Simulation time              365 days
Simulation speed              74k object.hours/second
Passes completed            8760 passes
Time steps completed        8760 timesteps
Convergence efficiency      1.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep           3600 seconds/timestep
Simulation rate         15766200 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
triplex_meter      0.642     72.8%    321.0
player             0.102     11.6%     25.5
solar              0.078      8.8%     39.0
inverter           0.049      5.6%     49.0
complex_assert     0.009      1.0%      4.5
double_assert      0.002      0.2%      2.0
================ ======== ======== ========
Total              0.882    100.0%     51.9

