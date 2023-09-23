/*

Use a seperate data stack from the main system stack,
as well as return stack.  Hence also keep these values
in the high saved registers.

s11 : instruction pointer
s10 : data stack
s9 : return stack
s8 : local stack

use lowest two temp locations for jump pointers
t0 : first jump location
t1 : second jump location

*/


.global _start

#define IP s11
#define DS s10
#define RS s9
#define LS s8

// system sizes
#define SIZE 4
#define DATA_STACK_SIZE 1
#define RETURN_STACK_SIZE 1
#define LOCAL_STACK_SIZE 1
#define INPUT_BUFFER_MAX 80

#define DEFAULT_BASE 10
#define NUMBER_FORMAT_BUFFER_SIZE 80

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

/*
################################################################################
#
# Start up code
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
  call alloc_mem
  li t0, PAGESIZE * DATA_STACK_SIZE
  add DS, a0, t0
  sw DS, data_stack_top, t0

# setup return stack
  li a0, RETURN_STACK_SIZE
  call alloc_mem
  li t0, PAGESIZE * RETURN_STACK_SIZE
  add RS, a0, t0
  sw RS, return_stack_top, t0

# setup local stack
  li a0, LOCAL_STACK_SIZE
  call alloc_mem
  li t0, PAGESIZE * LOCAL_STACK_SIZE
  add LS, a0, t0
  sw LS, local_stack_top, t0

# run program
  la IP, program
1:
  call parse_words
  j 1b
  call bye

.data

program:
  .word codeword_bye
.text

/*
################################################################################
#
# VM start
#
################################################################################
*/

enter:
  pushr1 IP
  addi IP, t0, SIZE
next:
  lw t0, 0(IP)
  lw t1, 0(t0)
  addi IP, IP, SIZE
  jr t1

code_exit:
  popr1 IP
  j next

.data
.p2align 2

execute_word:
  .4byte 0
  .4byte codeword_cont

codeword_cont:
  .4byte cont

.text

execute:
  sys_push1 ra
  sw a0, execute_word, t0
  pushr1 IP
  la IP, execute_word
  j next

cont:
  popr1 IP
  sys_pop1 ra
  ret

/*
################################################################################
#
# VM end
#
################################################################################
*/

/*
################################################################################
#
# System Variables
#
################################################################################
*/
.data

data_stack_top:
  .4byte 0

return_stack_top:
  .4byte 0

local_stack_top:
  .4byte 0

.text

/*
################################################################################
#
# Compiled functions
#
################################################################################
*/


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

# print newline

*/
print_newline:
  la a0, newline_msg
  la a1, newline_msg_length
  tail print

.section .rodata

newline_msg:
  .ascii "\n"
.equ newline_msg_length, .-newline_msg

.text
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

# split_on_ws_start - splits a string where white space begins

arguments:
  a0: start of string
  a1: size of string

returns:
  a0: base of lower string
  a1: the size lower string
  a2: base of upper string
  a3: size of upper string

locals:
  a4: constant 32
  a5: top of input string
  a6: char at point

*/
split_on_ws_start:
  mv a2, a0         # start split at input string
  li a4, 32         # load constant
  add a5, a0, a1    # a5 = top of input string
1:
  bge a2, a5, 2f    # if split not < a5, exit
  lb a6, 0(a2)      # get byte at a2
  ble a6, a4, 2f    # if a6 <= 32 done
  addi a2, a2, 1    # next a2
  j 1b
2:
  sub a1, a2, a0
  sub a3, a5, a2
  ret

/*

# split_on_ws_end - splits a string where white space ends

arguments:
  a0: start of string
  a1: size of string

returns:
  a0: base of lower string
  a1: the size of lower string
  a2: base of upper string
  a3: size of upper string

locals:
  a4: const value 32
  a5: top of input string
  a6: char at point

*/
split_on_ws_end:
  mv a2, a0
  li a4, 32
  add a5, a0, a1
1:
  bge a2, a5, 2f
  lb a6, 0(a2)
  bgt a6, a4, 2f
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
  sys_push1 ra
  call split_on_ws_end
  mv a0, a2
  mv a1, a3
  call split_on_ws_start
  sys_pop1 ra
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
  sys_push4 ra, s0, s1, s2
  sys_push1 s3
  call refill_input
1:
  call parse_word
  beqz a1, 2f         # If no word not found, exit
  mv s0, a0           # Save word found
  mv s1, a1
  mv s2, a2           # Save remainder of line
  mv s3, a3
  call find_word      # lookup word
  beqz a0, 3f
  call name_to_codeword # get codeword
  call execute         # and run it!
  j 4f
3:                     # else
  mv a0, s0
  mv a1, s1
  call word_to_number # see if it is a number
  bltz a0, 4f # if t0 < t1 then target
  push1 a0
4:
  mv a0, s2           # restore remainder
  mv a1, s3
  j 1b                # parse next word
2:
  sys_pop1 s3
  sys_pop4 ra, s0, s1, s2
  ret

/*

# find_word - search wordlist for given word

arguments:
  a0: start of target word
  a1: size of target word

returns:
  Success:
    a0: start of found word
    a1: size of found word
  Failure:
    a0: false (0)
    a1: unused

*/
find_word:
  sys_push4 ra, s2, s3, s4
  mv s2, a0
  mv s3, a1
  la s4, start_wordlist
1:
  lw a0, 0(s4)
  beqz a0, 2f
  lw a1, (SIZE)(s4)
  mv a2, s2
  mv a3, s3
  call string_eq
  bnez a0, 3f
  addi s4, s4, 2 * SIZE
  j 1b
