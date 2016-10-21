
Core profiler results
======================

Total objects                 62 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.8 seconds (84.8%)
    Compiler                 0.0 seconds (2.4%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.0%)
  Model time                 0.2 seconds/thread (15.2%)
Simulation time                1 days
Simulation speed             1.4k object.hours/second
Passes completed             182 passes
Time steps completed          89 timesteps
Convergence efficiency      2.04 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep            890 seconds/timestep
Simulation rate           79200 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
node               0.122     80.3%     30.5
overhead_line      0.008      5.3%      0.9
load               0.007      4.6%      0.6
recorder           0.003      2.0%      1.5
inverter           0.003      2.0%      3.0
underground_line   0.002      1.3%      1.0
currdump           0.002      1.3%      2.0
meter              0.001      0.7%      0.5
regulator          0.001      0.7%      1.0
switch             0.001      0.7%      1.0
player             0.001      0.7%      0.3
battery            0.001      0.7%      1.0
================ ======== ======== ========
Total              0.152    100.0%      2.5

