# SPICE and Behavioral simulation of systolic array equipped with ABFT 

# Systolic Array with ABFT flavor

We need to demostrate efficacy of Algorithm Based Fault Tolerance method for achiving low-voltage (high performance) computing. We propose a systolic array model with extra circuitry to detected computational errors on the fly. We need a platfom to simulate low-voltage operatiopn of our systolic array. The common digital simulation and synthesis tools lack detailed charactristics of logic cells hence we resort to perform our simulations using SPICE models. The flow of simulations are shown in below. The computer code or SPICE script of each section can be found in the repo.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/flow_of_simulations.png)


# Processing Elements
Each PE in the systolic array contains a MAC unit and a handful of flip-flops to pass data and/or to accomulate local results. The multiplier circuit in HSPICE was implemented as Wallace Tree multiplier (https://github.com/SiluPanda/8-bit-wallace-tree-multipier) and the adders are based on carry-ripple-adder/subtracture that we already used in Analog-to-Digital circuit https://en.wikipedia.org/wiki/Adder%E2%80%93subtractor. 
Note, when the supply is reduced the setup and hold time of flip-flops will be effected as well, hence we had to develope a model and MATLAB script to extract those information for different voltage and operaiton frequency.

# HSPICE-MATLAB communication

Data are read from transient simulatin using HSPICE toolbox (by Michael H. Perrott), available form https://cppsim.com/. Please note this toolbox requires the post format of output to be set to '.option POST_VERSION = 9601'. Binary digital stimuli data to HSPICE is generated using a MATLAB script (available in repository). “HPSC” Program can also be utilized for this purpose https://www.cppsim.com/Manuals/hspc.pdf.

# HSPICE/MATLAB simulation and post-processing time
The following speculations are based on our simulations on a server computer (with Intel Xenon Processor).

To obtain circuit results for exact inputs (hence not a probablity based model) we must carry a *Transient* simulation of the processor for different voltages. 
For HSPICE part, ideally we must simulate "ALL" combinations of inputs, i.e. for two 8-bit input and one 24-bit feedback internal input (from Accomulator register) we need perfom simulations for *2^32* different combinations of inputs. Add to this complexity the need for simulating the circuit under around 100 different voltage levels (e.g. from 0.3 to 1.2 with 0.1v step size), which translated into ~2^38.2 different combinatons of input and supply voltage! Now, for 2^12 data entries it take a couple of hours for HSPICE to finish (on a single thread, i.e. HSPICE switch "... -mt 1"). Now you can imagine it can easily take years for doing all simulations for $2^38.2$.
Most of simulation time is consumed in HSPICE and MATLAB (where the HSPICE output needs to be "resampl"ed since HSPICE results are non-unifermly sampled in time). The SPICE simulation and MATLAB post-processing (i.e. data alignments) take a long time. For MATLAB part, simply breaking data into smaller pieces and then performing resampling (which is basically a linear interpolation) increases the processing time significantly. 

Unique combination extraction, out of all possible inputs and outputs and internal signals to all PEs most of them are redundant so in pre-processing only unique combinations are preserved and the rest are removed, this aids us in accelerating the simulation by multiple orders of magnitites.



# Voltage/frequency simulations

All the possible data transition for PEs are collected from behavioral simulations. Simulations are re-itrated for all inputs and for all possbile voltage supplies (from Vth to full scale) with reasonabe step sizes (e.g. 0.1v). However, for charactrizations we do not need to sweep across all frequencies, instead simply change the output sampling time after rising edge (feeding the stimuli input) and we observe the circuits response for that imaginary clock period. As the sampling time gets closer to clock rising edge (i.e. a shorted clock period is assumed) the error rate invevitably will rise as shown in following figure.

![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/clock_edge_sample.png)



# Simulation samples
The following is an example screen shot of DUT. The output is not messy as it is spice simulation results. 
The simulation for finding optimum voltage-frequency requires sweeping from full-scall Vdd down to threshold voltage, however we do not need to sweep
frequency (and hence save a huge simulation time) as the results for 1 slow enough clock period determinds the maximum operating frequency.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/simulationsnapshot.png)


# Charactrization of D flip-flop metastabitlity in reduced voltage condition

The set-up-time of register in our co-simulation envirment is great nobe to emulate variation (beside supply voltage). Further, the set-up-time and hold-time of flip-flops in reduced voltage regime changes. A simple linear extrapolation can be etimated howeve using HSPICE models we can make a transistor simulations to measure the parameters more accurately. For this purpose the method introduced in "Foley, C., "Characterizing metastability," Symposium on Advanced Research in Asynchronous Circuits and Systems, 1996., pp.175,184, 18-21 Mar 1996, doi: 10.1109/ASYNC.1996.494449" was used.  There is a good Q&A in stackexchange where it explain the concept https://electronics.stackexchange.com/questions/81709/how-to-find-setup-time-and-hold-time-for-d-flip-flop. The summary of the method is depicted in following figure (adapted from mentioned paper).

![alt text](https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/metastability.png)




# Co-simulation GUI

There are many script from different platforms required to be run in sequence and managing all for exhastive simulations with different parameters is difficual. For ease of use a simple GUI was designed as well to assist on this regard.
This is still not a full automatic solution, and user must change the voltage-frequencies adaptively himself. It still takes weeks for the results generated for figures like the ones used in [1].
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/GUI.png
)



# Description of Co-simulation software
--------------------------------------------------------------------------------------------------
Main Script:
Name : run_SHELL.m

Input : Simulation parameters
Output : Power consumption, actual error rate, ABFT error rate, etc.

Description:
The script does the following task in order:
 1. system level matrix mul with ABFT augmented matrices and extract data fed on Systolic Array building blocks
 2. Remove the repeatitive data (for example there might be 2 operations wit same inputs so only simulating once is enough
 3. Convert the unique data/operation set into binary and generate a file that is usable by HSPICE; 
 4. Modify HSPICE model to have supply voltage according to simulations parameters and run HSPICE from SHELL
 5. Read back the transient simulation results, first do data alignment according to clock, then check integrity and detect faults
 6. Redo Step 1, i.e. system level simulation however this time using results of operations from step 5
 7. System Level simulation of ABFT checking part (the extra circuit on the systolic- notice the HSPIC simulation must verify error detection cirucit as well)
 8. Extract power consumption, do extrapolations and estimations, report total estimated power + error rate + etc.
--------------------------------------------------------------------------------------------------
Generate Data :
Name: transient_signals_extract.m

Input: Matrix size
Output: Unique transient operations to be used as stumuli in HSPICE simulations

Description: Since we cannot practically simulate a digital block in HSPICE for all possible inputs we extract the ones that actually are needed and simulate our PE for those. Further, since in a matrix-matrix multiplication most of the operations happen to have same inputs we must remove repeated operations. This function does that.

Steps:

1. Generate random matrices and convert into ABFT matrices (row, column wise)

2. do matrix multiplication and extract all operations along with their inputs (add, mul)

3. remove repeated operations with their inputs from the list (only Unique combination of inputs stay)


Name : generateSpiceData.m  

Convert unique input data generated using “transient_signals_extract.m” into binary format and generate HSPICE readable file 
--------------------------------------------------------------------------------------------------
