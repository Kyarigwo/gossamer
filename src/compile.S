/*
################################################################################
#
# Functions to do with creating and modifying words
#
################################################################################
*/
#include "common.S"

.global header, end_word, add_codeword, set_immediate
.global add_gmer_lit, add_gmer_colon, add_gmer_semicolon, gmer_lit
.global add_gmer_branch, add_gmer_branch0

/*
################################################################################
#
# Create new words
#
################################################################################

words are stored in a linked list, formated as below, each
line being 4 bytes long

0:        [ latest       ]
SIZE:     [ codeword ptr ]
2 * SIZE: [len][name     ]
n * SIZE: [ codeword     ]

define:
  wt - word token, pointer to the start of word.
  xt - value of codeword ptr, pointer to codeword.

*/

/*

# header -- Creates a new header from given string

arguments:
  a0: base of input string
  a1: length of input string

returns:
  nothing

0:        [ latest       ]
SIZE:     [ codeword ptr ] - lowest two bits are used as flags
2 * SIZE: [len][name     ]
n * SIZE: [ codeword     ]

*/

header:

  sys_push4

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

  sys_pop4

  ret

/*

# add_codeword -- adds a code word to new word

arguments:
  a0: address of codeword to add

*/
add_codeword:
  lw t0, ptr_here
  sw a0, 0(t0)
# bump here
  addi t0, t0, SIZE
  sw t0, ptr_here, t1
  ret


/*

# end_word -- updates latest to point to new word

*/
end_word:
  lw t0, ptr_new_word
  sw t0, ptr_latest, t1
  ret

/*

# set_immediate -- updates the word in a0 to be immediate

arguments:
  a0: word token

returns:
  nothing

*/
set_immediate:
  lw t0, SIZE(a0)
  ori t0, t0, 1
  sw t0, SIZE(a0)
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