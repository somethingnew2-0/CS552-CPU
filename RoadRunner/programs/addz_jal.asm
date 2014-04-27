# 10-15 instruction JAL/ADDz

	LLB R1, 55
	SUB R0, R1, R1	# SET Z
	JAL jump1
	SUB R0, R3, R1	# SET N
	JAL jump2
	ADD R0, R1, R1	# NONE SET
	JAL jump3

	JAL jump4
	HLT

jump1:	LLB R3, 5
	ADDz R4, R1, R3
	JR R15

jump2:	LLB R2, 10
	LHB R2, 25
	ADDz R6, R2, R1
	JR R15

jump3:	LLB R15, 7
	ADDz R5, R2, R1
	JR R15

jump4:	JR R15