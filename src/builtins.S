/*
################################################################################
#
# Builtin words, as well as the cold start function
#
################################################################################
*/
#include "common.S"
#include "macros.S"

.global cold_start, lit_codeword
.global print_newline, print_ok, print_compiled, print_space, print_question_mark
/*

# cold start

*/

cold_start:
  jal x5, sys_push4

# bye
  call add_gmer_bye
  call add_gmer_version
  call add_gmer_hello_world
  call add_gmer_goodbye_world
  call add_gmer_dot
  call add_gmer_lit
  call add_gmer_colon

  call add_gmer_semicolon
  lw a0, ptr_latest
  call set_immediate

  call add_gmer_print_wordlist
  call add_gmer_bool_dot

  jal x5, sys_pop4
  ret


.data

lit_codeword:
  .4byte gmer_lit

.text
/*
################################################################################
#
# compiled wordlist
#
################################################################################
*/

make_codeword bye, "bye"
  li a0, 0
  li a7, SYS_EXIT
  ecall
  j next

make_codeword version, "version"
  call print_version
  j next

make_codeword hello_world, "hello-world"
  call print_hello_world
  j next

make_codeword goodbye_world, "goodbye-world"
  call print_goodbye_world
  j next

make_codeword dot, "."
  pop1 a0
  call number_to_word
  call print
  call print_space
  j next

make_codeword lit, "lit"
  lw t0, 0(IP)
  push1 t0
  addi IP, IP, SIZE
  j next

make_codeword colon, ":"
  jal x5, sys_push4
  call parse_word
  call header
  la a0, enter
  call add_codeword
  sw zero, immediate_mode, t0
  jal x5, sys_pop4
  j next

# gmer_semicolon:
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

make_codeword print_wordlist, "wordlist"
  jal x5, sys_push4
  lw s0, ptr_latest
1:
  beqz s0, 2f
  mv a0, s0
  call wt_to_name
  call print
  call print_space
  lw s0, 0(s0)
  j 1b
2:
  jal x5, sys_pop4
  j next

make_codeword bool_dot, "bool."
  jal x5, sys_push4
  pop1 a0
  beqz a0, 1f
  call print_true
  j 2f
1:
  call print_false
2:
  jal x5, sys_pop4
  j next


/*

# print constants

*/

print_literal pipe "|"

print_literal newline, "\n"

print_literal space, " "

print_literal ok, "ok"

print_literal compiled, "compiled"

print_literal question_mark, "?"

print_literal version, "Version 1.0\n"

print_literal goodbye_world, "Goodbye World!\n"

print_literal hello_world, "Hello World!\n"

print_literal true, "true\n"

print_literal false, "false\n"

