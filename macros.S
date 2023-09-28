
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

.macro push1 reg0
  addi DS, DS, -(1 * SIZE)
  sw \reg0, (0 * SIZE)(DS)
.endm

.macro pop1 reg0
  lw \reg0, (0 * SIZE)(DS)
  addi DS,  DS, (1 * SIZE)
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
