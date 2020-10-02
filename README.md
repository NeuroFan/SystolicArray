# SPICE and Behavioral simulation of systolic array equipped with ABFT 

# Systolic Array with ABFT flavor

We need to demostrate efficacy of Algorithm Based Fault Tolerance method for achiving low-voltage (high performance) computing. We propose a systolic array model with extra circuitry to detected computational errors on the fly. We need a platfom to simulate low-voltage operatiopn of our systolic array. The common digital simulation and synthesis tools lack detailed charactristics of logic cells hence we resort to perform our simulations using SPICE models.

# Processing Elements
Each PE in the systolic array contains a MAC unit and a handful of flip-flops to pass data and/or to accomulate local results. The multiplier circuit in HSPICE was implemented as Wallace Tree multiplier (https://github.com/SiluPanda/8-bit-wallace-tree-multipier) and the adders are based on carry-ripple-adder/subtracture that we already used in Analog-to-Digital circuit https://en.wikipedia.org/wiki/Adder%E2%80%93subtractor. 
Note, when the supply is reduced the setup and hold time of flip-flops will be effected as well, hence we had to develope a model and MATLAB script to extract those information for different voltage and operaiton frequency. There is a good Q&A in stackexchange where it explain the concept https://electronics.stackexchange.com/questions/81709/how-to-find-setup-time-and-hold-time-for-d-flip-flop.

# HSPICE to/from MATLAB data transfer

Data are read from transient simulatin using HSPICE toolbox (by Michael H. Perrott), available form https://cppsim.com/. Please note this toolbox requires the post format of output to be set to '.option POST_VERSION = 9601'. Binary digital stimuli data to HSPICE is generated using a MATLAB script (available in repository). “HPSC” Program can also be utilized for this purpose https://www.cppsim.com/Manuals/hspc.pdf.

# Sweep on Voltage but not Frequency

All the possible data transition for PEs are collected from behavioral simulations. Simulations are re-itrated for all inputs and for all possbile voltage supplies (from Vth to full scale) with reasonabe step sizes (e.g. 0.1v). However, for charactrizations we do not need to sweep across all frequencies, instead simply change the output sampling time after rising edge (feeding the stimuli input) and we observe the circuits response for that imaginary clock period. As the sampling time gets closer to clock rising edge (i.e. a shorted clock period is assumed) the error rate invevitably will rise as shown in following figure.

![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/clock_edge_sample.png)



# Simulation samples
The following is an example screen shot of DUT. The output is not messy as it is spice simulation results. 
The simulation for finding optimum voltage-frequency requires sweeping from full-scall Vdd down to threshold voltage, however we do not need to sweep
frequency (and hence save a huge simulation time) as the results for 1 slow enough clock period determinds the maximum operating frequency.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/simulation1.png)


To be completed ....
