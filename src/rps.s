# vim:sw=2 syntax=asm
.data
w: .asciiz "W"
l: .asciiz "L"
t: .asciiz "T"
.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout

play_game_once:
  add $sp $sp -12
  sw $ra 0($sp)
  jal gen_byte
  sw $v0 4($sp)
  jal gen_byte 
  sw $v0 8($sp)
  lw $t1 4($sp)
  lw $t2 8($sp)
  beq $t1 $t2 tie
  sub $t0 $t1 $t2 
  beq $t0 -1 lose
  beq $t0 2 lose
  beq $t0 -2 win
  beq $t0 1 win
  tie:
  la $a0 t
  li $v0 4
  syscall
  lw $ra 0($sp)
  add $sp $sp 12
  jr $ra
  lose:
  la $a0 l
  li $v0 4
  syscall
  lw $ra 0($sp)
  add $sp $sp 12
  jr $ra
  win:
  la $a0 w
  li $v0 4
  syscall
  lw $ra 0($sp)
  add $sp $sp 12
  jr $ra
