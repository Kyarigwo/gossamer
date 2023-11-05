/*
################################################################################
#
# Builtin words, as well as the cold start function
#
################################################################################
*/
#include "../common.S"

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

# Logical

  call add_gmer_or
  call add_gmer_and
  call add_gmer_not

# interpret words
  call add_input_parsing

#  call add_gmer_interpret


  call add_gmer_literal

# Startup words
  call add_gmer_allot_memory

# Compile words
  call add_compile

  # dictionary
  call add_dictionary

# Utilities
  call add_gmer_b_memcpy

  call add_stack

  sys_pop4
  ret


.data

lit_codeword:
  .4byte gmer_lit

.text


make_codeword literal, "literal"
  ds_pop1
  call literal
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
# Utilities
#
################################################################################
*/

make_codeword b_memcpy, "{mem}>{mem}:b"
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
  xor a0, a0, a1
  seqz a0, a0
  ds_push1
  j next

make_codeword not_equals, "!="
  ds_pop2
  xor a0, a0, a1
  ds_push1
  j next

make_codeword lt, "<"
  ds_pop2
  slt a0, a0, a1
  ds_push1
  j next

make_codeword lteq, "<="
  ds_pop2
  slt a2, a0, a1
  xor a0, a0, a1
  seqz a0,  a0
  or a0, a0, a2
  ds_push1
  j next

make_codeword gt, ">"
  ds_pop2
  slt a0, a1, a0
  ds_push1
  j next

make_codeword gteq, ">="
  ds_pop2
  slt a2, a1, a0
  xor a0, a0, a1
  seqz a0, a0
  or a0, a0, a2
  ds_push1
  j next

/*
################################################################################
#
# Logical operations
#
################################################################################
*/

make_codeword or, "or"
  ds_pop2
  snez a0, a0
  snez a1, a1
  or a0, a0, a1
  ds_push1
  j next

make_codeword and, "and"
  ds_pop2
  snez a0, a0
  snez a1, a1
  and a0, a0, a1
  ds_push1
  j next

make_codeword not, "not"
  ds_pop1
  seqz a0, a0
  ds_push1
  j next