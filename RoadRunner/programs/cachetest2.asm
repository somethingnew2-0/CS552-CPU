LLB R1, 70 #Address
LHB R1, CC
LLB R2, 59

SW R2, R1,0
LW R3, R1, 0
ADD R4, R2, R2
LW R4, R1, 1
ADD R4, R4, R4
LW R4, R1, 2
ADD R4, R4, R4
LW R4, R1, 3
ADD R4, R4, R4

SW R2, R1, 16
LW R5, R1, 1

LW R6, R1, 3