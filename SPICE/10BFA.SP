*-------------------------------------------------
*------------------ 10BIT FULL-ADDER--------------           
*-------------------------------------------------

.subckt 10BFA	A0	B0	A1	B1	A2	B2	A3	B3
+A4	B4	A5	B5	A6	B6	A7	B7	A8	B8	A9	B9	Sub	S0
+S1	S2	S3	S4	S5	S6	S7	S8	S9

XOR0	Sub	B0	X0	XOR_4ND 
XFA0	A0	X0	Sub	C0	S0	FA 

XOR1	Sub	B1	X1	XOR_4ND 
XFA1	A1	X1	C0	C1	S1	FA 

XOR2	Sub	B2	X2	XOR_4ND 
XFA2	A2	X2	C1	C2	S2	FA 

XOR3	Sub	B3	X3	XOR_4ND 
XFA3	A3	X3	C2	C3	S3	FA 

XOR4	Sub	B4	X4	XOR_4ND 
XFA4	A4	X4	C3	C4	S4	FA 

XOR5	Sub	B5	X5	XOR_4ND 
XFA5	A5	X5	C4	C5	S5	FA 

XOR6	Sub	B6	X6	XOR_4ND 
XFA6	A6	X6	C5	C6	S6	FA 

XOR7	Sub	B7	X7	XOR_4ND 
XFA7	A7	X7	C6	C7	S7	FA 

XOR8	Sub	B8	X8	XOR_4ND 
XFA8	A8	X8	C7	C8	S8	FA 

XOR9	Sub	B9	X9	XOR_4ND 
XFA9	A9	X9	C8	C9	S9	FA 

.ends  10BFA 
