
#include "common.S"


.global wt_to_name, wt_to_xt, wt_immediate
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

