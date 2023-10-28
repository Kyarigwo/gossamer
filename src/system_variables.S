/*
################################################################################
#
# System Variables
#
################################################################################
*/
#include "common.S"

.global add_system_variables

.global ptr_latest, ptr_new_word, ptr_here, immediate_mode, data_stack_top
.global return_stack_top, local_stack_top, data_area_base, input_buffer
.global input_buffer_size, parse_point, parse_point_size
.global number_format_buffer, number_format_start


add_system_variables:
  sys_push4
# System variables
  call add_gmer_ptr_here
  call add_gmer_here
  call add_gmer_input_buffer
  call add_gmer_parse_point
  call add_gmer_parse_point_size
  call add_gmer_latest_word
  call add_gmer_new_word
  call add_gmer_immediate_mode
  call add_gmer_cell
  call add_gmer_nfb
  call add_gmer_nfb_c
  sys_pop4
  ret

/*
################################################################################
#
# System variables
#
################################################################################
*/
make_codeword ptr_here, "}data&"
  la a0, ptr_here
  ds_push1
  j next

make_codeword here, "}data"
  lw a0, ptr_here
  ds_push1
  j next

make_codeword input_buffer, "input{#"
  la a0, input_buffer
  lw a1, input_buffer_size
  ds_push2
  j next

make_codeword parse_point, "{input}"
  lw a0, parse_point
  ds_push1
  j next

make_codeword parse_point_size, "{input#}"
  lw a0, parse_point_size
  ds_push1
  j next

make_codeword latest_word, "@word"
  lw a0, ptr_latest
  ds_push1
  j next

make_codeword new_word, "@new"
  lw a0, ptr_new_word
  ds_push1
  j next

make_codeword immediate_mode, "immediate-mode"
  la a0, immediate_mode
  ds_push1
  j next

make_codeword cell, "cell"
  li a0, 4
  ds_push1
  j next

make_codeword nfb, "}format"
  la a0, number_format_buffer
  ds_push1
  j next


make_codeword nfb_c, "format&{"
  la a0, number_format_start
  ds_push1
  j next

.bss

/*

# stack locations

*/
.p2align 2

data_stack_top:
  .4byte 0

return_stack_top:
  .4byte 0

local_stack_top:
  .4byte 0

/*

# input variables

*/

input_buffer_ptr:
  .4byte

input_buffer:
.space INPUT_BUFFER_MAX

input_buffer_size:
  .4byte 0

parse_point:
  .4byte 0

parse_point_size:
  .4byte 0

/*

# Number formatting areas

*/
.bss
  .space NUMBER_FORMAT_BUFFER_SIZE
number_format_buffer:
  .space 1

.data
number_format_start:
  .4byte 0

/*

# Data area variables

*/
.bss

data_area_base:
  .4byte 0

ptr_here:
  .4byte 0

ptr_latest:
  .4byte 0

ptr_new_word:
  .4byte 0

/*

# system state

*/

.data

immediate_mode:
  .4byte 1