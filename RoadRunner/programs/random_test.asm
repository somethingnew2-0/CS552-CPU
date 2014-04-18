	# Initialize the registers for testing ease, R1 = 0x1111, R2 = 	0x2222, etc.
	LLB R1, 17
	LLB R2, 34
	LLB R3, 51
	LLB R4, 68
	LLB R5, 88
	LLB R6, 102
	LLB R7, 119
	LLB R8,	136
	LLB R9, 153
	LLB R10, 170
	LLB R11, 187
	LLB R12, 204
	LLB R13, 221
	LLB R14, 238
	LLB R15, 255
	LHB R1, 17
	LHB R2, 34
	LHB R3, 51
	LHB R4, 68
	LHB R5, 88
	LHB R6, 102
	LHB R7, 119
	LHB R8, 136
	LHB R9, 153
	LHB R10, 170
	LHB R11, 187
	LHB R12, 204
	LHB R13, 221
	LHB R14, 238
	LHB R15, 255
	############

        AND R6, R6, R15
        SRA R6, R0, 3
        SRL R2, R6, 11
        ADD R5, R13, R11
        ADD R7, R6, R8
        LW R5, R13, 4
        NOR R0, R0, R13
        SRA R2, R7, 9
        ADD R13, R9, R5
        ADDz R8, R0, R13
        LHB R4, 5
        SRA R3, R5, 13
        LLB R5, 5
        SUB R10, R11, R3
        JAL Weather
        SW R12, R11, 1
        NOR R10, R2, R5
Weather:LHB R13, 12
        LW R7, R15, 7
        AND R15, R5, R13
        NOR R13, R6, R2
        NOR R3, R11, R10
        ADDz R12, R10, R3
        AND R14, R0, R3
        JAL Crush
        ADDz R7, R7, R4
        LHB R15, 8
        SW R3, R4, 8
Crush:  ADD R1, R14, R11
        JAL By
        LHB R10, 6
        NOR R4, R14, R10
        JAL Sweater
        SLL R9, R0, 11
By:     B eq, Park
        ADDz R8, R11, R7
        LLB R11, 11
        LW R10, R6, 6
Sweater:SRL R6, R4, 8
        SUB R8, R15, R3
        JR R15
        ADD R5, R8, R5
Park:   ADDz R0, R2, R14
        LW R7, R10, 7
        LHB R8, 2
        SRA R1, R7, 10
        SRA R9, R1, 6
        LW R11, R10, 9
        ADDz R9, R6, R3
