# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

# This test is dependency free

# Initialize the registers for testing ease
	LLB R1, 0x11	# R1 = 0x0011
	LLB R2, 0x22	# R2 = 0x0022
	LLB R3, 0x33	# R3 = 0x0033
	LLB R4, 0x44	# R4 = 0x0044
	LLB R5, 0x55	# R5 = 0x0055
	LLB R6, 0x66	# R6 = 0x0066
	LLB R7, 0x77	# R7 = 0x0077
	LLB R8, 0x88	# R8 = 0xFF88
	LLB R9, 0x99	# R9 = 0xFF99
	LLB R10, 0xAA	# R10 = 0xFFAA
	LLB R11, 0xBB	# R11 = 0xFFBB
	LLB R12, 0xCC	# R12 = 0xFFCC
	LLB R13, 0xDD	# R13 = 0xFFDD
	LLB R14, 0xEE	# R14 = 0xFFEE
	LLB R15, 0xFF	# R15 = 0xFFFF
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
	SRA R8, R4, 4	 # R8 = 0xFFFD

	# Test ADDz
	ADDz R1, R1, R1	 # R1 should remain unchanged
 	ADD  R0, R0, R0	 # Set the Z flag
	ADDz R9, R1, R1  # R9 = 0x0044

	# Test SW
	SW R10, R12, 5	 # mem[R12 + 5] <= R10
	LW R11, R12, 5	 # R11 <= mem[R12 + 5] (should match R10, 0xFFAA) 
	LLB R13, 0xAB	# R13 = 0xFFAB
	LLB R14, 0x56	# R14 = 0xFF56
	LLB R15, 0xED	# R15 = 0xFFED

	HLT		 # Printout should match what's listed above
