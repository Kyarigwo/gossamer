/*
################################################################################
#
# Code that describes the format of words in the dictionary, and hence code to
* both create, modfy and extract information from these words.
#
################################################################################
*/

#include "../common.S"


.global add_dictionary
.global wt_to_name, wt_to_xt, wt_immediate
.global header, end_word, add_codeword, set_immediate

add_dictionary:
  sys_push4
  call add_gmer_wt_to_name
  call add_gmer_wt_to_xt
  call add_gmer_wt_immediate
  call add_gmer_header
  call add_gmer_add_codeword
  call add_gmer_end_word
  call add_gmer_immediate
  sys_pop4
  ret

/*
################################################################################
#
# Create add codewords
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

make_codeword wt_immediate, "immediate?"
  ds_pop1
  call wt_immediate
  ds_push1
  j next

/*
################################################################################
#
# Create new words
#
################################################################################

words are stored in a linked list, formated as below, each
line being 4 bytes long

0:               [ latest       ]
SIZE:            [len][name     ]
n * SIZE         [ does codeword]
n * SIZE + SIZE: [ codeword     ]

define:
  wt - word token, pointer to the start of word.
  xt - address of codeword.
  dt - address of does codeword

  need to, given a wt we can

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
################################################################################
#
# extract information from a word token
#
################################################################################
*/
/*

# wt_to_name -- gets the name from a name token

arguments:
  a0: word token

returns:
  a0: start of name
  a1: length of name

*/
wt_to_name:
  lb a1, (2 * SIZE)(a0)
  addi a0, a0, 2 * SIZE + 1
  ret

/*

# wt_to_xt -- gets the execution token from a name token

arguments:
  a0: word token

returns:
  a0: exection token

*/
wt_to_xt:
  lw a0, SIZE(a0)
  andi a0, a0, -4   # -4 = 111111100 -- clears flag bits
  ret

/*

# wt_immediate -- is the immediate flag set?

arguments:
  a0: word token

returns:
  a0: 0 if immediate flag is not set.

*/
wt_immediate:
  lw a0, SIZE(a0)
  andi a0, a0, 1   # gets bit 0
  ret

