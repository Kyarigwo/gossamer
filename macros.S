
/*
###############################################################################
#
# Stack manipulation macros
#
###############################################################################
*/

/*

#  The system stack

Should always be 16 byte aligned, so always grow, shrink by 4*SIZE

Also, if we pushn rega, regb, regc
we reverse this with popn rega, regb, regc

*/

.macro sys_push1 reg0
  addi sp, sp, -4*SIZE
  sw \reg0, 0(sp)
.endm

.macro sys_pop1 reg0
  lw \reg0, 0(sp)
  addi sp, sp, 4*SIZE
.endm

.macro sys_push2 reg0, reg1
  addi sp, sp, -4 * SIZE
  sw \reg0, 0(sp)
  sw \reg1, SIZE(sp)
.endm

.macro sys_pop2 reg0, reg1
  lw \reg0, 0(sp)
  lw \reg1, SIZE(sp)
  addi sp, sp, 4 * SIZE
.endm

.macro sys_push3 reg0, reg1, reg2
  addi sp, sp, -4 * SIZE
  sw \reg0, 0(sp)
  sw \reg1, SIZE(sp)
  sw \reg2, (2 * SIZE)(sp)
.endm

.macro sys_pop3 reg0, reg1, reg2
  lw \reg0, 0(sp)
  lw \reg1, SIZE(sp)
  lw \reg2, (2 * SIZE)(sp)
  addi sp, sp, 4 * SIZE
.endm

.macro sys_push4 reg0, reg1, reg2, reg3
  addi sp, sp, -(4 * SIZE)
  sw \reg0, (0 * SIZE)(sp)
  sw \reg1, (1 * SIZE)(sp)
  sw \reg2, (2 * SIZE)(sp)
  sw \reg3, (3 * SIZE)(sp)
.endm

.macro sys_pop4 reg0, reg1, reg2, reg3
  lw \reg0, (0 * SIZE)(sp)
  lw \reg1, (1 * SIZE)(sp)
  lw \reg2, (2 * SIZE)(sp)
  lw \reg3, (3 * SIZE)(sp)
  addi sp, sp, (4 * SIZE)
.endm




/*
################################################################################
#
#  Word creation macros
#
################################################################################

#  The general header

  .data 1 is a linear array of pointers to the word headers in .data 0

  .data
    1 byte name size
    n bytes name
    1 byte flags
    alignment to word

*/

.macro defheader label, name
.data 1
  .4byte name_\label
  .4byte end_name_\label - name_\label
.section .rodata
name_\label:
  .ascii "\name"
end_name_\label:
  .p2align 2                  # Padding to start of code
\label:                       # Execution pointer
.endm

/*

#  Defines an interpreted word

*/

.macro defword label, name
defheader \label, \name
  .4byte enter               # Start of code
.endm


/*

# Creates a variable

*/

.macro defvariable label, name
defheader \label, \name
  .4byte code_variable
.endm

/*

#  Defines a compiled word

  code_\label is pointer to .text code

*/

.macro defcodeword label, name
defheader \label, \name
  .4byte code_\label         # Start of code
.text
code_\label:
.endm

