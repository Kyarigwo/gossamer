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



#define IP s11
#define DS s10
#define RS s9
#define LS s8

// system sizes
#define SIZE 4
#define DATA_STACK_SIZE 1
#define RETURN_STACK_SIZE 1
#define LOCAL_STACK_SIZE 1
#define DATA_AREA_SIZE 4
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

#  push a0 and a1 onto the stack, with order a0 a1

*/
.macro push2
  addi DS, DS, -(2 * SIZE)
  sw a1, (0 * SIZE)(DS)
  sw a0, (1 * SIZE)(DS)
.endm

/*

# pop a0 and a1 of of the stack, with order a0, a1

*/
.macro pop2
  lw a1, (0 * SIZE)(DS)
  lw a0, (1 * SIZE)(DS)
  addi DS,  DS, (2 * SIZE)
.endm

/*

# push a0, a1, a2 onto the stack, with order a0 a1 a2

*/
.macro push3
  addi DS, DS, -(3 * SIZE)
  sw a2, (0 * SIZE)(DS)
  sw a1, (1 * SIZE)(DS)
  sw a0, (2 * SIZE)(DS)
.endm

/*

# pop a0, a1, a2 off the stack, with order a0 a1 a2

*/
.macro pop3
  lw a2, (0 * SIZE)(DS)
  lw a1, (1 * SIZE)(DS)
  lw a0, (2 * SIZE)(DS)
  addi DS,  DS, (3 * SIZE)
.endm


/*

# push a0, a1, a2, a3 onto the stack, with order a0 a1 a2 a3

*/
.macro push4
  addi DS, DS, -(4 * SIZE)
  sw a3, (0 * SIZE)(DS)
  sw a2, (1 * SIZE)(DS)
  sw a1, (2 * SIZE)(DS)
  sw a0, (3 * SIZE)(DS)
.endm

/*

# pop a0, a1, a2, a3 off the stack, with order a0 a1 a2 a3

*/
.macro pop4
  lw a3, (0 * SIZE)(DS)
  lw a2, (1 * SIZE)(DS)
  lw a1, (2 * SIZE)(DS)
  lw a0, (3 * SIZE)(DS)
  addi DS, DS, (4 * SIZE)
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
