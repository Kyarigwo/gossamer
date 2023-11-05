
#include "../common.S"

.global add_input_parsing
.global word_parse, find_word, word_to_number, literal
/*
################################################################################
#
# input parsing
#
################################################################################
*/

add_input_parsing:
  sys_push4
  call add_gmer_refill_input
  call add_gmer_whitespace_parse
  call add_gmer_non_whitespace_parse
  call add_gmer_word_parse
  call add_gmer_char_parse
  call add_gmer_string_eq
  call add_gmer_find_word
  call add_gmer_word_to_number
  sys_pop4
  ret

/*
################################################################################
#
# interpret words
#
################################################################################
*/

make_codeword refill_input, "refill-input"
  call refill_input
  ds_push2
  j next

make_codeword whitespace_parse, "whitespace-parse"
  call whitespace_parse
  ds_push2
  j next

make_codeword non_whitespace_parse, "non-whitespace-parse"
  call non_whitespace_parse
  ds_push2
  j next

make_codeword word_parse, "word-parse"
  call word_parse
  ds_push2
  j next

make_codeword char_parse, "char-parse"
  ds_pop1
  call char_parse
  ds_push2
  j next

make_codeword string_eq, "\"="
  ds_pop4
  call string_eq
  ds_push1
  j next

make_codeword find_word, "find-word"
  ds_pop2
  call find_word
  ds_push2
  j next

make_codeword word_to_number, "\">#"
  ds_pop2
  call word_to_number
  ds_push2
  j next
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
  la a1, scratch_input_buffer
  li a2, INPUT_BUFFER_MAX
  li a7, SYS_READ
  ecall
  bltz a0, 1f                   # if successful
  mv t0, a0                     # size of result
  la a0, scratch_input_buffer   # base of input buffer
  sw a0, input_bottom, t1       # store input_bottom
  sw a0, parse_point, t1        # store parse_point
  add a1, a0, t0              # top of input buffer
  sw a1, input_top, t1        # store input_top
  mv a1, t0
  ret
1:
  li a0, 0
  ret

/*

whitespace_parse -- moves {input} to first point past
                              whitespace, or end of buffer

input:
  none

returns:
  a0: original value of {input}
  a1: distance between new {input} and old {input}

*/
whitespace_parse:
  lw a0, parse_point
  mv a2, a0
  lw a3, input_top
  li a4, 32           # space to compare to
1:
  bge a2, a3, 2f      # while parse-point < parse-top
  lb  a5, 0(a2)       #   load byte at parse point
  bgtu a5, a4, 2f      #   if byte is > 32, exit
  addi a2, a2, 1      #   advance parse point by one
  j 1b                # wend
2:
  sw a2, parse_point, t0
  sub a1, a2, a0
  ret

/*

non_whitespace_parse -- moves {input} to first whitespace point past
                          non-whitespace, or end of of buffer

input:
  none

returns:
  a0: original value of {input}
  a1: distance between new {input} and old {input}

*/
non_whitespace_parse:
  lw a0, parse_point
  mv a2, a0
  lw a3, input_top
  li a4, 32           # space to compare to
1:
  bge a2, a3, 2f      # while parse-point < parse-top
  lb  a5, 0(a2)       #   load byte at parse point
  bleu a5, a4, 2f      #   if byte is < 32, exit
  addi a2, a2, 1      #   advance parse point by one
  j 1b                # wend
2:
  sw a2, parse_point, t0
  sub a1, a2, a0
  ret


/*

word_parse -- moves {input} to past next whitespace seperated word
                or at end of buffer

input:
  none

returns:
  a0: {input} at start of word
  a1: length of word, or 0 if not found

*/
word_parse:
  sys_push4         #save ra etc

  call whitespace_parse
  call non_whitespace_parse

  sys_pop4
  ret

/*

char-parse -- moves {input} to next instance of char
              or at end of buffer

input:
  a0: char to find

returns:
  a0: {parse} at start of search
  a1: length of characters to matching char

*/
char_parse:
  mv a4, a0
  lw a0, parse_point
  mv a2, a0
  lw a3, input_top
1:
  bge a2, a3, 3f      # while parse-point < parse-top
  lb  a5, 0(a2)       #   load byte at parse point
  beq a5, a4, 2f            # if byte is found, exit
  addi a2, a2, 1
  j 1b
2:
  addi a2, a2, 1            # move point past character
3:
  sw a2, parse_point, t0
  sub a1, a2, a0
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
