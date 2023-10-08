

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
  pushr1 IP
  addi IP, t0, SIZE
next:
  lw t0, 0(IP)
  lw t1, 0(t0)
  addi IP, IP, SIZE
  jr t1

code_exit:
  popr1 IP
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
  jal x5, sys_push4
  sw a0, execute_word, t0
  pushr1 IP
  la IP, execute_word
  j next

cont:
  popr1 IP
  jal x5, sys_pop4
  ret
