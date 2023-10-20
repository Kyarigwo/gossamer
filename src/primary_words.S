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
  sys_push4

#
  call add_gmer_bye
  call add_gmer_print
  call add_gmer_version
  call add_gmer_dot

  call add_gmer_print_wordlist

  call add_gmer_peek
  call add_gmer_peek_byte

  call add_gmer_poke
  call add_gmer_poke_byte

# Arithmatic

  call add_gmer_plus
  call add_gmer_minus
  call add_gmer_times

# Comparison



# interpret words
  call add_gmer_refill_input
  call add_gmer_whitespace_parse
  call add_gmer_non_whitespace_parse
  call add_gmer_word_parse
  call add_gmer_char_parse
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
  call add_gmer_cell

# Compile words
  call add_gmer_header
  call add_gmer_add_codeword
  call add_gmer_end_word
  call add_gmer_immediate
  call add_gmer_semicolon

  lw a0, ptr_latest
  call set_immediate

  call add_gmer_lit
  call add_gmer_two_lit
  call add_gmer_colon
  call add_gmer_branch
  call add_gmer_branch0

# Dictionary words
  call add_gmer_wt_to_name
  call add_gmer_wt_to_xt
  call add_gmer_xt_to_wt
  call add_gmer_wt_immediate

# Utilities
  call add_gmer_b_memcpy

# Stack manipulation
  call add_gmer_drop
  call add_gmer_swap
  call add_gmer_nip
  call add_gmer_dup
  call add_gmer_over
  call add_gmer_tuck
  call add_gmer_rot
  call add_gmer_minus_rot

# stack manipulation 2
  call add_gmer_two_drop
  call add_gmer_two_swap
  call add_gmer_two_nip
  call add_gmer_two_dup
  call add_gmer_two_over
  call add_gmer_two_tuck
  call add_gmer_two_rot
  call add_gmer_two_minus_rot

  sys_pop4
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
  ds_push2
  j next

make_codeword whitespace_parse, "whitespace-parse"
  call whitespace_parse
  ds_push2
  j next

make_codeword non_whitespace_parse, "non-whitespace-parse"
  call non_whitespace_parse
  ds_push2
  j next

make_codeword word_parse, "word-parse"
  call word_parse
  ds_push2
  j next

make_codeword char_parse, "char-parse"
  ds_pop1
  call char_parse
  ds_push2
  j next

make_codeword string_eq, "\"="
  ds_pop4
  call string_eq
  ds_push1
  j next

make_codeword interpret, "interpret"
  call interpret
  j next

make_codeword find_word, "find-word"
  ds_pop2
  call find_word
  ds_push2
  j next

make_codeword word_to_number, "\">#"
  ds_pop2
  call word_to_number
  ds_push2
  j next

make_codeword literal, "literal"
  ds_pop1
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
  ds_pop1
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
  ds_pop1
  call allot_memory
  ds_push1
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

make_codeword print, "print"
  ds_pop2
  call print
  j next

make_codeword version, "version"
  call print_version
  j next

make_codeword dot, "."
  ds_pop1
  call number_to_word
  call print
  call print_space
  j next

make_codeword print_wordlist, "wordlist"
  sys_push4
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
  sys_pop4
  j next


/*
################################################################################
#
# memory access
#
################################################################################
*/
make_codeword peek, "?"
  ds_pop1
  lw a0, 0(a0)
  ds_push1
  j next

make_codeword peek_byte, "b?"
  ds_pop1
  lb a0, 0(a0)
  ds_push1
  j next

make_codeword poke, "!"
  ds_pop2
  sw a0, 0(a1)
  j next

make_codeword poke_byte, "b!"
  ds_pop2
  sb a0, 0(a1)
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
  ds_push1
  j next

make_codeword here, "^here"
  lw a0, ptr_here
  ds_push1
  j next

make_codeword input_buffer, "input-buffer"
  la a0, input_buffer
  lw a1, input_buffer_size
  ds_push2
  j next

make_codeword parse_point, "^parse"
  lw a0, parse_point
  ds_push1
  j next

make_codeword parse_point_size, "#parse"
  lw a0, parse_point_size
  ds_push1
  j next

make_codeword latest_word, "latest-word"
  lw a0, ptr_latest
  ds_push1
  j next

make_codeword new_word, "new-word"
  lw a0, ptr_new_word
  ds_push1
  j next

