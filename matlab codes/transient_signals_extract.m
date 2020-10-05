function HSPICE_DATA=  trainsient_signal_extract(MATRIX_SIZE)

    disp("HSPICE_DATA is: A0 A1 A2 ... A7,        B0 B1 B2 ... B7,       S0 S1 S2 ... S23, ");

    seed = 1; %randi ; %fixed seed to get same results on different computers
    rng(seed);
    N = MATRIX_SIZE; %matrix size N*N
    factor = 32;
    A = factor*randi([0 4],N,N);    
    B = factor*randi([0 4],N,N);   


    C = zeros(N+1,N+1);
    transientData = zeros((N+1)^3,3); % p(i) = a(i)*b(i) + p(i-1); --> [a(i),b(i),p(i-1),p(i)]


    [Ac,Ar,Af] = mat_ext(A);
    [Bc,Br,Bf] = mat_ext(B);

    ArScale=Ar;BcScale = Bc;
    ArScale(end,:) = Ar(end,:)./factor; %Scale down checksum to accomodate it into 8 bits
    BcScale(:,end) = Bc(:,end)./factor; %Scale down checksum to accomodate it into 8 bits

    %% Extract Information on this regard
    indx=1;
    for i = 1:N+1
        for j = 1:N+1
            for k = 1:N

                transientData(indx,1) = ArScale(i,k); % 1th input of mult
                transientData(indx,2) = BcScale(k,j); % 2th imput of mul
                transientData(indx,3) = C(i,j); % input to adder (feedbacked)

                p = ArScale(i,k)*BcScale(k,j); 
                C(i,j) = C(i,j) + p;

            %    transientData(indx,4) = C(i,j) ; %though this could be simply last p but we save it anyways
                indx=indx+1;
            end
        end
    end

    Uniq_Combinations_of_inputs = unique(transientData,'rows'); %this removes reapted computations
    Len_Comb = length(Uniq_Combinations_of_inputs);
    timeToSimulate = 10*Len_Comb./(2^16);  %2^16 bit simulation took around 10 hours 
    disp(['Estimated simulation time: ~' num2str(round(timeToSimulate)) ' hours for ' num2str(N) 'x' num2str(N) ' matrix' ]);

    %% Convert generated data into HSPICE readable (binary array)
     HSPICE_DATA  = zeros(Len_Comb, 8+8+24); % 2 8bits for mul and 1 24bit for adder

     for i = 1:Len_Comb
         mul_in1 = Uniq_Combinations_of_inputs(i,1);
         mul_in2 = Uniq_Combinations_of_inputs(i,2);
         add_in1 = Uniq_Combinations_of_inputs(i,3);

         HSPICE_DATA(i,1:8) = int_to_binary(mul_in1,8);
         HSPICE_DATA(i,9:16) = int_to_binary(mul_in2,8);
         HSPICE_DATA(i,17:40) = int_to_binary(add_in1,24); % NOTICE 32 bit is really needed!!!! but we used 24 bit should be corrected later!

     end
     %% Control if generated data is correct
     % data might not match due to dec2bin's second argument that limits number
     % of bits
     misMatch = 0;
     for i = 1:Len_Comb

         M1_dec = binary_to_decimal( HSPICE_DATA(i,1:8));
         M2_dec = binary_to_decimal(HSPICE_DATA(i,9:16));
         A1_dec = binary_to_decimal(HSPICE_DATA(i,17:40));

         if (M1_dec ~= Uniq_Combinations_of_inputs(i,1))|(M2_dec ~=Uniq_Combinations_of_inputs(i,2))|(A1_dec ~=Uniq_Combinations_of_inputs(i,3))
             disp("Error Generated binary does NOT matche MATLAB!");
             misMatch = 1;
             break
         end
     end
     if (misMatch==0)
         disp("Success!");
     end
end
