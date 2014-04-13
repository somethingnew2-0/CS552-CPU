# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

# Initialize the registers for testing ease, R1 = 0x1111, R2 = 0x2222, etc.
LLB R1, 17
LHB R1, 17
LLB R2, 34
LHB R2, 34
LLB R3, 51
LHB R3, 51
LLB R4, 68
LHB R4, 68
LLB R5, 88
LHB R5, 88
LLB R6, 102
LHB R6, 102
LLB R7, 119
LHB R7, 119
LLB R8, 136
LHB R8, 136
LLB R9, 153
LHB R9, 153
LLB R10, 170
LHB R10, 170
LLB R11, 187
LHB R11, 187
LLB R12, 204
LHB R12, 204
LLB R13, 221
LHB R13, 221
LLB R14, 238
LHB R14, 238
LLB R15, 255
LHB R15, 255
############

	# Test AND
	AND R1, R3, R11 # R1 = 0x3333

	# Test SUB
	SUB R2, R1, R2   # R2 = 0x1111

	# Test ADD
	ADD R3, R1, R2   # R3 = 0x4444 (Non-Saturating)
	LLB R12, 0xFF
	LHB R12, 0x6F	 # R12 has a large positive number
	ADD R13, R12, R7 # R13 = 0x7FFF (Positive overflow / Saturation)

	# Test NOR
	NOR R4, R1, R3	 # R4 = 0x8888

	# Test ADDz (Saturation *does* work)
	SUB R0, R2, R2 	 # Set the zr flag
	
	ADDz R5, R3, R3  # R5 = 0x7FFF (Negative overflow / Saturation)
	ADDz R5, R1, R2  # R5 should be unchanged (zr == 0)

	# Test SLL
	SLL R6, R3, 8	 # R6 = 0x4400

	# Test SRL
	SRL R7, R3, 8	 # R7 = 0x0044

	# Test SRA
	SRA R8, R8, 8	 # R8 = 0xFF88
	
	# Test LLB
	LLB R9, 0x55	 # R9 = 0x0055
	LLB R10, 0xCC	 # R10 = 0xFFCC

	# Test LHB
	LHB R11, 0xFF	 # R11 = 0xFFBB

	# Test LW and SW
	SW R11, R9, 0	# mem[R9] = R11
	LW R12, R9, 0	# R12 = R11

	HLT		 # Printout should match what's listed above
