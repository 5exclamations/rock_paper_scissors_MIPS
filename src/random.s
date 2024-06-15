# vim:sw=2 syntax=asm
.data

.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#
gen_byte:
  addiu $sp $sp -4
  sw $ra 0($sp)
  eq:
  jal gen_bit
  move $a3 $v0
  jal gen_bit
  move $t1 $v0
  and $t2 $a3 $t1
  bnez $t2 eq
  sll $v0 $a3 1
  or $v0 $v0 $t1
  lw $ra 0($sp)
  addiu $sp $sp 4
  jr $ra

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#
gen_bit:
	addi $sp $sp -8
  	sw $a0 0($sp)
  	sw $ra 4($sp)
  	lw $t5 0($a0)
  	lb $s1 10($a0)
  	lb $t3 11($a0)
  	lb $t4 8($a0)
  	subi $t4 $t4 1
  	subu $s6 $t4 $t3
  	bnez $t5 update
  	lw $a1 4($a0)
  	li $v0 40
  	syscall
  	li $a0 0
  	li $v0 41
  	syscall
  	andi $v0 $a0 1
  	j terminate
  update: 
    	beqz $s1 column
    	subi $s1 $s1 1
    	jal  simulate_automaton
    	j update
  column:
    	lw $t1 4($a0)
    	srlv $t1 $t1 $s6
    	andi $t1 $t1 1
    	move $v0 $t1
    	move $t1 $zero 
  terminate:
    	lw $a0 0($sp)
    	lw $ra 4($sp)
    	addi $sp $sp 8
	jr $ra