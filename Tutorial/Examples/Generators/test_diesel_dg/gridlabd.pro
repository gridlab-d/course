
Core profiler results
======================

Total objects                 13 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.9 seconds (92.9%)
    Compiler                 0.0 seconds (2.8%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.1%)
  Model time                 0.1 seconds/thread (7.1%)
Simulation time               27 days
Simulation speed             8.4k object.hours/second
Passes completed             649 passes
Time steps completed         649 timesteps
Convergence efficiency      1.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep           3594 seconds/timestep
Simulation rate         2332800 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
meter              0.048     67.6%     48.0
triplex_meter      0.005      7.0%      5.0
triplex_line       0.005      7.0%      5.0
recorder           0.005      7.0%      2.5
transformer        0.002      2.8%      2.0
triplex_node       0.002      2.8%      2.0
diesel_dg          0.002      2.8%      2.0
player             0.002      2.8%      2.0
================ ======== ======== ========
Total              0.071    100.0%      5.5