make_codeword immediate_mode, "immediate-mode"
  la a0, immediate_mode
  ds_push1
  j next

make_codeword cell, "cell"
  li a0, 4
  ds_push1
  j next

/*
################################################################################
#
# compile words
#
################################################################################
*/

make_codeword header, "header"
  ds_pop2
  call header
  j next

make_codeword add_codeword, "add-codeword"
  ds_pop1
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
  ds_pop1
  call wt_to_name
  ds_push2
  j next

make_codeword wt_to_xt, "wt>xt"
  ds_pop1
  call wt_to_xt
  ds_push1
  j next

make_codeword xt_to_wt, "xt>wt"
  ds_pop1
  call xt_to_wt
  ds_push1
  j next

make_codeword wt_immediate, "immediate?"
  ds_pop1
  call wt_immediate
  ds_push1
  j next

/*
################################################################################
#
# Utilities
#
################################################################################
*/

make_codeword b_memcpy, "b-copy"
  ds_pop3
  call gmer_memcpy
  ds_push1
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

print_literal newline, "\n"

print_literal space, " "

print_literal ok, "ok"

print_literal compiled, "compiled"

print_literal question_mark, "?"

print_literal version, "Version 1.0\n"

/*
################################################################################
#
# Arithmatic
#
################################################################################
*/

make_codeword plus, "+"
  ds_pop2
  add a0, a0, a1
  ds_push1
  j next

make_codeword minus, "-"
  ds_pop2
  sub a0, a0, a1
  ds_push1
  j next

make_codeword times, "*"
  ds_pop2
  mul a0, a1, a0
  ds_push1
  j next

/*
################################################################################
#
# Comparison
#
################################################################################
*/

make_codeword equals, "="
  ds_pop2


/*
################################################################################
#
# stack manipulation
#
################################################################################
*/

make_codeword drop, "drop"
  ds_pop1
  j next

make_codeword swap, "swap"
  ds_pop2
  mv t0, a0
  mv a0, a1
  mv a1, t0
  ds_push2
  j next

make_codeword nip, "nip"
  ds_pop2
  mv a0, a1
  ds_push1
  j next

make_codeword dup, "dup"
  ds_pop1
  mv a1, a0
  ds_push2
  j next

make_codeword over, "over"
  ds_pop2
  mv a2, a0
  ds_push3
  j next

make_codeword tuck, "tuck"
  ds_pop2
  mv a2, a1
  mv a1, a0
  mv a0, a2
  ds_push3
  j next

make_codeword rot, "rot"
  ds_pop3
  mv t0, a0
  mv a0, a1
  mv a1, a2
  mv a2, t0
  ds_push3
  j next

make_codeword minus_rot, "-rot"
  ds_pop3
  mv t0, a2
  mv a2, a1
  mv a1, a0
  mv a0, t0
  ds_push3
  j next

/*
################################################################################
#
# Double stack manipulation
#
################################################################################
*/

make_codeword two_drop, "2drop"
  ds_pop2
  j next

make_codeword two_swap, "2swap"
  ds_pop4
  mv t0, a0
  mv t1, a1
  mv a0, a2
  mv a1, a3
  mv a2, t0
  mv a3, t1
  ds_push4
  j next

make_codeword two_nip, "2nip"
  ds_pop4
  mv a0, a2
  mv a1, a3
  ds_push4
  j next

make_codeword two_dup, "2dup"
  ds_pop2
  mv a2, a0
  mv a3, a1
  ds_push4
  j next

make_codeword two_over, "2over"
  ds_pop4
  mv a4, a0
  mv a5, a1
  ds_push6
  j next

make_codeword two_tuck, "2tuck"
  ds_pop4
  mv a4, a2
  mv a5, a3
  mv a2, a0
  mv a3, a1
  mv a0, a4
  mv a1, a5
  ds_push6
  j next

make_codeword two_rot, "2rot"
  ds_pop6
  mv t0, a0
  mv t1, a1
  mv a0, a2
  mv a1, a3
  mv a2, a4
  mv a3, a5
  mv a4, t0
  mv a5, t1
  ds_push6
  j next

make_codeword two_minus_rot, "-2rot"
  ds_pop6
  mv t0, a4
  mv t1, a5

  mv a4, a2
  mv a5, a3

  mv a2, a0
  mv a3, a1

  mv a0, t0
  mv a1, t1

  ds_push6
  j next
