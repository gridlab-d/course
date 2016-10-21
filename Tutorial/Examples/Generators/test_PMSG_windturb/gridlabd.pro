
Core profiler results
======================

Total objects                 34 objects
Parallelism                    1 thread
Total time                  10.0 seconds
  Core time                  1.4 seconds (14.0%)
    Compiler                 0.0 seconds (0.2%)
    Instances                0.0 seconds (0.0%)
    Random variables         0.0 seconds (0.0%)
    Schedules                0.0 seconds (0.0%)
    Loadshapes               0.0 seconds (0.0%)
    Enduses                  0.0 seconds (0.0%)
    Transforms               0.0 seconds (0.1%)
  Model time                 8.6 seconds/thread (86.0%)
Simulation time                4 days
Simulation speed             326 object.hours/second
Passes completed           69280 passes
Time steps completed       69121 timesteps
Convergence efficiency      1.00 passes/timestep
Read lock contention        0.0%
Write lock contention       0.0%
Average timestep              5 seconds/timestep
Simulation rate           34560 x realtime


Model profiler results
======================

Class            Time (s) Time (%) msec/obj
---------------- -------- -------- --------
recorder           2.842     33.1%    473.7
transformer        1.233     14.3%    308.2
node               0.992     11.5%    330.7
windturb_dg        0.735      8.5%    367.5
triplex_meter      0.683      7.9%    341.5
triplex_node       0.362      4.2%    362.0
triplex_line       0.313      3.6%    313.0
overhead_line      0.307      3.6%    307.0
meter              0.292      3.4%    292.0
rectifier          0.283      3.3%    283.0
climate            0.279      3.2%    279.0
inverter           0.277      3.2%    277.0
================ ======== ======== ========
Total              8.598    100.0%    252.9

