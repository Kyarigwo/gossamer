#include "common.S"

.global sys_push4, sys_pop4
.global sys_push8, sys_pop8
.global gmer_memcpy, align_4byte

sys_push4:
  addi sp, sp, -4*SIZE
  sw ra, 0(sp)
  sw s0, SIZE(sp)
  sw s1, 2*SIZE(sp)
  sw s2, 3*SIZE(sp)
  jr x5   # jump to x5

sys_pop4:
  lw ra, 0(sp)
  lw s0, SIZE(sp)
  lw s1, 2*SIZE(sp)
  lw s2, 3*SIZE(sp)
  addi sp, sp, 4*SIZE
  jr x5  # jump to x5

sys_push8:
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

sys_pop8:

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

# Copy a1 bytes from a0 to a2

arguments:
  a0: start of area to copy
  a1: amount to copy
  a2: address to copy to

returns:
  a0: location 1 byte pass end of copied data

*/
gmer_memcpy:
2:
  beqz a1, 1f
  lb a3, 0(a0)
  sb a3, 0(a2)
  addi a0, a0, 1
  addi a2, a2, 1
  addi a1, a1, -1
  j 2b
1:
  mv a0, a2
  ret

/*

# Align a0 to next 4byte alignment

argument:
  a0: pointer to align

returns:
  a0: aligned pointer

*/
align_4byte:
  srli a1, a0, 2
  slli a1, a1, 2
  beq a0, a1, 1f
  addi a0, a1, SIZE
1:
  ret


