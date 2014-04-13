# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

# This test is dependency free

# Initialize the registers for testing ease, R1 = 0x1111, R2 = 0x2222, etc.
LLB R1, 17
LHB R1, 17
LLB R2, 34
LHB R2, 34
LLB R3, 51
LHB R3, 51
LLB R4, 68
LHB R4, 68
LLB R5, 85
LHB R5, 85
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
	AND R1, R2, R3   # R1 = 0x2222

	# Test SUB
	SUB R2, R3, R2   # R2 = 0x1111

	# Test ADD
	ADD R3, R3, R4   # R3 = 0x7777 (Non-Saturating)

	# Test NOR
	NOR R4, R1, R1	 # R4 = 0xDDDD

	# Test SLL
	SLL R5, R1, 8	 # R5 = 0x2200

	# Test SRL
	SRL R6, R1, 8	 # R6 = 0x0022

	# Test SRA
	SRA R7, R1, 8	 # R7 = 0x0022
	SRA R8, R4, 8	 # R8 = 0xFFDD

	# Test ADDz
	ADDz R1, R1, R1	 # R1 should remain unchanged
 	ADD  R0, R0, R0	 # Set the Z flag
	ADDz R9, R1, R1 # R10 = 0x4444

	HLT		 # Printout should match what's listed above
