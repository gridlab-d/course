
Core profiler results
======================

Total objects                 72 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.5 seconds (52.6%)
    Compiler                 0.0 seconds (3.2%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.1%)
  Model time                 0.5 seconds/thread (47.4%)
Simulation time                1 days
Simulation speed             1.6k object.hours/second
Passes completed             366 passes
Time steps completed         133 timesteps
Convergence efficiency      2.75 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep            595 seconds/timestep
Simulation rate           79200 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
node               0.399     84.2%    133.0
load               0.022      4.6%      2.0
overhead_line      0.011      2.3%      1.2
meter              0.008      1.7%      2.0
switch             0.007      1.5%      7.0
player             0.006      1.3%      0.9
inverter           0.006      1.3%      3.0
underground_line   0.003      0.6%      1.5
regulator          0.003      0.6%      3.0
recorder           0.003      0.6%      0.8
battery            0.003      0.6%      1.5
voltdump           0.002      0.4%      2.0
currdump           0.001      0.2%      1.0
================ ======== ======== ========
Total              0.474    100.0%      6.6

