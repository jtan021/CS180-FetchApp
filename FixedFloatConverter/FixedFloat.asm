# Simple Program that reads in an integer, and casts it to a 
# floating point value. For example the floating point number
# 1.5 has a hex value of 0x3FC00000. This hex number has an
# integer value of 1,069,547,520.
#
# Sample Input : 1069547520
# Sample Output: 1.50000000

.text

main:
start:
   la $a0, OPSTR		# load OPSTR to be output
   li $v0, 4			# syscall 4 (print_str)
   syscall 			# outputs the string at $a0
   
   li $v0, 5			# syscall 5 (read_int)
   syscall			# reads an into into $v0
   
   beq $v0, $zero, function1	# If v0 == 0, function1 (fixed->float)
   
##############################
## Part 2 -- FLOATING TO FIXED
# Get decimal position and load it into $t0
   la    $a0, STR1   		# load STR1 to be output
   li    $v0, 4     		# syscall 4 (print_str)
   syscall           		# outputs the string at $a0

   li    $v0, 5      		# syscall 5 (read_int)
   syscall      	     	# reads an int into $v0
   
   add $t0, $v0, $zero		# store decimal position into $t0
   
# Get floating point value and load it into $t1
   la	$a0, STR3    		# load STR2 to be output
   li	$v0, 4			# syscall 4 (print_str)
   syscall			# outputs the string at $a0
   
   li	$v0, 6			# syscall 6 (read_float)
   syscall
   	
   mfc1 $t1, $f0		#t1 contains the binary value of the float
   
#Check if input = 0
   beqz $t1, OUTPUT_NUM		#If input = 0, output 0
   
   lw $t2, NEG_FLAG
   and $s0, $t1, $t2		#s0 determines sign; 0 = pos
   
   subiu  $t2, $t2, 1		#sub 1 from neg flag
   and $t1, $t1, $t2		#remove signage from float and place result into t1
   srl $s1, $t1, 23 		#s1 contains exponent+127
   subi $t5, $s1, 127 		#t5 = real exponent
   
   add $t5, $t5, $t0		#Number of shifts to be subtracted
   
   addi $t6, $0, 23
   not $t5, $t5
   addi $t5, $t5, 1
   add $t5, $t5, $t6		#Numbers of shifts required to the right
   
   #Isolate fraction bits by shifting left 9 times then back right 9 times
   sll $t1, $t1, 9		
   srl $t1, $t1, 9
   
   ori $t1, $t1, 8388608 	#Place 1 in front of fractional bits
 
   srlv $t1, $t1, $t5		#Shift $t1 over $t5 timess to obtain final result
#flag for removed code location
   beqz $s0, OUTPUT_NUM		#If sign flag is = 0, original # was positive so skip negative handler
   
#Negative handler
   not $t1, $t1
   addi $t1, $t1, 1
   
OUTPUT_NUM:
   add $a0, $t1, $0		#Store result into v0 to output
   li $v0, 1
   syscall
   
   j start
   
###########################
# Part 1 -- FIXED TO FLOATING
# Register t0 holds decimal position
# Register t1 holds fixed point value
# Register t2 will hold # of shifts needed to normalize
# Register t3 will hold the corrected t1 value in case of errors
# Register t4 will 8 exponent bits
# Register t5 will hold mantissa
# Register t6 will hold t2 for evaluating the fraction
# Register t7 holds result

function1:
# Get decimal position and load it into $t0
   la    $a0, STR1   		# load STR1 to be output
   li    $v0, 4     		# syscall 4 (print_str)
   syscall           		# outputs the string at $a0

   li    $v0, 5      		# syscall 5 (read_int)
   syscall      	     	# reads an int into $v0
   
   add $t0, $v0, $zero		# store decimal position into $t0
   
