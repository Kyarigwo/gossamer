
#include "common.S"


.global wt_to_name, wt_to_xt, wt_immediate, xt_to_wt
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

# xt>wt --gets the word token for this execution token

arguments:
  a0: xt

returns:
  a0: wt if found, or 0 if not

*/
xt_to_wt:
  mv a1, a0
  li a2, 5
loop:
  lw a3, 0(a0)
  beq a1, a3, found
  addi a0, a0, -SIZE
  addi a2, a2, -1
  bgt a2, x0, loop
  li a0, 0
  ret
found:
  addi a0, a0, -SIZE
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

