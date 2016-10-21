
Core profiler results
======================

Total objects                325 objects
Parallelism                    1 thread
Total time                   1.0 seconds
  Core time                  0.9 seconds (94.0%)
    Compiler                 0.0 seconds (2.7%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.0%)
  Model time                 0.1 seconds/thread (6.0%)
  Deltamode time             0.0 seconds/thread (0.0%)
Simulation time                0 days
Simulation speed               1 object.hours/second
Passes completed               6 passes
Time steps completed           3 timesteps
Convergence efficiency      2.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep              2 seconds/timestep
Simulation rate               7 x realtime

Delta mode profiler results
===========================

Active modules          tape,powerflow
Initialization time          0.0 seconds
Number of updates              8
Average update timestep   7.5000 ms
Minumum update timestep  10.0000 ms
Maximum update timestep  10.0000 ms
Total deltamode simtime      0.0 s
Preupdate time               0.0 s (0.0%)
Object update time           0.1 s (50.0%)
Interupdate time             0.1 s (50.0%)
Postupdate time              0.0 s (0.0%)
Total deltamode runtime      0.0 s (100%)
Simulation rate              inf x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
meter              0.048     80.0%     48.0
load               0.005      8.3%      0.1
player             0.004      6.7%      0.3
node               0.001      1.7%      0.0
overhead_line      0.001      1.7%      0.0
triplex_line       0.001      1.7%      0.5
================ ======== ======== ========
Total              0.060    100.0%      0.2

