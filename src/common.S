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
#define SYS_MUNMAP 215
#define SYS_EXIT 93
#define SYS_WRITE 64
#define SYS_READ 63
#define SYS_OPENAT 56
#define SYS_CLOSE 57
#define SYS_LSEEK 62

// Data for mmap
#define PAGESIZE 4096  // page size
#define PROT_READ 0x1
#define PROT_WRITE 0x2
#define MAP_ANONYMOUS 0x20
#define MAP_PRIVATE 0x02

#define AT_FDCW -100
#define O_RDONLY  0

/*
###############################################################################
#
# Stack manipulation macros
#
###############################################################################
*/
/*
################################################################################
#
# System stack
#
################################################################################
*/
.macro sys_push4
  jal x5, l_sys_push4
.endm

.macro sys_pop4
  jal x5, l_sys_pop4
.endm

.macro sys_push8
  jal x5, l_sys_push8
.endm

.macro sys_pop8
  jal x5, l_sys_pop8
.endm

/*
################################################################################
#
# return stack - in s9
#
################################################################################
*/

.macro rs_pushIP
  jal x5, l_rs_pushIP
.endm

.macro rs_popIP
  jal x5, l_rs_popIP
.endm


/*
################################################################################
#
# data stack - in s10
#
################################################################################
*/

/*

# push/pop a0

*/

.macro ds_push1
  jal x5, l_ds_push1
.endm

.macro ds_pop1
  jal x5, l_ds_pop1
.endm

/*

#  push/pop a0 a1

*/
.macro ds_push2
  jal x5, l_ds_push2
.endm

.macro ds_pop2
  jal x5, l_ds_pop2
.endm

/*

# push/pop a0, a1, a2

*/
.macro ds_push3
  jal x5, l_ds_push3
.endm

.macro ds_pop3
  jal x5, l_ds_pop3
.endm

/*

# push/pop a0 a1 a2 a3

*/
.macro ds_push4
  jal x5, l_ds_push4
.endm

.macro ds_pop4
  jal x5, l_ds_pop4
.endm

/*

# push/pop a0 a1 a2 a3 a4

*/
.macro ds_push5
  jal x5, l_ds_push5
.endm

.macro ds_pop5
  jal x5, l_ds_pop5
.endm

/*

# push/pop a0 a1 a2 a3 a4 a5

*/
.macro ds_push6
  jal x5, l_ds_push6
.endm

.macro ds_pop6
  jal x5, l_ds_pop6
.endm

/*
################################################################################
#
# return stack - in s9
#
################################################################################
*/

/*

# push/pop a0

*/
.macro rs_push1
  jal x5, l_rs_push1
.endm

.macro rs_pop1
  jal x5, l_rs_pop1
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
  sys_push4
  la a0, str_msg_\label
  la a1, str_msg_length_\label
  call header
  la a0, gmer_\label
  call add_codeword
  call end_word
  sys_pop4
  ret

.section .rodata
str_msg_\label:
  .ascii "\value"
.equ str_msg_length_\label, .-str_msg_\label

.text
gmer_\label:

.endm
