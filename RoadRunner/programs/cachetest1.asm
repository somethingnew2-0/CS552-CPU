#Tests basic cache stuff
LLB R1, 0x70 #Address
LHB R1, 0xCC
LLB R2, 59

SW R2, R1,0
LW R3, R1, 0

ADD R4, R1, R1
SW R4, R1, 1
LW R5, R1, 1

ADD R5, R4, R4
SW R5, R1, 16
LW R6, R1, 16

SW R2, R1, 16

LW R7, R1, 0

LW R8, R1, 16
HLT