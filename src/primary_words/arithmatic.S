
#include "../common.S"

.global add_arithmatic

add_arithmatic:
  sys_push4

  call add_gmer_plus
  call add_gmer_minus
  call add_gmer_times
  call add_gmer_div_mod
  call add_gmer_abs_sign

  sys_pop4
  ret

/*
################################################################################
#
# Arithmatic
#
################################################################################
*/

make_codeword plus, "+"
  ds_pop2
  add a0, a0, a1
  ds_push1
  j next

make_codeword minus, "-"
  ds_pop2
  sub a0, a0, a1
  ds_push1
  j next

make_codeword times, "*"
  ds_pop2
  mul a0, a1, a0
  ds_push1
  j next

/*

  combination of division and modulus
  division by zero = 0
  remainder is

*/
make_codeword div_mod, "/%"
  ds_pop2
  beqz a1, 1f
  # save d
  mv t1, a1
  # a2 = a0 / a1
  div a2, a0, a1
  # a3 = a0 % a1
  rem a3, a0, a1

  # a4 signum rem
  mv a0, a3
  jal t0, signum
  mv a4, a0

  # a5 - signum d
  mv a0, t1
  jal t0, signum
  neg a5, a0

  xor a4, a4, a5
  seqz a4, a4

  sub a0, a2, a4
  mul a1, a4, t1
  add a1, a1, a3

  ds_push2
  j next
1:
  li a0, 0
  li a1, 0
  ds_push2
  j next

/*
  sign of a0, -1, 0 or 1
  touches a1
*/
signum:
  sgtz a1, a0
  sltz a0, a0
  neg a0, a0
  add a0, a0, a1
  jr t0

/*

  abs-sign
  (n -- f n)

*/
make_codeword abs_sign, "abs-sign"
  ds_pop1
  mv t1, a0
  jal t0, signum
  mul a1, t1, a0
  ds_push2
  j next