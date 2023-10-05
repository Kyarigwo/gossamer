/*
################################################################################
#
# Builtin words, as well as the cold start function
#
################################################################################
*/
#include "common.S"
#include "macros.S"

.global cold_start, lit_codeword, print
.global print_newline, print_ok, print_compiled, print_space, print_question_mark
/*

# cold start

*/

cold_start:
  jal x5, sys_push4

# bye
  call add_gmer_bye
  call add_gmer_print
  call add_gmer_version
  call add_gmer_hello_world
  call add_gmer_goodbye_world
  call add_gmer_dot
  call add_gmer_lit
  call add_gmer_colon

  call add_gmer_push_hello_world

  call add_gmer_semicolon
  lw a0, ptr_latest
  call set_immediate

  call add_gmer_print_wordlist
  call add_gmer_bool_dot

  call add_gmer_ptr_here
  call add_gmer_input_buffer

  call add_gmer_peek
  call add_gmer_peek_byte

  call add_gmer_poke
  call add_gmer_poke_byte

  call add_gmer_plus
  call add_gmer_minus
  call add_gmer_times

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

make_codeword push_hello_world, "hw"
  la a0, hello_world_msg_length
  la a1, hello_world_msg
  push2
  j next

make_codeword print, "print"
  pop2
  mv t0, a0
  mv a0, a1
  mv a1, t0
  call print
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
  pop1
  call number_to_word
  call print
  call print_space
  j next

make_codeword lit, "lit"
  lw a0, 0(IP)
  push1
  addi IP, IP, SIZE
  j next

make_codeword colon, ":"
  jal x5, sys_push4
  call word_parse
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
  pop1
  beqz a0, 1f
  call print_true
  j 2f
1:
  call print_false
2:
  jal x5, sys_pop4
  j next

/*
################################################################################
#
# memory access
#
################################################################################
*/
make_codeword peek, "?"
  pop1
  lw a0, 0(a0)
  push1
  j next

make_codeword peek_byte, "b?"
  pop1
  lb a0, 0(a0)
  push1
  j next

make_codeword poke, "!"
  pop2
  sw a1, 0(a0)
  j next

make_codeword poke_byte, "b!"
  pop2
  sb a1, 0(a0)
  j next

/*
################################################################################
#
# System variables
#
################################################################################
*/
make_codeword ptr_here, "here&"
  la a0, ptr_here
  push1
  j next

make_codeword input_buffer, "input-buffer"
  la a1, input_buffer
  lw a0, input_buffer_size
  push2
  j next

/*

# print constants

*/

/*

#  print -- writes bytes to standard out

arguments:
  a0: base of string to write
  a1: size of string to write

returns:
  nothing

*/
print:
  mv a2, a1
  mv a1, a0
  li a0, 1          # stdout
  li a7, SYS_WRITE
  ecall
  ret

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

/*
################################################################################
#
# Arithmatic
#
################################################################################
*/

make_codeword plus, "+"
  pop2
  add a0, a0, a1
  push1
  j next

make_codeword minus, "-"
  pop2
  sub a0, a1, a0
  push1
  j next

make_codeword times, "*"
  pop2
  mul a0, a1, a0
  push1
  j next