/*
################################################################################
#
# Builtin words, as well as the cold start function
#
################################################################################
*/
#include "common.S"

.global cold_start, lit_codeword, print
.global print_newline, print_ok, print_compiled, print_space,
.global print_question_mark
/*

# cold start

*/

cold_start:
  jal x5, sys_push4

#
  call add_gmer_bye
  call add_gmer_print
  call add_gmer_version
  call add_gmer_hello_world
  call add_gmer_goodbye_world
  call add_gmer_dot

  call add_gmer_push_hello_world

  call add_gmer_print_wordlist
  call add_gmer_bool_dot


  call add_gmer_peek
  call add_gmer_peek_byte

  call add_gmer_poke
  call add_gmer_poke_byte

  call add_gmer_plus
  call add_gmer_minus
  call add_gmer_times

# interpret words
  call add_gmer_refill_input
  call add_gmer_whitespace_parse
  call add_gmer_non_whitespace_parse
  call add_gmer_word_parse
  call add_gmer_string_eq
  call add_gmer_interpret
  call add_gmer_find_word
  call add_gmer_word_to_number
  call add_gmer_literal

# VM words
  call add_gmer_exit
  call add_gmer_execute

# Startup words
  call add_gmer_allot_memory

# System variables
  call add_gmer_ptr_here
  call add_gmer_here
  call add_gmer_input_buffer
  call add_gmer_parse_point
  call add_gmer_parse_point_size
  call add_gmer_latest_word
  call add_gmer_new_word
  call add_gmer_immediate_mode

# Compile words
  call add_gmer_header
  call add_gmer_add_codeword
  call add_gmer_end_word
  call add_gmer_immediate
  call add_gmer_semicolon
  lw a0, ptr_latest
  call set_immediate
  call add_gmer_lit
  call add_gmer_colon

# Dictionary words
  call add_gmer_wt_to_name
  call add_gmer_wt_to_xt
  call add_gmer_wt_immediate

# Utilities
  call add_gmer_memcpy


  jal x5, sys_pop4
  ret


.data

lit_codeword:
  .4byte gmer_lit

.text
/*
################################################################################
#
# interpret words
#
################################################################################
*/

make_codeword refill_input, "refill-input"
  call refill_input
  push2
  j next

make_codeword whitespace_parse, "whitespace-parse"
  call whitespace_parse
  push2
  j next

make_codeword non_whitespace_parse, "non-whitespace-parse"
  call non_whitespace_parse
  push2
  j next

make_codeword word_parse, "word-parse"
  call word_parse
  push2
  j next

make_codeword string_eq, "\"="
  pop4
  call string_eq
  push1
  j next

make_codeword interpret, "interpret"
  call interpret
  j next

make_codeword find_word, "find-word"
  pop2
  call find_word
  push2
  j next

make_codeword word_to_number, "\">#"
  pop2
  call word_to_number
  push1
  j next

make_codeword literal, "literal"
  pop1
  call literal
  j next

/*
################################################################################
#
# VM words
#
################################################################################
*/

make_codeword exit, "exit"
  j code_exit

make_codeword execute, "execute"
  pop1
  j execute
  j next

/*
################################################################################
#
# Startup words
#
################################################################################
*/

make_codeword allot_memory, "allot-memory"
  pop1
  call allot_memory
  push1
  j next

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
make_codeword ptr_here, "&here"
  la a0, ptr_here
  push1
  j next

make_codeword here, "^here"
  lw a0, ptr_here
  push1
  j next

make_codeword input_buffer, "input-buffer"
  la a1, input_buffer
  lw a0, input_buffer_size
  push2
  j next

make_codeword parse_point, "^parse"
  lw a0, parse_point
  push1
  j next

make_codeword parse_point_size, "#parse"
  lw a0, parse_point_size
  push1
  j next

make_codeword latest_word, "latest-word"
  lw a0, ptr_latest
  push1
  j next

make_codeword new_word, "new-word"
  lw a0, ptr_new_word
  push1
  j next

make_codeword immediate_mode, "immediate-mode"
  la a0, immediate_mode
  push1
  j next

/*
################################################################################
#
# compile words
#
################################################################################
*/

make_codeword header, "header"
  pop2
  call header
  j next

make_codeword add_codeword, "add-codeword"
  pop1
  call add_codeword
  j next

make_codeword end_word, "end-word"
  call end_word
  j next

make_codeword immediate, "immediate"
  lw a0, ptr_latest
  call set_immediate
  j next

/*
################################################################################
#
# Dictionary words
#
################################################################################
*/

make_codeword wt_to_name, "wt>name"
  pop1
  call wt_to_name
  push2
  j next

make_codeword wt_to_xt, "wt>xt"
  pop1
  call wt_to_xt
  push1
  j next

make_codeword wt_immediate, "immediate?"
  pop1
  call wt_immediate
  push1
  j next

/*
################################################################################
#
# Utilities
#
################################################################################
*/

make_codeword memcpy, "b-copy"
  pop3
  call gmer_memcpy
  push1
  j next


/*
################################################################################
#
# print constants
#
################################################################################
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