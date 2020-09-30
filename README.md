# SPICE and Behavioral simulation of systolic array equipped with ABFT 

# Systolic Array with ABFT flavor

We need to demostrate efficacy of Algorithm Based Fault Tolerance method for achiving low-voltage (high performance) computing. We propose a systolic array model with extra circuitry to detected computational errors on the fly. We need a platfom to simulate low-voltage operatiopn of our systolic array. The common digital simulation and synthesis tools lack detailed charactristics of logic cells hence we resort to perform our simulations using SPICE models.

# Processing Elements
The multiplier circuit in HSPICE was implemented as Wallace Tree multiplier (https://github.com/SiluPanda/8-bit-wallace-tree-multipier) and the adders are based on carry-ripple-adder/subtracture that we already used in Analog-to-Digital circuit https://en.wikipedia.org/wiki/Adder%E2%80%93subtractor.

# HSPICE to/from MATLAB data transfer

Data are read from transient simulatin using HSPICE toolbox (by Michael H. Perrott), available form https://cppsim.com/. Please note this toolbox requires the post format of output to be set to '.option POST_VERSION = 9601'. Binary digital stimuli data to HSPICE is generated using a MATLAB script (available in repository). “HPSC” Program can also be utilized for this purpose https://www.cppsim.com/Manuals/hspc.pdf.

# Simulation samples
The following is an example screen shot of DUT. The output is not messy as it is spice simulation results. 
The simulation for finding optimum voltage-frequency requires sweeping from full-scall Vdd down to threshold voltage, however we do not need to sweep
frequency (and hence save a huge simulation time) as the results for 1 slow enough clock period determinds the maximum operating frequency.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/simulation1.png)

As the sampling time gets closer to clock rising edge (i.e. a shorted clock period is assumed) the error rate invevitably will rise as shown in following figure.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/clock_edge_sample.png)