# Get fixed point value and load it into $t1
   la	$a0, STR2    		# load STR2 to be output
   li	$v0, 4			# syscall 4 (print_str)
   syscall			# outputs the string at $a0
   
   li	$v0, 5			# syscall 5 (read_int)
   syscall
   add $t1, $v0, $zero		# store fixed point value into $t1

# Check if either inputs are 0
# If $t0 is Zero, output $t1 (fixed point value)
   add $v0, $t1, $zero		# set $v0 to $t1
   bnez $t0, CONT		# if $t0 != $zero, CONT
   addi $t1, $zero, 1		# set $t1 to 1

# If $t1 is Zero, output $t1 (fixed point value)
CONT:
   add $v0, $t1, $zero		# set $v0 to $t1
   beq $t1, $zero, FLOATOUT	# if $t1 == $zero, FLOATOUT
   add $t7, $zero, $zero	# Set $t7 to zero

# Check if $t1 is positive, if so then skip 2's compliment
   bgez $t1, POS_HANDLER	# if $t1 >= 0, POS_HANDLER

# If $t1 is negative then obtain 2's compliment and set sign bit in result:
   lw $t2, NEG_FLAG		# Load $t2 with negative flag
   xor $t7, $t7, $t2		# Load result with negative sign bit
   not $t1, $t1			# Invert bits of $t1
   add $t1, $t1, 1		# Add 1 to complete 2's compliment

# Function to handle if input is positve
POS_HANDLER:
   add $t2, $zero, $zero	# set $t2 equal to $0
   add $t3, $t1, $zero		# set $t3 equal to $t1

# Function to shift fixed point and determine exponent value
SHIFT_LOOP:
   beq $t3, 1, EVALUATE		# if $t3 == 1, EVALUATE
   srl $t3, $t3, 1		# shift $t3 to the right by 1 bit
   add $t2, $t2, 1		# Increment $t2 to obtain exponent value
   b SHIFT_LOOP

# Function to evaluate fraction
EVALUATE:
   addi $t6, $zero, 32		# Set $t6 to 32
   #not $t2, $t2
   #addi $t2, $t2, 1
   #add $t6, $t6, $t2
   sub $t6, $t6, $t2		# Subtract t2 from t6 to obtain # of shifts needed to obtain mantissa
   
   # Calculate exponent bits
   not $t0, $t0			# Invert bits of $t0
   addi $t0, $t0, 1		# Add 1 to complete 2's compliment
   add $t2, $t2, $t0		# $t2 = $t2 - $t0 ( To get actual exponents value )
   addi $t4, $t2, 127		# $t4 = $t2 + 127 ( To get exponent bits into $t4 )
   sll $t4, $t4, 23		# Shift t4 to the left 23 times to set it into bits [30 - 23]
   xor $t7, $t7, $t4		# XOR $t7 with $t4 to load bits [30 - 23] with the exponent bits
   
   # Calculate fraction/mantissa
   
   add $t5, $t1, $zero		# set $t5 equal to $t1
   sllv $t5, $t5, $t6		# shift $t5 left (#t6) times to obtain the mantissa
   srl $t5, $t5, 9		# shift $t5 right 9 times to set it into bits [22 - 0]
   
   xor $t7, $t7, $t5		# XOR %$t7 with $t5 to load bits [22 - 0] with the mantissa
   
   add $v0, $t7, $zero		# Set $v0 to result

# Function to output result
FLOATOUT:
   mtc1  $v0, $f12   		# moves integer to floating point register
   li    $v0, 2      		# syscall 2 (print_float)
   syscall           		# outputs the float at $f12

   j start
DONE:

.data

NEG_FLAG:
   .word 0x80000000
   
STR1:
   .asciiz "Enter an Integer for decimal position: \n"
  
STR2:
   .asciiz "Enter an Integer for fixed point value: \n"
   
STR3:
   .asciiz "Enter a floating point value: \n"
   
OPSTR:
   .asciiz "\nSelect an operation. Enter '0' for Fixed->Float or '1' for Float->Fixed: \n"
