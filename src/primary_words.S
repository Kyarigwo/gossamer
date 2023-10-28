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

  call add_gmer_print_wordlist

  call add_gmer_peek
  call add_gmer_peek_byte

  call add_gmer_poke
  call add_gmer_poke_byte

  call add_system_variables
  call add_arithmatic
# Comparison

  call add_gmer_equals
  call add_gmer_not_equals
  call add_gmer_lt
  call add_gmer_gt
  call add_gmer_lteq
  call add_gmer_gteq


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

  call add_stack


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

make_codeword print, ">output"
  ds_pop2
  call print
  j next

make_codeword version, "version"
  call print_version
  j next

make_codeword print_wordlist, "wordlist"
  sys_push4
  lw s0, ptr_latest
1:
  beqz s0, 2f
  mv a0, s0
  call wt_to_name
  call print
  call print_newline
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

make_codeword peek_byte, "?:b"
  ds_pop1
  lb a0, 0(a0)
  ds_push1
  j next

make_codeword poke, "!"
  ds_pop2
  sw a0, 0(a1)
  j next

make_codeword poke_byte, "!:b"
  ds_pop2
  sb a0, 0(a1)
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
# Comparison
#
################################################################################
*/

make_codeword equals, "="
  ds_pop2
  beq a0, a1, 1f
  li a0, 0
  ds_push1
  j next
1:
  li a0, -1
  ds_push1
  j next

make_codeword not_equals, "!="
  ds_pop2
  beq a0, a1, 1f
  li a0, -1
  ds_push1
  j next
1:
  li a0, 0
  ds_push1
  j next

make_codeword lt, "<"
  ds_pop2
  blt a0, a1, 1f
  li a0, 0
  ds_push1
  j next
1:
  li a0, -1
  ds_push1
  j next

make_codeword lteq, "<="
  ds_pop2
  ble a0, a1, 1f
  li a0, 0
  ds_push1
  j next
1:
  li a0, -1
  ds_push1
  j next

make_codeword gt, ">"
  ds_pop2
  bgt a0, a1, 1f
  li a0, 0
  ds_push1
  j next
1:
  li a0, -1
  ds_push1
  j next

make_codeword gteq, ">="
  ds_pop2
  bge a0, a1, 1f
  li a0, 0
  ds_push1
  j next
1:
  li a0, -1
  ds_push1
  j next
