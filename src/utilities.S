#include "common.S"

.global gmer_memcpy, align_4byte

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


