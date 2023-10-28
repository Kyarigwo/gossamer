
  li a0, 5
  li a1, 5
  beqz a1, dzero
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
  snez a4, a4

  sub a1, a2, a4
  mul a2, a4, t1
  add a2, a2, a3

  li a0, 10
  ecall
dzero:
  li a1, 0
  li a2, 0
  li a0, 10
  ecall

signum:
  sgtz a1, a0
  sltz a0, a0
  neg a0, a0
  add a0, a0, a1
  jr t0