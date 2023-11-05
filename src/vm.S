

#include "common.S"

.global enter, next, code_exit, codeword_exit

/*
################################################################################
#
# VM module
#
################################################################################
*/

enter:
  rs_pushIP
  addi IP, t1, SIZE
next:
  lw t1, 0(IP)
  lw t2, 0(t1)
  addi IP, IP, SIZE
  jr t2

code_exit:
  rs_popIP
  j next

.data
.p2align 2

codeword_exit:
  .4byte code_exit

