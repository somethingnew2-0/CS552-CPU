# Src1 Hazard Testing
# -------------------
# RAW
# Load-Use
# Load-Store

# If the test succeeds, R1,2 will be 5; R3,4 will be 0; R5,6 will be 10

# Initialize the registers for testing ease
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

# RAW (1 instruction later)
LLB R1, 3		#
LHB R1, 0		# Initialize
LLB R15, 11		# 	values
LHB R15, 0		#

ADD R1, R1, R1	
SUB R1, R15, R1	# R1 = 5

# RAW (2 instructions later)
LLB R2, 3		#
LHB R2, 0		# Initialize
LLB R14, 11		# 	values
LHB R14, 0		#

ADD R2, R2, R2
AND R0, R0, R0	# Filler (NOP)
SUB R2, R14, R2	# R2 = 5

# Load-Use (1 instruction later)
LLB R12, 10		#
LHB R12, 0		# Initialize
LLB R13, 55		# 	values
LHB R13, 55		#
SW 	R12, R13, 0	# So we know what's out there

LW 	R3, R13, 0
SUB R3, R12, R3	# R3 = 0

# Load-Use (2 instructions later)
LW 	R4, R13, 0
AND R0, R0, R0	# Filler (NOP)
SUB R4, R12, R4	# R4 = 0

# Load-Store (1 instruction later)
LLB R12, 33		# Initialize
LHB R12, 33		# 	value

LW	R5, R13, 0	# Load 10
SW	R5, R12, 0	# Store it somewhere else
LW	R5, R12, 0	# R5 = 10

# Load-Store (2 instructions later)
LW	R6, R13, 0	# Load 10
AND R0, R0, R0	# Filler (NOP)
SW	R6, R12, 0	# Store is somewhere else
LW	R6, R12, 0	# R6 = 10 # Why is this 0xXXXX when run again WISC.S14?


