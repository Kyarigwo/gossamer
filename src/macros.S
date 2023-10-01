
/*
###############################################################################
#
# Stack manipulation macros
#
###############################################################################
*/

/*

/*
################################################################################
#
# return stack - in s9
#
################################################################################
*/

.macro pushr1 reg0
  addi RS, RS, -(1 * SIZE)
  sw \reg0, (0 * SIZE)(RS)
.endm

.macro popr1 reg0
  lw \reg0, (0 * SIZE)(RS)
  addi RS, RS, (1 * SIZE)
.endm


/*
################################################################################
#
# data stack - in s10
#
################################################################################
*/

.macro push1
  addi DS, DS, -(1 * SIZE)
  sw a0, (0 * SIZE)(DS)
.endm

.macro pop1
  lw a0, (0 * SIZE)(DS)
  addi DS,  DS, (1 * SIZE)
.endm

/*

#  push a0 and a1 onto the stack, with order a1 a0

*/
.macro push2
  addi DS, DS, -(2 * SIZE)
  sw a0, (0 * SIZE)(DS)
  sw a1, (1 * SIZE)(DS)
.endm

/*

# pop a0 and a1 of of the stack, with order a1, a0

*/
.macro pop2
  lw a0, (0 * SIZE)(DS)
  lw a1, (1 * SIZE)(DS)
  addi DS,  DS, (2 * SIZE)
.endm


/*
################################################################################
#
# Helper macros
#
################################################################################
*/

/*

# print literal - prints a given string

*/
.macro print_literal label, value
print_\label:
  la a0, \label\()_msg
  la a1, \label\()_msg_length
  tail print

.section .rodata
\label\()_msg:
  .ascii "\value"
.equ \label\()_msg_length, .-\label\()_msg

.text
.endm

/*

# Load and create a literal string

*/
.macro string_literal label, value
  la a0, \label\()_msg
  la a1, \label\()_msg_length

.section .rodata
\label\()_msg:
  .ascii "\value"
.equ \label\()_msg_length, .-\label\()_msg

.text

.endm

.macro make_codeword label, value
add_gmer_\label:
  jal x5, sys_push4
  la a0, str_msg_\label
  la a1, str_msg_length_\label
  call header
  la a0, gmer_\label
  call add_codeword
  call end_word
  jal x5, sys_pop4
  ret

.section .rodata
str_msg_\label:
  .ascii "\value"
.equ str_msg_length_\label, .-str_msg_\label

.text
gmer_\label:

.endm
