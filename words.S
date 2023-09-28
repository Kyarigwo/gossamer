#include "common.S"

.global header, end_word, add_codeword

/*
################################################################################
#
# Create new words
#
################################################################################
*/

/*

# Creates a new header from given string

arguments:
  a0: base of input string
  a1: length of input string

0:        [ latest   ]
SIZE:     [ codeword ]
2 * SIZE: [len][name ]

*/

header:

  jal x5, sys_push4

  lw s0, ptr_here           # here
  lw t0, ptr_latest         # latest

  sw t0, 0(s0)              # here = latest

  sw s0, ptr_new_word, t0   # ptr_new_word = here

  sw zero, SIZE(s0)         # here + SIZE = zero
  sb a1, (2*SIZE)(s0)       # here + 2 * SIZE = name.length

  addi a2, s0, (2*SIZE + 1) # location to write name = here + 2 * SIZE + 1

  call gmer_memcpy          # a0 = 1 past end of string
  call align_4byte          # a0 to align on 4bytes

  sw a0, SIZE(s0)
  sw a0, ptr_here, t0       # here = a0

  jal x5, sys_pop4

  ret

add_codeword:
  lw t0, ptr_here
  sw a0, 0(t0)
# bump here
  addi t0, t0, SIZE
  sw t0, ptr_here, t1
  ret

end_word:
  lw t0, ptr_new_word
  sw t0, ptr_latest, t1
  ret
