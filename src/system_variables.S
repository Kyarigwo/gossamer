/*
################################################################################
#
# System Variables
#
################################################################################
*/
#include "common.S"

.global ptr_latest, ptr_new_word, ptr_here, immediate_mode, data_stack_top
.global return_stack_top, local_stack_top, data_area_base, input_buffer
.global input_buffer_size, parse_point, parse_point_size
.global number_format_buffer

.bss

/*

# stack locations

*/
data_stack_top:
  .4byte 0

return_stack_top:
  .4byte 0

local_stack_top:
  .4byte 0

/*

# input variables

*/

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

  .space NUMBER_FORMAT_BUFFER_SIZE
number_format_buffer:
  .space 1

/*

# Data area variables

*/

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