
Core profiler results
======================

Total objects                 20 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.9 seconds (91.1%)
    Compiler                 0.0 seconds (2.2%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.1%)
  Model time                 0.1 seconds/thread (8.9%)
Simulation time               89 days
Simulation speed              43k object.hours/second
Passes completed            4274 passes
Time steps completed        2137 timesteps
Convergence efficiency      2.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep           3598 seconds/timestep
Simulation rate         7689600 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
recorder           0.019     21.3%     19.0
triplex_meter      0.019     21.3%     19.0
overhead_line      0.014     15.7%     14.0
meter              0.011     12.4%     11.0
node               0.009     10.1%      9.0
transformer        0.008      9.0%      8.0
stubauction        0.008      9.0%      8.0
double_assert      0.001      1.1%      0.1
================ ======== ======== ========
Total              0.089    100.0%      4.5

