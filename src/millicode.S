#include "common.S"

.global l_sys_push4, l_sys_pop4
.global l_sys_push8, l_sys_pop8
.global l_ds_push1, l_ds_pop1
.global l_ds_push2, l_ds_pop2
.global l_ds_push3, l_ds_pop3
.global l_ds_push4, l_ds_pop4
.global l_ds_push5, l_ds_pop5
.global l_ds_push6, l_ds_pop6
.global l_rs_pushIP, l_rs_popIP

/*
################################################################################
#
# System stack manipulation
#
################################################################################
*/

l_sys_push4:
  addi sp, sp, -4*SIZE
  sw ra, 0(sp)
  sw s0, SIZE(sp)
  sw s1, 2*SIZE(sp)
  sw s2, 3*SIZE(sp)
  jr x5   # jump to x5

l_sys_pop4:
  lw ra, 0(sp)
  lw s0, SIZE(sp)
  lw s1, 2*SIZE(sp)
  lw s2, 3*SIZE(sp)
  addi sp, sp, 4*SIZE
  jr x5  # jump to x5

l_sys_push8:
  addi sp, sp, -8*SIZE

  sw ra, 0(sp)
  sw s0, SIZE(sp)
  sw s1, 2*SIZE(sp)
  sw s2, 3*SIZE(sp)

  sw s3, 4*SIZE(sp)
  sw s4, 5*SIZE(sp)
  sw s5, 6*SIZE(sp)
  sw s6, 7*SIZE(sp)

  jr x5   # jump to x5

l_sys_pop8:

  lw ra, 0(sp)
  lw s0, SIZE(sp)
  lw s1, 2*SIZE(sp)
  lw s2, 3*SIZE(sp)

  lw s3, 4*SIZE(sp)
  lw s4, 5*SIZE(sp)
  lw s5, 6*SIZE(sp)
  lw s6, 7*SIZE(sp)

  addi sp, sp, 8*SIZE
  jr x5  # jump to x5

/*
################################################################################
#
# Data stack manipulation - in s10
#
################################################################################
*/

/*

# push/pop a0 from stack

*/
l_ds_push1:
  addi DS, DS, -(1 * SIZE)
  sw a0, (0 * SIZE)(DS)
  jr x5

l_ds_pop1:
  lw a0, (0 * SIZE)(DS)
  addi DS,  DS, (1 * SIZE)
  jr x5

/*

# push/pop a0 a1

*/
l_ds_push2:
  addi DS, DS, -(2 * SIZE)
  sw a1, (0 * SIZE)(DS)
  sw a0, (1 * SIZE)(DS)
  jr x5

l_ds_pop2:
  lw a1, (0 * SIZE)(DS)
  lw a0, (1 * SIZE)(DS)
  addi DS,  DS, (2 * SIZE)
  jr x5

/*

# push/pop a0 a1 a2

*/
l_ds_push3:
  addi DS, DS, -(3 * SIZE)
  sw a2, (0 * SIZE)(DS)
  sw a1, (1 * SIZE)(DS)
  sw a0, (2 * SIZE)(DS)
  jr x5

l_ds_pop3:
  lw a2, (0 * SIZE)(DS)
  lw a1, (1 * SIZE)(DS)
  lw a0, (2 * SIZE)(DS)
  addi DS,  DS, (3 * SIZE)
  jr x5

/*

# push/pop  a0 a1 a2 a3

*/
l_ds_push4:
  addi DS, DS, -(4 * SIZE)
  sw a3, (0 * SIZE)(DS)
  sw a2, (1 * SIZE)(DS)
  sw a1, (2 * SIZE)(DS)
  sw a0, (3 * SIZE)(DS)
  jr x5

l_ds_pop4:
  lw a3, (0 * SIZE)(DS)
  lw a2, (1 * SIZE)(DS)
  lw a1, (2 * SIZE)(DS)
  lw a0, (3 * SIZE)(DS)
  addi DS, DS, (4 * SIZE)
  jr x5

/*

# push/pop  a0 a1 a2 a3 a4

*/
l_ds_push5:
  addi DS, DS, -(5 * SIZE)
  sw a4, (0 * SIZE)(DS)
  sw a3, (1 * SIZE)(DS)
  sw a2, (2 * SIZE)(DS)
  sw a1, (3 * SIZE)(DS)
  sw a0, (4 * SIZE)(DS)
  jr x5

l_ds_pop5:
  lw a4, (0 * SIZE)(DS)
  lw a3, (1 * SIZE)(DS)
  lw a2, (2 * SIZE)(DS)
  lw a1, (3 * SIZE)(DS)
  lw a0, (4 * SIZE)(DS)
  addi DS, DS, (5 * SIZE)
  jr x5

/*

# push/pop  a0 a1 a2 a3 a4 a5

*/
l_ds_push6:
  addi DS, DS, -(6 * SIZE)
  sw a5, (0 * SIZE)(DS)
  sw a4, (1 * SIZE)(DS)
  sw a3, (2 * SIZE)(DS)
  sw a2, (3 * SIZE)(DS)
  sw a1, (4 * SIZE)(DS)
  sw a0, (5 * SIZE)(DS)
  jr x5

l_ds_pop6:
  lw a5, (0 * SIZE)(DS)
  lw a4, (1 * SIZE)(DS)
  lw a3, (2 * SIZE)(DS)
  lw a2, (3 * SIZE)(DS)
  lw a1, (4 * SIZE)(DS)
  lw a0, (5 * SIZE)(DS)
  addi DS, DS, (6 * SIZE)
  jr x5


/*
################################################################################
#
# return stack - in s9
#
################################################################################
*/

l_rs_pushIP:
  addi RS, RS, -(1 * SIZE)
  sw IP, (0 * SIZE)(RS)
  jr x5

l_rs_popIP:
  lw IP, (0 * SIZE)(RS)
  addi RS, RS, (1 * SIZE)
  jr x5