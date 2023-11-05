
/*
################################################################################
#
# stack manipulation
#
################################################################################
*/

#include "../common.S"

.global add_stack

add_stack:
  sys_push4

# Stack manipulation
  call add_gmer_drop
  call add_gmer_swap
  call add_gmer_nip
  call add_gmer_dup
  call add_gmer_maybe_dup
  call add_gmer_over
  call add_gmer_tuck
  call add_gmer_rot
  call add_gmer_minus_rot


# stack manipulation 2
  call add_gmer_two_drop
  call add_gmer_two_swap
  call add_gmer_two_nip
  call add_gmer_two_dup
  call add_gmer_two_over
  call add_gmer_two_tuck
  call add_gmer_two_rot
  call add_gmer_two_minus_rot

# stack manipulation rs
  call add_gmer_ds_to_rs
  call add_gmer_rs_to_ds

  sys_pop4
  ret


make_codeword drop, "drop"
  ds_pop1
  j next

make_codeword swap, "swap"
  ds_pop2
  mv t0, a0
  mv a0, a1
  mv a1, t0
  ds_push2
  j next

make_codeword nip, "nip"
  ds_pop2
  mv a0, a1
  ds_push1
  j next

make_codeword dup, "dup"
  ds_pop1
  mv a1, a0
  ds_push2
  j next

make_codeword maybe_dup, "?dup"
  ds_pop1
  beqz a0, 1f
  mv a1, a0
  ds_push2
  j next
1:
  ds_push1
  j next

make_codeword over, "over"
  ds_pop2
  mv a2, a0
  ds_push3
  j next

make_codeword tuck, "tuck"
  ds_pop2
  mv a2, a1
  mv a1, a0
  mv a0, a2
  ds_push3
  j next

make_codeword rot, "rot"
  ds_pop3
  mv t0, a0
  mv a0, a1
  mv a1, a2
  mv a2, t0
  ds_push3
  j next

make_codeword minus_rot, "-rot"
  ds_pop3
  mv t0, a2
  mv a2, a1
  mv a1, a0
  mv a0, t0
  ds_push3
  j next



/*
################################################################################
#
# Double stack manipulation
#
################################################################################
*/

make_codeword two_drop, "drop:2"
  ds_pop2
  j next

make_codeword two_swap, "swap:2"
  ds_pop4
  mv t0, a0
  mv t1, a1
  mv a0, a2
  mv a1, a3
  mv a2, t0
  mv a3, t1
  ds_push4
  j next

make_codeword two_nip, "nip:2"
  ds_pop4
  mv a0, a2
  mv a1, a3
  ds_push2
  j next

make_codeword two_dup, "dup:2"
  ds_pop2
  mv a2, a0
  mv a3, a1
  ds_push4
  j next

make_codeword two_over, "over:2"
  ds_pop4
  mv a4, a0
  mv a5, a1
  ds_push6
  j next

make_codeword two_tuck, "tuck:2"
  ds_pop4
  mv a4, a2
  mv a5, a3
  mv a2, a0
  mv a3, a1
  mv a0, a4
  mv a1, a5
  ds_push6
  j next

make_codeword two_rot, "rot:2"
  ds_pop6
  mv t0, a0
  mv t1, a1
  mv a0, a2
  mv a1, a3
  mv a2, a4
  mv a3, a5
  mv a4, t0
  mv a5, t1
  ds_push6
  j next

make_codeword two_minus_rot, "-rot:2"
  ds_pop6
  mv t0, a4
  mv t1, a5

  mv a4, a2
  mv a5, a3

  mv a2, a0
  mv a3, a1

  mv a0, t0
  mv a1, t1

  ds_push6
  j next

/*
################################################################################
#
# return stack manipulation
#
################################################################################
*/

make_codeword ds_to_rs, "ds>rs"
  ds_pop1
  rs_push1
  j next

make_codeword rs_to_ds, "rs>ds"
  rs_pop1
  ds_push1
  j next