/*
################################################################################
#
# System Variables
#
################################################################################
*/
#include "../common.S"

.global add_system_variables

.global ptr_latest, ptr_new_word, ptr_here, immediate_mode, data_stack_top
.global return_stack_top, local_stack_top, data_area_base
.global scratch_input_buffer
.global input_bottom, input_top, parse_point
.global number_format_buffer, number_format_start
.global interpret_xt


add_system_variables:
  sys_push4
# System variables
  call add_gmer_ptr_here
  call add_gmer_here
  call add_gmer_input_buffer
  call add_gmer_parse_point
  call add_gmer_input_buffer_top
  call add_gmer_latest_word
  call add_gmer_new_word
  call add_gmer_immediate_mode
  call add_gmer_cell
  call add_gmer_nfb
  call add_gmer_nfb_c
  call add_gmer_ds_top
  call add_gmer_ds_base
  call add_gmer_interpret_xt
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

make_codeword input_buffer, "input{"
  lw a0, input_bottom
  ds_push1
  j next

make_codeword parse_point, "{input&}"
  la a0, parse_point
  ds_push1
  j next

make_codeword input_buffer_top, "}input"
  lw a0, input_top
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

make_codeword ds_top, "}ds"
  lw a0, data_stack_top
  ds_push1
  j next

make_codeword ds_base, "ds{"
  mv a0, DS
  ds_push1
  j next

make_codeword interpret_xt, "&interpret_xt"
  la a0, interpret_xt
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

scratch_input_buffer:
.space INPUT_BUFFER_MAX

input_bottom:
  .4byte 0

input_top:
  .4byte 0

parse_point:
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

interpret_xt:
  .4byte 0

/*

# system state

*/

.data

immediate_mode:
  .4byte 1