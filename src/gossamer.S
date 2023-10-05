
#include "common.S"
#include "macros.S"

.global _start

.global next, enter, codeword_exit
.global number_to_word, word_parse
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

/*
################################################################################
#
# VM module
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

codeword_exit:
  .4byte code_exit

.text

execute:
  jal x5, sys_push4
  sw a0, execute_word, t0
  pushr1 IP
  la IP, execute_word
  j next

cont:
  popr1 IP
  jal x5, sys_pop4
  ret


/*
################################################################################
#
# Startup Module
#
################################################################################
*/

/*

# alloc-mem -- allocates PAGESIZE pages of memory

arguments:
  a0: number of pages to allocate

returns:
  a0: address of allocated area, or 0 for failure

*/
allot_memory:
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
################################################################################
#
# interpret module
#
################################################################################
*/

/*

# refill-input - fills the input buffer from current input source

arguments:
  none

returns:
  a0: current base of input buffer | 0 failure
  a1: current size of input buffer | unused failure

*/

.text
refill_input:
  li a0, 0                      # stdin
  la a1, input_buffer
  li a2, INPUT_BUFFER_MAX
  li a7, SYS_READ
  ecall
  bltz a0, 1f                   # if successful
  sw a0, input_buffer_size, t0  # set amount of data read
  la t0, input_buffer           # load base of input
  sw t0, parse_point, t1        # reset parse point
  sw a0, parse_point_size, t0   # reset parse size

  mv a1, a0
  la a0, input_buffer
  ret
1:
  li a0, 0
  ret

/*

whitespace_parse -- moves ^parse to first point past
                              whitespace, or end of buffer

input:
  none

returns:
  a0: original value of ^parse
  a1: distance between new ^parse and old ^parse

*/
whitespace_parse:
  lw a0, parse_point
  lw a1, parse_point_size
  li a2, 32           # space to compare to
  mv a4, a0           # record original location of ^parse
  add a3, a0, a1      # a3 = a0 + a1 pointer to end of parse area
1:
  bge a0, a3, 2f      # while parse-point < parse-top
  lb a5, 0(a0)        #   load byte at parse point
  bgt a5, a2, 2f      #   if byte is > 32, exit
  addi a0, a0, 1      #   advance parse point by one
  j 1b                # wend
2:
  sub a1, a3, a0      # parse_point_size = parse-top - parse point
  sw a0, parse_point, t0
  sw a1, parse_point_size, t0
  sub a1, a0, a4
  mv a0, a4
  ret

/*

non_whitespace_parse -- moves ^parse to first whitespace point past
                          non-whitespace, or end of of buffer

input:
  none

returns:
  a0: original value of ^parse
  a1: distance between new ^parse and old ^parse

*/
non_whitespace_parse:
  lw a0, parse_point
  lw a1, parse_point_size
  li a2, 32           # space to compare to
  mv a4, a0           # record original location of ^parse
  add a3, a0, a1      # a3 = a0 + a1 pointer to end of parse area
1:
  bge a0, a3, 2f      # while parse-point < parse-top
  lb a5, 0(a0)        #   load byte at parse point
  ble a5, a2, 2f      #   if byte is <= 32, exit
  addi a0, a0, 1      #   advance parse point by one
  j 1b                # wend
2:
  sub a1, a3, a0      # parse_point_size = parse-top - parse point
  sw a0, parse_point, t0
  sw a1, parse_point_size, t0
  sub a1, a0, a4
  mv a0, a4
  ret

/*

word_parse -- moves ^parse to past next whitespace seperated word
                or at end of buffer

input:
  none

returns:
  a0: ^parse at start of word
  a1: length of word, or 0 if not found

*/
word_parse:
  jal x5, sys_push4         #save ra etc

  call whitespace_parse
  call non_whitespace_parse

  jal x5, sys_pop4
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

# interpret - reads line, splits into words, and prints them out

arguments:
  none

returns:
  none

*/
interpret:
  jal x5, sys_push4

1:
  call word_parse
  beqz a1, 2f           # If no word found, end of  line

  mv s0, a0             # Save word found
  mv s1, a1

  call handle_word      # try to handle like a word
  bnez a0, 1b

  mv a0, s0
  mv a1, s1
  call handle_number    # try to handle like  a number
  bnez a0, 1b           # if a0 != 0 next word

  call print_question_mark # bad end
  call print_newline
  jal x5, sys_pop4
  ret

2:                    # good end
  lw t0, immediate_mode
  beqz t0, 3f
  call print_ok
  call print_newline
  jal x5, sys_pop4
  ret

3:
  call print_compiled
  call print_newline
  jal x5, sys_pop4
  ret

/*

# Handle word - handles a word that is in the dictionary

arguments:
  a0: base of input string
  a1: length of input string

returns:
  a0: 1 if handled, otherwise 0

*/
handle_word:
  jal x5, sys_push4
  call find_word
  beqz a1, 3f           # word not in dicationary

  addi a1, a1, 1        # if word is not immediate  a1 = -1, so now 0
                        // if word is immediate, a1 = 2

  lw t0, immediate_mode # are we in immediate mode?
  or t0, t0, a1         # if either

  beqz t0, 1f           # we run the instructions
  call execute
  j 2f
1:                      # else
  lw t0, ptr_here       # store xt at here
  sw a0, 0(t0)
  addi t0, t0, SIZE
  sw t0, ptr_here, t1
2:
  li a0, 1
  jal x5, sys_pop4
  ret
3:
  li a0, 0
  jal x5, sys_pop4
  ret

/*

# handle_number -- handles a potential number

arguments:
  a0: base of input string
  a1: length of input string

returns:
  a0: 1 if handled, otherwise 0

*/
handle_number:
  jal x5, sys_push4
  call word_to_number
  bltz a0, 3f
  lw t0, immediate_mode
  beqz t0, 1f
  push1
  j 2f
1:
  lw t0, ptr_here
  la t1, lit_codeword
  sw t1, 0(t0)
  sw a0, SIZE(t0)
  addi t0, t0, 2*SIZE
  sw t0, ptr_here, t1
2:
  li a0, 1
  jal x5, sys_pop4
  ret

3:
  li a0, 0
  jal x5, sys_pop4
  ret

/*

# find_word - search wordlist for given word

arguments:
  a0: start of target word
  a1: size of target word

returns:
  a0: xt if word found, 0 otherwise
  a1: 0 if not found, -1 if not immediate, 1 if immdediate

*/
find_word:
  jal x5, sys_push4

  mv s0, a0           # save target
  mv s1, a1

  la s2, ptr_latest   # load word pointer

1:
  lw s2, 0(s2)        # next word pointer
  beqz s2, 2f         # while != 0

  mv a0, s2
  call wt_to_name     # get name of word

  mv a2, s0
  mv a3, s1
  call string_eq      # compare it to target

  beqz a0, 1b         # if != wend

  mv a0, s2           # check for immediate  word
  call wt_immediate
  mv t0, a0

  mv a0, s2
  call wt_to_xt
  li a1, -1
  beqz t0, 3f
  li a1, 1
3:
  jal x5, sys_pop4
  ret

2:
  li a1, 0
  li a0, 0            # return 0
  jal x5, sys_pop4
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
  jal x5,  sys_push8

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

  jal x5, sys_pop8
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

