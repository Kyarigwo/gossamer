
#include "common.S"


.global refill_input, whitespace_parse, non_whitespace_parse, word_parse
.global char_parse
.global string_eq, interpret, find_word, word_to_number, literal

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
  sys_push4         #save ra etc

  call whitespace_parse
  call non_whitespace_parse

  sys_pop4
  ret

/*

char-parse -- moves ^parse to next instance of char
              or at end of buffer

input:
  a0: char to find

returns:
  a0: ^parse at start of search
  a1: length of characters to matching char

*/
char_parse:

  lw a1, parse_point
  lw a2, parse_point_size

  mv a4, a1                 # record original location of ^parse
  add a3, a1, a2            # a3 = pointer to end of parse area
1:
  bge a1, a3, 3f            # while parse-point < parse-top
  lb a5, 0(a1)              # load byte at parse point
  beq a5, a0, 2f            # if byte is found, exit
  addi a1, a1, 1            # advance parse point by one
  j 1b                      # wend
2:
  addi a1, a1, 1
3:
  sub a2, a3, a1
  sw a1, parse_point, t0
  sw a2, parse_point_size, t0
  mv a0, a4
  sub a1, a1, a0

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
  sys_push4

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
  mv a0, s0
  mv a1, s1
  call print
  call print_question_mark # bad end
  call print_newline
  li t0, 1
  sw t0, immediate_mode, t1
  sys_pop4
  ret

2:                    # good end
  lw t0, immediate_mode
  beqz t0, 3f
  call print_ok
  call print_newline
  sys_pop4
  ret

3:
  call print_compiled
  call print_newline
  sys_pop4
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
  sys_push4
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
  sys_pop4
  ret
3:
  li a0, 0
  sys_pop4
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
  sys_push4
  call word_to_number
  beqz a1, 3f
  lw t0, immediate_mode
  beqz t0, 1f
  ds_push1
  j 2f
1:
  call literal
2:
  li a0, 1
  sys_pop4
  ret

3:
  li a0, 0
  sys_pop4
  ret

/*

# literal -- adds a literal to the word

arguments:
  a0: literal value

returns:
  nothing

*/
literal:
  lw t0, ptr_here
  la t1, lit_codeword
  sw t1, 0(t0)
  sw a0, SIZE(t0)
  addi t0, t0, 2*SIZE
  sw t0, ptr_here, t1
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
  sys_push4

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
  sys_pop4
  ret

2:
  li a1, 0
  li a0, 0            # return 0
  sys_pop4
  ret
/*

# word_to_number - converts word to + number.  -1 if fail

for the moment, only consider unsigned ints.  So -1 if anything else,
including extra characters.

arguments:
  a0: start of string to convert
  a1: size of found word

returns:
  a0: number converted, or 0 if failed
  a1: -1 if succeeded, or 0 if failed

variables:
  a0 : pointer to current character
  a2 : negative flag
  a3 : working value
  a4 : top of string
  a5 : current character/digit
  a6 : tempory value to compare
*/
word_to_number:
  li a3, 0        # Intial value

  li a6, 10
  add a4, a0, a1  # top of string
  li a2, 1

  lb a5, 0(a0)
  li a1, 45
  bne a5, a1, 1f
  li a2, -1
  addi a0, a0, 1

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
  mul a0, a3, a2
  li a1, -1
  ret
3:
  li a0, 0
  li a1, 0
  ret
