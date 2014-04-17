# Src1 Hazard Testing
# -------------------
# RAW
# Load-Use
# Load-Store

# If the test succeeds, R1,2 will be 5; R3,4 will be 0; R5,6 will be A

# RAW (1 instruction later)
LLB R1, 3		#
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R1, 0		# Initialize
LLB R15, 11		# 	values
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R15, 0		#

ADD R1, R1, R1	
#ADD R0, R0, R0
#ADD R0, R0, R0
SUB R1, R15, R1	# R1 = 5

# RAW (2 instructions later)
LLB R2, 3		#
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R2, 0		# Initialize
LLB R14, 11		# 	values
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R14, 0		#

ADD R2, R2, R2
AND R0, R0, R0	# Filler, leave this one uncommented so you are testing a different case
#ADD R0, R0, R0
#ADD R0, R0, R0
SUB R2, R14, R2	# R2 = 5

# Load-Use (1 instruction later)
LLB R12, 10		#
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R12, 0		# Initialize
LLB R13, 55		# 	values
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R13, 55		#
SW 	R12, R13, 0	# So we know what's out there

LW 	R3, R13, 0
#ADD R0, R0, R0
#ADD R0, R0, R0
SUB R3, R12, R3	# R3 = 0

# Load-Use (2 instructions later)
LW 	R4, R13, 0
AND R0, R0, R0	# Filler leave this one uncommented so you are testing a different case
#ADD R0, R0, R0
#ADD R0, R0, R0
SUB R4, R12, R4	# R4 = 0

# Load-Store (1 instruction later)
LLB R12, 33		# Initialize
#ADD R0, R0, R0
#ADD R0, R0, R0
LHB R12, 33		# 	value

LW	R5, R13, 0	# Load 10
#ADD R0, R0, R0
#ADD R0, R0, R0
SW	R5, R12, 0	# Store it somewhere else
LW	R5, R12, 0	# R5 = 10

# Load-Store (2 instructions later)
LW	R6, R13, 0	# Load 10
AND R0, R0, R0	# Filler leave this one uncommented so you are testing a different case
#ADD R0, R0, R0
#ADD R0, R0, R0
SW	R6, R12, 0	# Store it somewhere else
LW	R6, R12, 0	# R6 = 10



