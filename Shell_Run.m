%% The following script does the following task in order:
% 1. system level matrix mul with ABFT augmented matrices and extract data fed on Systolic Array building blocks
% 2. Remove the repeatitive data (for example there might be 2 operations wit same inputs so only simulating once is enough
% 3. Convert the unique data/operation set into binary and generate a file that is usable by HSPICE; 
% 4. Modify HSPICE model to have supply voltage according to simulations parameters and run HSPICE from SHELL
% 5. Read back the transient simulation results, first do data alignment according to clock, then check integrity and detect faults
% 6. Redo Step 1, i.e. system level simulation however this time using results of operations from step 5
% 7. On sysyem 




%% General ...
addpath([pwd '/HspiceToolbox/'])

%% system level matrix multiply to generate and find the unique stimuli, produce hspice feedable data 
defSHELL = 1;
TIME_STEP = 0.05*10^-9;
CLOCK_PERIOD = 100; 
MATRIX_SIZE = 8;
Vdd = 0.9;
seed = 1;
SET_UP_TIME = 10; %sample SET_UP_TIME points (roughly (TIME_STEP*SET_UP_TIME) seconds), before next clock edge, this variable can provide a nobe to check circuit response to different frequencies
SPICE_input_Data_Path = [pwd '/HSPICE_Simulations/spiceModel/Pulses.SP'];
SPICE_output_Data_Path= [pwd '/HSPICE_Simulations/Vdd0.9ADDMUL_driven_final.tr0'];
run ./System_Simulations/generateSpiceData.m;

%% Invoke HSPICE 

%system (['cp ' Output_Path Script_Path(1:end-23)]);
Script_Path = ' ./HSPICE_Simulations/spiceModel/ADDMUL_driven_final.SP ' ;
Output_Path = [' ./HSPICE_Simulations/' 'Vdd' num2str(Vdd) 'ADDMUL_driven_final.lis '];
HSPICE_Path = ' /usr/local/contrib/synopsys/hspice_vP-2019.06-SP2-1/hspice/P-2019.06-SP2-1/hspice/linux64/hspice ';
HSPICE_PARAMs = ' -mt 24 -hpp';
Command = [HSPICE_Path ' -i ' Script_Path ' -o ' Output_Path HSPICE_PARAMs];
[~,cmdOUT] = system(Command)



%% Check data intergrity and extract faulty results from HSPICE output
run ./System_Simulations/ErrorCHK/check_data.m;

