# Systolic_Array_ABFT
SPICE and Behavioral simulation of systolic array equipped with ABFT 
The multiplier circuit in HSPICE was implemented as Wallace Tree multiplier (https://github.com/SiluPanda/8-bit-wallace-tree-multipier).



The following is an example screen shot of DUT. The output is not messy as it is spice simulation results. 
The simulation for finding optimum voltage-frequency requires sweeping from full-scall Vdd down to threshold voltage, however we do not need to sweep
frequency (and hence save a huge simulation time) as the results for 1 slow enough clock period determinds the maximum operating frequency.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/simulation1.png)
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/simulation_snap_shot.png)
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/sample.png)

