

#include "common.S"

.global enter, next, code_exit, execute, codeword_exit

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

execute_word:
  .4byte 0
  .4byte codeword_cont

codeword_cont:
  .4byte cont

codeword_exit:
  .4byte code_exit

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
