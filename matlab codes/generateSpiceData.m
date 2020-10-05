
TIME_STEP = 0.05*10^-9; %0.05 ns
CLOCK_PERIOD = 100;    %5ns or 200MHz
MATRIX_SIZE = 32;


HSPICE_DATA = transient_signals_extract(MATRIX_SIZE);



N = length(HSPICE_DATA); % Length of data
A = HSPICE_DATA(1:end,1:8);
B = HSPICE_DATA(1:end,9:16);
C = HSPICE_DATA(1:end,17:40);


A = [zeros(1,8);A;zeros(1,8)];
B = [zeros(1,8);B;zeros(1,8)];
C = [zeros(1,24);C;zeros(1,24)];


bit_stream_length = length(A);
spice_data_length = CLOCK_PERIOD * bit_stream_length;

A_spice_stream = zeros(spice_data_length,8); 
B_spice_stream = zeros(spice_data_length,8); 
C_spice_stream = zeros(spice_data_length,24); 

time_stream = zeros(spice_data_length,1) ; 
clock_stream = zeros(spice_data_length,1) ; 

for i = 1:bit_stream_length

     t1 = (i-1) * CLOCK_PERIOD + 1; %start point of clock 
     t2 =   i  * CLOCK_PERIOD;   %end point of clock
     time_stream(t1:t2) = (t1:t2).*TIME_STEP;
     clock_stream(t1:(t2-0.5*CLOCK_PERIOD)) = 1; % clock signal

     A_spice_stream(t1:t2,1) = A(i,1);     
     A_spice_stream(t1:t2,2) = A(i,2);     
     A_spice_stream(t1:t2,3) = A(i,3);   
     A_spice_stream(t1:t2,4) = A(i,4);   
     A_spice_stream(t1:t2,5) = A(i,5);   
     A_spice_stream(t1:t2,6) = A(i,6);   
     A_spice_stream(t1:t2,7) = A(i,7);   
     A_spice_stream(t1:t2,8) = A(i,8);   

     B_spice_stream(t1:t2,1) = B(i,1);      
     B_spice_stream(t1:t2,2) = B(i,2);      
     B_spice_stream(t1:t2,3) = B(i,3);    
     B_spice_stream(t1:t2,4) = B(i,4);    
     B_spice_stream(t1:t2,5) = B(i,5);    
     B_spice_stream(t1:t2,6) = B(i,6);    
     B_spice_stream(t1:t2,7) = B(i,7);    
     B_spice_stream(t1:t2,8) = B(i,8);    

     C_spice_stream(t1:t2,1) = C(i,1);       
     C_spice_stream(t1:t2,2) = C(i,2);       
     C_spice_stream(t1:t2,3) = C(i,3);     
     C_spice_stream(t1:t2,4) = C(i,4);     
     C_spice_stream(t1:t2,5) = C(i,5);     
     C_spice_stream(t1:t2,6) = C(i,6);     
     C_spice_stream(t1:t2,7) = C(i,7);     
     C_spice_stream(t1:t2,8) = C(i,8);    
     C_spice_stream(t1:t2,9) = C(i,9);  
     C_spice_stream(t1:t2,10) = C(i,10);  
     C_spice_stream(t1:t2,11) = C(i,11);  
     C_spice_stream(t1:t2,12) = C(i,12);  
     C_spice_stream(t1:t2,13) = C(i,13);  
     C_spice_stream(t1:t2,14) = C(i,14);  
     C_spice_stream(t1:t2,15) = C(i,15);  
     C_spice_stream(t1:t2,16) = C(i,16);  
     C_spice_stream(t1:t2,17) = C(i,17);  
     C_spice_stream(t1:t2,18) = C(i,18);  
     C_spice_stream(t1:t2,19) = C(i,19);  
     C_spice_stream(t1:t2,20) = C(i,20);  
     C_spice_stream(t1:t2,21) = C(i,21);  
     C_spice_stream(t1:t2,22) = C(i,22);  
     C_spice_stream(t1:t2,23) = C(i,23);  
     C_spice_stream(t1:t2,24) = C(i,24);  
  
end

% write results in hspice understandable format file
std = fileread('PULSES_HEADER_CODE.txt');
file = fopen( 'Pulses.sp', 'wt' );
fprintf(file,'\n\n%s',std);

for i = 1:spice_data_length
  a = A_spice_stream(i,:);
  b = B_spice_stream(i,:);
  c = C_spice_stream(i,:);
  fprintf( file, '%e,     %d, %d, %d, %d, %d, %d, %d, %d, %d, ', time_stream(i), clock_stream(i), a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8));
 
  fprintf( file, '%d, %d, %d, %d, %d, %d, %d, %d, ', b(1), b(2), b(3), b(4), b(5), b(6), b(7), b(8));

  
  fprintf( file, '%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d', c(1), c(2), c(3), c(4), c(5), c(6), c(7), c(8), + ...
                                                                                                                   c(9), c(10), c(11), c(12), c(13), c(14), c(15), c(16), +...
                                                                                                                   c(17), c(18), c(19), c(20), c(21), c(22), c(23), c(24));

 fprintf( file, '\n');
end

fprintf( file, '\n');
fprintf( file, '.ENDDATA  \n');

fclose(file);

