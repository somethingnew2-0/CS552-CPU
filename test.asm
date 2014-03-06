# Any comments on the right hand side of the form "# Rx = " indicate what
# the value of that register should be when HLT prints out. Be careful
# not to change these values once they are set.

	# Test AND
	AND R1, R10, R12 # R1 = 0x8888

	# Test SUB
	SUB R2, R1, R7   # R2 = 0x1111

	# Test ADD
	ADD R3, R1, R2   # R3 = 0x9999 (Non-Saturating)

	# Test NOR
	NOR R4, R1, R3	 # R4 = 0x6666

	# Test ADDz
	SUB R0, R1, R1 	 # Set the zr flag
	ADDz R5, R3, R3  # R5 = 0xCCCC
	ADDz R5, R5, R5  # R5 should be unchanged (zr == 0)

	# Test SLL
	SLL R6, R3, 8	 # R6 = 0x9900

	# Test SRL

	# Test SRA

	# Test LLB

	# Test LHB

	# Test HLT
	HLT		# Printout should match what's listed above