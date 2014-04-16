# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

# This test is dependency free

# Initialize the registers for testing ease
LLB R1, 17	R1 = 0x0011
LLB R2, 34	R2 = 0x0022
LLB R3, 51	R3 = 0x0033
LLB R4, 68	R4 = 0x0044
LLB R5, 85	R5 = 0x0055
LLB R6, 102	R6 = 0x0066
LLB R7, 119	R7 = 0x0077
LLB R8, 136	R8 = 0xFF88
LLB R9, 153	R9 = 0xFF99
LLB R10, 170	R10 = 0xFFAA
LLB R11, 187	R11 = 0xFFBB
LLB R12, 204	R12 = 0xFFCC
LLB R13, 221	R13 = 0xFFDD
LLB R14, 238	R14 = 0xFFEE
LLB R15, 255	R15 = 0xFFFF
############

	# Test AND
	AND R1, R2, R3   # R1 = 0x0022

	# Test SUB
	SUB R2, R3, R2   # R2 = 0x0011

	# Test ADD
	ADD R3, R3, R4   # R3 = 0x0077 (Non-Saturating)

	# Test NOR
	NOR R4, R1, R1	 # R4 = 0xFFDD

	# Test SLL
	SLL R5, R1, 8	 # R5 = 0x2200

	# Test SRL
	SRL R6, R1, 4	 # R6 = 0x0002

	# Test SRA
	SRA R7, R1, 4	 # R7 = 0x0002
	SRA R8, R4, 4	 # R8 = 0xFFFF

	# Test ADDz
	ADDz R1, R1, R1	 # R1 should remain unchanged
 	ADD  R0, R0, R0	 # Set the Z flag
	ADDz R9, R1, R1  # R9 = 0x0044

	# Test SW
	SW R10, R12, 5	 # mem[R12 + 5] <= R10
	LW R11, R12, 5	 # R11 <= mem[R12 + 5] (should match R10, 0xFFAA) 

	HLT		 # Printout should match what's listed above
