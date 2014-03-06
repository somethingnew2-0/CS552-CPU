# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

	# Test AND
	AND R1, R10, R12 # R1 = 0x8888

	# Test SUB
	SUB R2, R1, R7   # R2 = 0x1111

	# Test ADD
	ADD R3, R1, R2   # R3 = 0x9999 (Non-Saturating)
	LLB R12, 0xFF
	LHB R12, 0x6F	 # R12 has a large positive number
	ADD R12, R12, R7 # R12 = 0x7FFF (Positive overflow / Saturation)

	# Test NOR
	NOR R4, R1, R3	 # R4 = 0x6666

	# Test ADDz
	SUB R0, R1, R1 	 # Set the zr flag
	ADDz R5, R3, R3  # R5 = 0x8000 (Negative overflow / Saturation)
	#ADDz R5, R5, R5  # R5 should be unchanged (zr == 0)

	# Test SLL
	SLL R6, R3, 8	 # R6 = 0x9900

	# Test SRL
	SRL R7, R3, 8	 # R7 = 0x0099

	# Test SRA
	SRA R8, R8, 8	 # R8 = 0xFF88

	# Test LLB
	LLB R9, 0x55	 # R9 = 0x0055
	LLB R10, 0xCC	 # R10 = 0xFFCC

	# Test LHB
	LHB R11, 0xFF	 # R11 = 0xFFBB

	# Test HLT
	HLT		 # Printout should match what's listed above