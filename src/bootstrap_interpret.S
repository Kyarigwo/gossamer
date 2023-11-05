
#include "common.S"


.global interpret

/*
################################################################################
#
# interpret module
#
################################################################################
*/
/*

# interpret - reads line, splits into words, and prints them out

arguments:
  none

returns:
  none

*/
interpret:
  sys_push4

1:
  call word_parse
  beqz a1, 2f           # If no word found, end of  line

  mv s0, a0             # Save word found
  mv s1, a1

  call handle_word      # try to handle like a word
  bnez a0, 1b

  mv a0, s0
  mv a1, s1
  call handle_number    # try to handle like  a number
  bnez a0, 1b           # if a0 != 0 next word
  mv a0, s0
  mv a1, s1
  call print
  call print_question_mark # bad end
  call print_newline
  li t0, 1
  sw t0, immediate_mode, t1
  sys_pop4
  ret

2:                    # good end
  lw t0, immediate_mode
  beqz t0, 3f
  call print_ok
  call print_newline
  sys_pop4
  ret

3:
  call print_compiled
  call print_newline
  sys_pop4
  ret

/*

# Handle word - handles a word that is in the dictionary

arguments:
  a0: base of input string
  a1: length of input string

returns:
  a0: 1 if handled, otherwise 0

*/
handle_word:
  sys_push4
  call find_word
  beqz a1, 3f           # word not in dicationary

  addi a1, a1, 1        # if word is not immediate  a1 = -1, so now 0
                        // if word is immediate, a1 = 2

  lw t0, immediate_mode # are we in immediate mode?
  or t0, t0, a1         # if either

  beqz t0, 1f           # we run the instructions
  call execute
  j 2f
1:                      # else
  lw t0, ptr_here       # store xt at here
  sw a0, 0(t0)
  addi t0, t0, SIZE
  sw t0, ptr_here, t1
2:
  li a0, 1
  sys_pop4
  ret
3:
  li a0, 0
  sys_pop4
  ret

/*

# handle_number -- handles a potential number

arguments:
  a0: base of input string
  a1: length of input string

returns:
  a0: 1 if handled, otherwise 0

*/
handle_number:
  sys_push4
  call word_to_number
  beqz a1, 3f
  lw t0, immediate_mode
  beqz t0, 1f
  ds_push1
  j 2f
1:
  call literal
2:
  li a0, 1
  sys_pop4
  ret

3:
  li a0, 0
  sys_pop4
  ret

.data
.p2align 2

execute_word:
  .4byte 0
  .4byte codeword_cont

codeword_cont:
  .4byte cont

.text

execute:
  sys_push4
  sw a0, execute_word, t0
  rs_pushIP
  la IP, execute_word
  j next

cont:
  rs_popIP
  sys_pop4
  ret
