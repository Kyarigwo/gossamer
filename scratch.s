
  la a0, hello_world
  li a1, 5
  la a2, target
  call gmer_memcpy
  li a0, 10
  ecall


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
  ret


.data

hello_world:
  .asciiz "hello world!"
end_hello_world:
  .word 1
target:
  .space 100