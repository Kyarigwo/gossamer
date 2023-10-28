
#include "common.S"

.global _start


.global next, enter, codeword_exit, execute, code_exit

/*
################################################################################
#
# Start code
#
################################################################################
*/

.text
_start:
# magic to get loading of data to work
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop

# setup data stack
  li a0, DATA_STACK_SIZE
  call allot_memory
  li t0, PAGESIZE * DATA_STACK_SIZE
  add DS, a0, t0
  sw DS, data_stack_top, t0

# setup return stack
  li a0, RETURN_STACK_SIZE
  call allot_memory
  li t0, PAGESIZE * RETURN_STACK_SIZE
  add RS, a0, t0
  sw RS, return_stack_top, t0

# setup local stack
  li a0, LOCAL_STACK_SIZE
  call allot_memory
  li t0, PAGESIZE * LOCAL_STACK_SIZE
  add LS, a0, t0
  sw LS, local_stack_top, t0

# create data area
  li a0, DATA_AREA_SIZE
  call allot_memory

  sw a0, data_area_base, t0
  sw a0, ptr_here, t0
  sw a0,  ptr_new_word, t0
  sw zero, ptr_latest, t0
  la t0, number_format_buffer
  sw t0, number_format_start, t0

  call cold_start

  la a0, secondary_words
  la a1, secondary_words_length
  sw a0, parse_point, t0
  sw a1, parse_point_size, t0

  call interpret

1:
  call refill_input
  call interpret
  j 1b

  li a7, SYS_EXIT
  ecall


