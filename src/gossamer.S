
#include "common.S"

.global _start


.global next, enter, codeword_exit, execute, code_exit
.global number_to_word

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


number_to_word:
  sys_push8

  # setup
  mv s2, a0
  la s5, number_format_buffer
  li s4, DEFAULT_BASE
  li s6, 0
  # set sign bit, and take abs
  bge s2, x0, 1f
  neg s2, s2
  li s6, 1
  # do
1:
  rem  a0, s2, s4      #   a0 = s2 % s4
  div  s2, s2, s4      #   s2 = s2 / s4
  call digit_to_ascii  #   r = chr r

  call push_char_format_buffer
#  sb   a0, (s5)        #   *output = r
#  addi s5, s5,-1       #   output--

  bnez s2, 1b          # while n != 0
  # until s2 == 0

  beq s6, x0, 2f       # if sign bit set
  li a0, 45            # load '- 'value
  call push_char_format_buffer
#  sb a0, (s5)
#  addi s5, s5, -1
2:
  la t0, number_format_buffer
  sub  a1, t0, s5      # a1 = original_output - output
  addi s5, s5, 1       # output++i
  mv   a0, s5          # a0 = output

  sys_pop8
  ret

push_char_format_buffer:
  sb a0, (s5)
  addi s5, s5, -1
  ret

/*
  given a digit, converts it to an ascii rep -- up to hex
*/
digit_to_ascii:
  addi a0, a0, 48
  li a1, 57
  ble a0, a1, 1f
  addi a0, a0, 7
1:
  ret

