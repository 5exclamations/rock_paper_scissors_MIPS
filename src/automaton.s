# vim:sw=2 syntax=asm
.data
FinalText: .space 1024
ReversedText: .space 1024
Num: .space 1024
ReverseNum: .space 1024
.text
  .globl simulate_automaton, print_tape

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)

simulate_automaton:

   add $sp $sp -36
   sw $ra 0($sp)
   sw $s0 4($sp)
   sw $s1 8($sp)
   sw $s2 12($sp)
   sw $s3 16($sp)
   sw $s4 20($sp)
   sw $s5 24($sp)    
   li $s2 2
   li $s4 1
   lb $s0 8($a0)
   lw $s1 4($a0)
   jal convert_to_binary
   move $t0 $s1 #tape
   lb $s1 9($a0)
   jal convert_to_binary
   move $t1 $s1 #rule
   li $s4 0
  
  ten_to_s0:
  	li $t2 1
  	sw $s0 28($sp)
  ten_to_s0_continue:
  	mul $t2 $t2 10
  	sub $s0 $s0 1
  	bgtz $s0 ten_to_s0_continue
  	lw $s0 28($sp)
  	move $s3 $s0
  	li $s2 10     
  	div $t2 $t2 10
  	
  create_byte:
    	div $t0 $s2
    	mfhi $t3
    	mul $t3 $t3 100
    	div $t4 $t0 $t2
    	sw $t4 28($sp)
    	mul $t4 $t4 10
    	add $t3 $t3 $t4
    	div $t0 $t2
    	mfhi $t4
    	div $t5 $t2 $s2
    	div $t4 $t4 $t5
    	add $t3 $t3 $t4
    	sub $s0 $s0 1
    	jal change_num
    	
  center_byte: 
    	li $s2 10              
    	beq $s0 1 right_byte
    	div $t0 $t2
    	mflo $t4
    	mfhi $t5
    	mul $t4 $t4 100
    	div $t2 $s2
    	mflo $t6
    	div $t5 $t5 $t6
    	mul $t5 $t5 10
    	add $t3 $t4 $t5
    	div $t5 $t2 10
    	div $t0 $t5
    	mfhi $t5
    	div $t6 $t2 100
    	div $t5 $t5 $t6 
    	add $t3 $t3 $t5
    	sub $s0 $s0 1
    	div $t0 $t2
    	mfhi $t0
    	div $t2 $t2 10
    	jal change_num
    	j center_byte
    	
  change_num:
    	li $s3 1
   	sw $t1 32($sp)
    	li $t7 10
  change_num_continue:
  	div $t3 $t3 10
   	mfhi $s2 
        mul $s2 $s2 $s3
        mul $s3 $s3 2
        add $s4 $s4 $s2
        bnez $t3 change_num_continue
  change_num_continue1:
        beqz $s4 change_num_continue2
        div $t1 $t1 $t7
        sub $s4 $s4 1
   change_num_continue2:
        bnez $s4 change_num_continue1
        div $t1 $t1 10 
        mfhi $s2
        mul $a1  $a1 10
        add $a1 $a1 $s2
        lw $t1 32($sp)
    	jr $ra
    	
  convert_to_binary:
        add $sp $sp -12
	sw $ra 0($sp)
	sw $t0 28($sp)
	sw $t1 32($sp)
	li $v0 0
	li $t0 0
	li $t1 1
	convert_to_binary_continue:
	div $s1 $s1 2
	mfhi $t0
	mul $t0 $t0 $t1
	mul $t1 $t1 10
	addu $v0 $v0 $t0
	bge $s1 1 convert_to_binary_continue
	lw $ra 0($sp)
	lw $t0 28($sp)
	lw $t1 32($sp)
	add $sp $sp 12
	move $s1 $v0
	jr $ra
  right_byte:
    	div $t4 $t0 $t2
    	mfhi $t5
    	mul $t4 $t4 100
    	mul $t5 $t5 10
    	add $t3 $t4 $t5
    	lw $t5 28($sp)
    	add $t3 $t3 $t5
    	jal change_num
  convert_to_decimal:
        li $s2 1
        li $s3 0
  convert_to_decimal_continue:
      	div $a1 $a1 10
      	mfhi $s3
      	mul $s3 $s3 $s2
      	mul $s2 $s2 2
      	add $s4 $s4 $s3
      	bnez $a1 convert_to_decimal_continue 
    	sw $s4 4($a0)
    	lw $ra 0($sp)
    	lw $s0 4($sp)
    	lw $s1 8($sp)
    	lw $s2 16($sp)
    	lw $s3 20($sp)
    	lw $s4 24($sp)
    	lw $s5 28($sp)
    	add $sp $sp 36
    	jr $ra	

# Print the tape of the cellular automaton
# A+36rguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_
print_tape:
  lw $t0 4($a0)
  lb $t1 8($a0)
  add $sp $sp -12
  sw $s1 4($sp)
  sw $s2 8($sp)
  li $t4 'X'
  li $t5 '_'
  la $s1 FinalText
  la $s2 ReversedText
  sw $ra 0($sp)
divide: 
div $t0 $t0 2
mfhi $t3 
beq $t3 1 printX
divide1:
beq $t3 0 printN
divide2:
add $t1 $t1 -1
bge $t1 1 divide
jal reverse
divide3:
add $s2 $s2 1 
li $v0 4
la $a0 ReversedText
syscall
li $v0 11
li $a0 '\n'
syscall
lw $ra 0($sp)
lw $s1 4($sp)
lw $s2 8($sp)
add $sp $sp 12
jr $ra
printX:
sb $t4 ($s1)
add $s1 $s1 1
b divide1
printN:
sb $t5 ($s1)
add $s1 $s1 1
b divide2
reverse: 
lb $t6 8($a0)
add $s1 $s1 -1
reverse1:
lb $t7 ($s1)
sb $t7 ($s2)
add $t6 $t6 -1
add $s1 $s1 -1
add $s2 $s2 1
beqz $t6 divide3
j reverse1
