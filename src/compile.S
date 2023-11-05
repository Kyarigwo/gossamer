/*
################################################################################
#
# Functions to do with creating and modifying words
#
################################################################################
*/
#include "common.S"

.global add_compile, gmer_lit

add_compile:
  sys_push4

  call add_gmer_lit
  call add_gmer_two_lit
  call add_gmer_colon
  call add_gmer_branch
  call add_gmer_branch0
  call add_gmer_semicolon
  lw a0, ptr_latest
  call set_immediate

  sys_pop4
  ret

/*

# lit -- implimentation of literals

*/
make_codeword lit, "lit"
  lw a0, 0(IP)
  ds_push1
  addi IP, IP, SIZE
  j next

/*

# 2lit -- implimentation of double literals

*/
make_codeword two_lit, "2lit"
  lw a1, 0(IP)
  lw a0, (SIZE)(IP)
  ds_push2
  addi IP, IP, 2*SIZE
  j next

/*

# : -- starts compilation of a word

*/
make_codeword colon, ":"
  sys_push4
  call word_parse
  call header
  la a0, enter
  call add_codeword
  sw zero, immediate_mode, t0
  sys_pop4
  j next

/*

# ; -- ends compilation of a word

*/
make_codeword semicolon, ";"
  la a0, codeword_exit
  lw t0, ptr_here
  sw a0, 0(t0)
  addi t0, t0, SIZE
  sw t0, ptr_here, t1
  call end_word
  li t0, 1
  sw t0, immediate_mode, t1
  j next


make_codeword branch, "branch"
  lw a0, 0(IP)
  mv IP, a0
  j next

make_codeword branch0, "branch-false"
  lw a1, 0(IP)
  ds_pop1
  addi IP, IP, SIZE
  bnez a0, 1f
  mv IP, a1
1:
  j next