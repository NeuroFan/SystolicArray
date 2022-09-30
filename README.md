
# Note:

The following are notes that collected during prepration of a research work done by the author of the page. Note all information here included in the research paper. The information might vary with the ones presented in the paper since this page is not kept updated. However, the data here might shed more light and attract more researchers to the field and hopefully use our results.


Please note not all simulation files are uploeaded but we hope enough is supported.

# Demonstration video
Please find a video demonstrating adaptivity of our method with variations such as temrpature and IDF:

    https://youtu.be/5klGBAmTmdA
# SPICE and Behavioral simulation of systolic array 

# Systolic Array with in low voltage

We need to demostrate efficacy of our method for achiving low-voltage (high performance) computing. We propose a systolic array model with extra circuitry to detected computational errors on the fly. We need a platfom to simulate low-voltage operatiopn of our systolic array. The common digital simulation and synthesis tools lack detailed charactristics of logic cells hence we resort to perform our simulations using SPICE models. The flow of simulations are shown in below. The computer code or SPICE script of each section can be found in the repo.
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

# Ambient and Process Variations effect

Since such monte carlo type simulation adds large overhead for simulation we did a trick to mimic the variations while keep the simulations tracktable, computationaly speaking.
In simplest form one can add some jitter to set-up-time as a simplified way to mimic variations.

    VARIATION = round( (rand-0.5)*setup_hold_time*variation_percent); % e.g. 20%  jitter added on sampling period
    outp_smp_inx = current - setup_hold_time + VARIATION;
       
![alt text](https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/variations_mimic.png)


# Voltage/frequency simulations

All the possible data transition for PEs are collected from behavioral simulations. Simulations are re-itrated for all inputs and for all possbile voltage supplies (from Vth to full scale) with reasonabe step sizes (e.g. 0.1v). However, for charactrizations we do not need to sweep across all frequencies, instead simply change the output sampling time after rising edge (feeding the stimuli input) and we observe the circuits response for that imaginary clock period. As the sampling time gets closer to clock rising edge (i.e. a shorted clock period is assumed) the error rate invevitably will rise as shown in following figure.

![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/clock_edge_sample.png)



# Simulation samples
The following is an example screen shot of DUT. The output is not messy as it is spice simulation results. 
The simulation for finding optimum voltage-frequency requires sweeping from full-scall Vdd down to threshold voltage, however we do not need to sweep
frequency (and hence save a huge simulation time) as the results for 1 slow enough clock period determinds the maximum operating frequency.
![alt text]( https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/simulation1.png)




# Simulation results and insights

Here I write about extra information that might shed more light on the idea, challenges and trade-offs. Lets start by looking at power consumption per PE with respect to matrix size. As following figure shows with growth in matrix size (hence systolic array) the share of overhead tends to be zero, so one might conclude it is good idea to utilize the structure for very large matrix-matrix multipication to achieve "Almost Zero" overhead accelerator, however we should remember the cost and power consumption of clock tree for such large arrays and intra-die variations might grow exponentioally as well.

![alt text](https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/power%20per%20PE.jpg)

# Silent Error rate

As indiacated in our paper upper-bound of error for 1 single matrix multipicaiton is 50%. This should scare you, this is "upper bound" and not realistic. Further as we discussed in the paper, the usual applications (e.g. a deep neural nets) require tens of matrices to be multiplied in each episode of action, so the probablity of not detecting errors for an episode is really low (upper bound is 2^(- number of matrix multipications). Keep in mind that the worst case scenario we assumed is not realistic.

To have a more realistic model of silent errro occurance rate, we made the following model (as described breifly in the paper).

To extract exprimental silent error rate we must carry out millions of matrix multipications to extract this information which requires mind blowing computing resources if we only carry out SPICE simulations. However we decided to use co-simulation approach.

![alt text](https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/silent_error_rate.png)

In other word a bunch of PEs were simulated for different tempratures, different corner, different voltage and fix frequency in HSPICE. The rate of error for output bits were extracted, i.e. 24 bits. As expected error rate of MSB starts to rise faster than others as the MSB is associated with longest delay path usually. 

Then using the above information we can do millions system level matrix multipications. During each PE's operation we inject faults based on probablity distribution shown in above image into output "bits". 


# Charactrization of D flip-flop metastabitlity in reduced voltage condition

The set-up-time of register in our co-simulation envirment is great nobe to emulate variation (beside supply voltage). Further, the set-up-time and hold-time of flip-flops in reduced voltage regime changes. A simple linear extrapolation can be etimated howeve using HSPICE models we can make a transistor simulations to measure the parameters more accurately. This does not have much impact but we need some figures in simulation to consider for set-up time,etc. For this purpose the method introduced in "Foley, C., "Characterizing metastability," Symposium on Advanced Research in Asynchronous Circuits and Systems, 1996., pp.175,184, 18-21 Mar 1996, doi: 10.1109/ASYNC.1996.494449" was used.  There is a good Q&A in stackexchange where it explain the concept https://electronics.stackexchange.com/questions/81709/how-to-find-setup-time-and-hold-time-for-d-flip-flop. The summary of the method is depicted in following figure (adapted from mentioned paper).

![alt text](https://github.com/NeuroFan/Systolic_Array_ABFT/blob/master/figures/metastability.png)

# Description of Co-simulation software
--------------------------------------------------------------------------------------------------
Main Script:
Name : run_SHELL.m

Input : Simulation parameters
Output : Power consumption, actual error rate, ABFT error rate, etc.

Description:
The script does the following task in order:
 1. system level matrix mul with proposed method and extract data fed on Systolic Array building blocks
 2. Remove the repeatitive data (for example there might be 2 operations wit same inputs so only simulating once is enough
 3. Convert the unique data/operation set into binary and generate a file that is usable by HSPICE; 
 4. Modify HSPICE model to have supply voltage according to simulations parameters and run HSPICE from SHELL
 5. Read back the transient simulation results, first do data alignment according to clock, then check integrity and detect faults
 6. Redo Step 1, i.e. system level simulation however this time using results of operations from step 5
 7. System Level simulation of proposed method based error checking part (the extra circuit on the systolic- notice the HSPIC simulation must verify error detection cirucit as well)
 8. Extract power consumption, do extrapolations and estimations, report total estimated power + error rate + etc.
--------------------------------------------------------------------------------------------------
Generate Data :
Name: transient_signals_extract.m

Input: Matrix size
Output: Unique transient operations to be used as stumuli in HSPICE simulations

Description: Since we cannot practically simulate a digital block in HSPICE for all possible inputs we extract the ones that actually are needed and simulate our PE for those. Further, since in a matrix-matrix multiplication most of the operations happen to have same inputs we must remove repeated operations. This function does that.

Steps:

1. Generate random matrices and convert into special form of interst (row, column wise)

2. do matrix multiplication and extract all operations along with their inputs (add, mul)

3. remove repeated operations with their inputs from the list (only Unique combination of inputs stay)


Name : generateSpiceData.m  

Convert unique input data generated using “transient_signals_extract.m” into binary format and generate HSPICE readable file 
--------------------------------------------------------------------------------------------------
