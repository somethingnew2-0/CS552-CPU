# Test branch under the different conditions, assuming flags work
# Success if this loops infinitely

# Initialize the registers for testing ease, R1 = 0x1111, R2 = 0x2222, etc.
LLB R1, 17
LLB R2, 34
LLB R3, 51
LLB R4, 68
LLB R5, 88
LLB R6, 102
LLB R7, 119
LLB R8, 136
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

# !V!Z!N
check_000:	ADD R0, R1, R1		# Clear all three

			b eq, broked		#
			b lt, broked		# Condition should be false
			b ovfl, broked		#
			b lte, broked		#
			
			b neq, skip1		# Condition's are true, HLT's should be skipped
			HLT #1
	skip1:	b gt, skip2
			HLT #2
	skip2:	b gte, skip3
			HLT #3
	skip3:	b uncond, check_001	# Every possible branch has been tested
# !V!ZN
check_001:	SUB R0, R1, R2		# Set the N flag
			
			b eq, broked		#
			b gt, broked		# Condition should be false
			b ovfl, broked		#
			b gte, broked		#
			
			b lt, skip4			# Condition's are true, HLT's should be skipped
			HLT #4
	skip4:	b lte, skip5
			HLT #5
	skip5:	b neq, skip6
			HLT #6
	skip6:	b uncond, check_010	# Every possible branch has been tested
# !VZ!N
check_010:	SUB R0, R1, R1		# Set the Z flag

			b lt, broked		#
			b ovfl, broked		# Condition should be false
			b neq, broked		#
			b gt, broked		#
			
			b eq, skip7		# Condition's are true, HLT's should be skipped
			HLT #7
	skip7:	b lte, skip8
			HLT #8
	skip8:	b gte, skip9
			HLT #9
	skip9:	b uncond, check_100	# Every possible branch has been tested
# V!Z!N
check_100:	ADD R0, R7, R7	# Set the V flag (Positive Overflow)

			b eq, broked		#
			b lt, broked		# Condition should be false
			b lte, broked		#
			
			b ovfl, skip10		# Condition's are true, HLT's should be skipped
			HLT #10
	skip10:	b neq, skip11
			HLT #11
	skip11:	b gt, skip12
			HLT #12
	skip12:	b gte, skip13
			HLT #13
	skip13:	b uncond, check_101	# Every possible branch has been tested
# V!ZN
check_101:	ADD R0, R9, R9		# Set the V and N flags (Negative Overflow)

			b eq, broked		#
			b gt, broked		# Condition should be false
			b gte, broked		#
			
			b lt, skip14		# Condition's are true, HLT's should be skipped
			HLT #14
	skip14:	b lte, skip15
			HLT #15
	skip15:	b ovfl, skip16
			HLT #16
	skip16:	b neq, skip17
			HLT #17
	skip17:	b uncond, check_JAL	# Every possible branch has been tested
check_JAL:	JAL check_return
		HLT # Sucess!		# PC should be @0x005e (HLT addr + 1)

broked:		HLT # Broken

check_return:	JR R15
