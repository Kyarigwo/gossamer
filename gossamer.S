

.global _start

# Jump register is t0 = x5
# Indirect pointer is ra = x1
# Data stack pointer is sp = x2
# Return stack pointer is fp = s0 = x8
# Instruction pointer s1 = x9

#define SIZE 4
#define INPUT_BUFFER_MAX 80

// Sys call data
#define SYS_MMAP 222
#define SYS_EXIT 93
#define SYS_WRITE 64
#define SYS_READ 63

// Data for mmap
#define PAGESIZE 4096  // page size
#define PROT_READ 0x1
#define PROT_WRITE 0x2
#define MAP_ANONYMOUS 0x20
#define MAP_PRIVATE 0x02

#include "macros.S"

.text
_start:
# magic to get loading of data to work
  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop
  la a0, ex_word1
  la a1, ex_word1_length
  la a2, ex_word1
  la a3, ex_word1_length
  call string_eq
  call print_bool
  call bye


/*

# bye -- exits with given exit code

arguments:
  a0: exit code

returns:
  nothing, suprisingly

*/
bye:
  li a7, SYS_EXIT
  ecall

/*

# alloc-mem -- allocates PAGESIZE pages of memory

arguments:
  a0: number of pages to allocate

returns:
  a0: address of allocated area, or 0 for failure

*/
alloc_mem:
  mv t0, a0
  li t1, PAGESIZE
  mul t0, t0, t1
  li a0, 0
  mv a1, t0
  li a2, PROT_READ | PROT_WRITE
  li a3, MAP_ANONYMOUS | MAP_PRIVATE
  li a4, -1
  li a5, 0
  li a7, SYS_MMAP
  ecall
  ret

/*

#  print -- writes bytes to standard out

arguments:
  a0: base of string to write
  a1: size of string to write

returns:
  nothing

*/
print:
  mv a2, a1
  mv a1, a0
  li a0, 1          # stdout
  li a7, SYS_WRITE
  ecall
  ret

/*

# refill-input - fills the input buffer from current input source

arguments:
  none

returns:
  a0: current base of input buffer | 0 failure
  a1: current size of input buffer | unused failure

*/
refill_input:
  li a0, 0                  # stdin
  la a1, input_buffer
  li a2, INPUT_BUFFER_MAX
  li a7, SYS_READ
  ecall
  bltz a0, 1f
  mv a1, a0
  la a0, input_buffer
  ret
1:
  li a0, 0
  ret

.bss
input_buffer: .space INPUT_BUFFER_MAX
.text

/*

# split_eq_str - splits a string where c != target

arguments:
  a0: start of string
  a1: size of string
  a2: target

returns:
  a0: base of lower string
  a1: the size lower string
  a2: base of upper string
  a3: size of upper string

locals:
  a4: copy of target
  a5: top of input string
  a6: char at point

*/
split_eq_str:
  mv a4, a2
  mv a2, a0
  add a5, a0, a1
1:
  bge a2, a5, 2f
  lb a6, 0(a2)
  bne a4, a6, 2f
  addi a2, a2, 1
  j 1b
2:
  sub a1, a2, a0
  sub a3, a5, a2
  ret

/*

# split_ne_str - splits a string where c == target

arguments:
  a0: start of string
  a1: size of string
  a2: target

returns:
  a0: base of lower string
  a1: the size of lower string
  a2: base of upper string
  a3: size of upper string

locals:
  a4: copy of target
  a5: top of input string
  a6: char at point

*/
split_ne_str:
  mv a4, a2
  mv a2, a0
  add a5, a0, a1
1:
  bge a2, a5, 2f
  lb a6, 0(a2)
  beq a4, a6, 2f
  addi a2, a2, 1
  j 1b
2:
  sub a1, a2, a0
  sub a3, a5, a2
  ret

/*

# parse_word - first white space seperated word

arguments:
  a0: start of string
  a1: size of string

returns:
  a0: start of word
  a1: size of word
  a2: start of remainder
  a3: size of remainder

*/
parse_word:
  push1 ra
  li a2, 32
  call split_eq_str
  mv a0, a2
  mv a1, a3
  li a2, 32
  call split_ne_str
  pop1 ra
  ret

/*

# string= - true if argument string equal, false if not

arguments:
  a0: start of first string
  a1: size of first string
  a2: start of second string
  a3: size of second string

returns:
  a0: true is strings equal, false is not

*/
string_eq:
  bne a1, a3, 2f
1:
  beqz a1, 1f
  lb a4, 0(a0)
  lb a5, 0(a2)
  bne a4, a5, 2f
  addi a1, a1, -1
  addi a0, a0, 1
  addi a2, a2, 1
  j 1b
1:
  li a0, 1
  ret
2:
  li a0, 0
  ret

/*

# parse_words - reads line, splits into words, and prints them out

arguments:
  none

returns:
  none

*/
parse_words:
  push3 ra, s2, s3
  call refill_input
1:
  call parse_word
  mv s2, a2
  mv s3, a3
  beqz a1, 2f
  call print
  mv a0, s2
  mv a1, s3
  j 1b
2:
  pop3 s3, s2, ra
  ret

/*

# print_version -- prints version

arguments:
  none

returns:
  none

*/
print_version:
  la a0, version_msg
  la a1, version_msg_length
  tail print


.data
version_msg:
  .ascii "Version 2.21\n"
.equ version_msg_length, .-version_msg

ex_word1:
  .ascii "xest_word2"
.equ ex_word1_length, .-ex_word1

ex_word2:
  .ascii "test_word2"
.equ ex_word2_length, .-ex_word2

.text

/*

# print_bool - prints true or false based on a0

arguments:
  a0: if 0 prints false, else true

returns:
  nothing

*/
print_bool:
  push1 ra
  beqz a0, 1f
  call print_true
  j 2f
1:
  call print_false
2:
  pop1 ra
  ret

/*

# print_true - prints 'true'

*/
print_true:
  la a0, true_msg
  la a1, true_msg_length
  tail print

/*

# print_false - prints false

*/
print_false:
  la a0, false_msg
  la a1, false_msg_length
  tail print

.data
true_msg:
  .ascii "true\n"
.equ true_msg_length, .-true_msg

false_msg:
  .ascii "false\n"
.equ false_msg_length, .-false_msg