3:
  lw a0, 0(s4)
  lw a1, (SIZE)(s4)
  sys_pop4 ra, s2, s3, s4
  ret
2:
  li a0, 0
  sys_pop4 ra, s2, s3, s4
  ret

/*

# name_to_codeword - replaces a found name with its codeword

arguments:
  a0: start of found word
  a1: size of found word

returns:
  a0: address of code word

*/
name_to_codeword:
  # need to round to align?
  mv t0, a1
  srli a1, a1, 2
  slli a1, a1, 2
  beq t0, a1, 1f
  addi a1, a1, 4
1:
  add a0, a0, a1
  ret

/*

# word_to_number - converts word to + number.  -1 if fail

for the moment, only consider unsigned ints.  So -1 if anything else,
including extra characters.

arguments:
  a0: start of string to convert
  a1: size of found word

returns:
  a0: number converted, or -1 if it fails

variables:
  a0 : pointer to current character
  a3 : working value
  a4 : top of string
  a5 : current character/digit
  a6 : tempory value to compare
*/
word_to_number:
  li a3, 0        # Intial value
  li a6, 10
  add a4, a0, a1  # top of string
1:
  bgeu a0, a4, 2f # while a0 < a4
  lb a5, 0(a0)
  addi a5, a5, -48  # convert char to decimal digit
  bltz a5, 3f       # fail if < 0
  bge a5, a6, 3f     # fail if >= 10
  mul a3, a3, a6
  add a3, a3, a5    # a3 = 10 * a3 + a5
  addi a0, a0, 1
  j 1b
2:
  mv a0, a3
  ret
3:
  li a0, -1
  ret

/*

# number_to_word - converts a number in a0 to a word

arguments:
  a0: input number

returns:
  a0: base of representation string
  a1: size of representation string

locals:
  a0 : scratch register
  s2 : working number as it decreases
  s5 : location where we will push the next char
  s4 : stores our base
  s6 : flag if original number is -

  # setup
  s2 = a0
  s5 = number_format_buffer_top
  s4 = DEFAULT_BASE
  s6 = 0

  # set flag if number negative, and take abs
  if ! s2 >= 0  # handle negative numbers by, if number is negative
    s2 = -s2    # change sign
    s6 = 1      # and set bit to indicate this


do
  a0 = s2 `mod` s4    # pull out lowest digit
  s2 = s2 / s4        # and shift remainder down
  a0 = digit_to_ascii a0  # change remainder to a letter digit
  *s5 = a0                # store that byte in the output buffer
  s5 --                   # move the output buffer down
until s2 != 0

  if s6 == true:      # add sign bit
    *s5 = '-'
    s5 --             # push digit to the output buffer
  t0 = number_format_buffer_top
  a1 = t0 - s5        # length = original-top - current bottom
  s5++                # move bottom of buffer up by one
  a0 = s5


*/
number_to_word:
  sys_push4 ra, s2, s3, s4
  sys_push2 s5, s6

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
  addi s5, s5, 1       # output++
  mv   a0, s5          # a0 = output

  sys_pop2 s5, s6      # restore registers
  sys_pop4 ra, s2, s3, s4
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

.bss
  .space NUMBER_FORMAT_BUFFER_SIZE
number_format_buffer:
  .space 1

.text

/*

# print_wordlist - prints out all words in wordlist

arguments:
  none

returns:
  nothing

*/
print_wordlist:
  sys_push2 ra, s2
  la s2, start_wordlist
1:
  lw a0, 0(s2)
  beqz a0, 2f
  lw a1, (SIZE)(s2)
  call print
  call print_newline
  addi s2, s2, 2 * SIZE
  j 1b
2:
  sys_pop2 ra, s2
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


.section .rodata
version_msg:
  .ascii "Version 2.21\n"
.equ version_msg_length, .-version_msg


.text

/*

# print_bool - prints true or false based on a0

arguments:
  a0: if 0 prints false, else true

returns:
  nothing

*/
print_bool:
  sys_push1 ra
  beqz a0, 1f
  call print_true
  j 2f
1:
  call print_false
2:
  sys_pop1 ra
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

.section .rodata

true_msg:
  .ascii "true\n"
.equ true_msg_length, .-true_msg

false_msg:
  .ascii "false\n"
.equ false_msg_length, .-false_msg

/*
################################################################################
#
# compiled wordlist
#
################################################################################
*/

.data 1

start_wordlist:

defcodeword bye, "bye"
  li a0, 0
  call bye
  j next

defcodeword print_version, "version"
  call print_version
  j next

defcodeword print_hello_world, "print_hello_world"
  la a0, hello_world_msg
  la a1, hello_world_msg_length
  call print
  j next

defcodeword print_goodbye_world, "print_goodbye_world"
  la a0, goodbye_world_msg
  la a1, goodbye_world_msg_length
  call print
  j next

defcodeword dot, "."
  pop1 a0
  call number_to_word
  call print
  j next

defword two_words, "two_words"
  .4byte codeword_print_goodbye_world
  .4byte codeword_print_hello_world
  .4byte codeword_exit

defheader exit, "exit"
  .4byte code_exit


.data 1
end_wordlist:
  .4byte 0

.section .rodata

hello_world_msg:
  .ascii "Hello world!\n"
.equ hello_world_msg_length, .-hello_world_msg

string_literal goodbye_world, "Goodbye World!\n"

.text
