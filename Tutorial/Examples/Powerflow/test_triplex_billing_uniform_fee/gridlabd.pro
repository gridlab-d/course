
Core profiler results
======================

Total objects                 20 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.9 seconds (92.2%)
    Compiler                 0.0 seconds (2.4%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.3%)
  Model time                 0.1 seconds/thread (7.8%)
Simulation time               89 days
Simulation speed              43k object.hours/second
Passes completed            4335 passes
Time steps completed        2198 timesteps
Convergence efficiency      1.97 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep           3498 seconds/timestep
Simulation rate         7689600 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
node               0.021     26.9%     21.0
triplex_meter      0.015     19.2%     15.0
transformer        0.011     14.1%     11.0
overhead_line      0.009     11.5%      9.0
meter              0.008     10.3%      8.0
stubauction        0.005      6.4%      5.0
player             0.004      5.1%      4.0
recorder           0.003      3.8%      3.0
double_assert      0.002      2.6%      0.2
================ ======== ======== ========
Total              0.078    100.0%      3.9

