LLB R1, 70 #Address
LHB R1, 0xCC
LLB R2, 59
LLB R12, 34
LLB R13, 45
LLB R14, 78

#LW R7, R0, 0
#LW R8, R0, 1
#HLT

#SW R2, R1, 0
#ADD R0, R0, R0
#ADD R0, R0, R0
#ADD R0, R0, R0
#LW R7, R1, 0
#ADD R0, R0, R0
#ADD R0, R0, R0
#ADD R0, R0, R0
#HLT
#ADD R0, R0, R0
#ADD R0, R0, R0
#ADD R0, R0, R0
SW R12, R1, 1
SW R13, R1, 2
SW R14, R1, 3

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
HLT