# Test the different branch conditions (using extra wires on the CPU to see
# the branch addresses directly)

		b neq, SkipHalt1
		HLT #1
Start:
SkipHalt1:	b gt, SkipHalt2
		HLT #2

SkipHalt2:	b gte, SkipHalt3
		HLT #3

SkipHalt3:	SUB R0, R0, R0	# Set Z
		b neq, SkipHalt4
		b gt, SkipHalt4
		b ovfl, SkipHalt4
		b eq, SkipHalt4
		HLT #4

SkipHalt4:	b lte, SkipHalt5
		HLT #5

SkipHalt5:	ADD R0, R1, R1 # Clear flags (branches stop working after this...)
		b eq, SkipHalt6
		SUB R2, R2, R3 # Set N
		#b ovfl, SkipHalt6
		b uncond, SkipHalt6
		HLT #6

SkipHalt6:	b lte, SkipHalt7
		HLT #7

SkipHalt7:	ADD R1, R1, R0 # Clear flags
		b lt, SkipHalt8
		ADD R0, R10, R10 # Set V
		b lt, SkipHalt8
		b ovfl, SkipHalt8
		HLT #8

SkipHalt8:	b uncond, Start