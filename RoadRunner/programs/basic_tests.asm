# Some basic hazard free tests

	LLB R1, 15
	LLB R2, 20
	LLB R3, 5
	LHB R3, 3
	LLB R4, 15

					# Answers
	LLB R10, 35			# 15+20
	LLB R11, 0x78			# b1111 < 3  = 1111000
	LLB R12, 1			# b1111 > 3 = 1

	LLB R14, 0			# Status

	ADD R5, R1, R2			# Test 1

	SLL R6, R4, 3			# Test 2

	SRL R7, R4, 3			# Test 3


	SW  R4, R3, 0
	LW  R4, R3, 0 


	SUB R0, R7, R12
	ADDZ R14, R14, R3

	HLT
