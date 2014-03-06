	# Test AND
	AND R1, R10, R12 # R1 = 0x8888

	# Test SUB
	SUB R2, R1, R7   # R2 = 0x1111

	# Test ADD
	ADD R3, R1, R2   # R3 = 0x9999 (Non-Saturating)

	# Test ADDz
	ADDz R1, R1, R1  # R1 should remain unchanged
	SUB R0, R1, R1	 # Should set zero flag
	ADDz R4, R3, R2  # R4 = 0xAAAA

	# Test NOR
	NOR R5, R1, R4   # R5 = 0x5555
	
	
	HLT