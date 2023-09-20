
/*
###############################################################################
#
# Stack manipulation macros
#
###############################################################################
*/

/*

#  The data stack - grows down

*/

# ( -- reg0 ) - push reg0
.macro push1 reg0
  addi sp, sp, -SIZE
  sw \reg0, 0(sp)
.endm

# ( reg0 -- ) - pop reg0
.macro pop1 reg0
  lw \reg0, 0(sp)
  addi sp, sp, SIZE
.endm

# ( -- reg0 reg1) push reg0 then reg1
.macro push2 reg0, reg1
  addi sp, sp, -(2 * SIZE)
  sw \reg1, 0(sp)
  sw \reg0, SIZE(sp)
.endm

# ( reg1 reg0 -- ) - pop reg0 then reg1
.macro pop2 reg0, reg1
  lw \reg0, 0(sp)
  lw \reg1, SIZE(sp)
  addi sp, sp, (2 * SIZE)
.endm

# ( -- reg0 reg1 reg2 ) - push reg0 then reg1 then reg2
.macro push3 reg0, reg1, reg2
  addi sp, sp, -(3 * SIZE)
  sw \reg2, 0(sp)
  sw \reg1, SIZE(sp)
  sw \reg0, (2 * SIZE)(sp)
.endm

# ( -- reg2 reg1 reg0 ) - pop reg0 then reg1 then reg2
.macro pop3 reg0, reg1, reg2
  lw \reg0, 0(sp)
  lw \reg1, SIZE(sp)
  lw \reg2, (2 * SIZE)(sp)
  addi sp, sp, (3 * SIZE)
.endm

# ( -- reg0 reg1 reg2 reg3 ) - push reg0 then reg1 then reg2 then reg3
.macro push4 reg0, reg1, reg2, reg3
  addi sp, sp, -(4 * SIZE)
  sw \reg3, (0 * SIZE)(sp)
  sw \reg2, (1 * SIZE)(sp)
  sw \reg1, (2 * SIZE)(sp)
  sw \reg0, (3 * SIZE)(sp)
.endm

# ( -- reg2 reg1 reg0 ) - pop reg0 then reg1 then reg2 then reg3
.macro pop4 reg0, reg1, reg2, reg3
  lw \reg0, (0 * SIZE)(sp)
  lw \reg1, (1 * SIZE)(sp)
  lw \reg2, (2 * SIZE)(sp)
  lw \reg3, (3 * SIZE)(sp)
  addi sp, sp, (4 * SIZE)
.endm

# ( -- reg0 reg1 reg2 reg3 reg4) - push reg0 then reg1 then reg2 then reg3 then reg4
.macro push5 reg0, reg1, reg2, reg3, reg4
  addi sp, sp, -(5 * SIZE)
  sw \reg4, (0 * SIZE)(sp)
  sw \reg3, (1 * SIZE)(sp)
  sw \reg2, (2 * SIZE)(sp)
  sw \reg1, (3 * SIZE)(sp)
  sw \reg0, (4 * SIZE)(sp)
.endm

# ( -- reg4 reg3 reg2 reg1 reg0 ) - pop reg0 then reg1 then reg2 then reg3, then reg4
.macro pop5 reg0, reg1, reg2, reg3, reg4
  lw \reg0, (0 * SIZE)(sp)
  lw \reg1, (1 * SIZE)(sp)
  lw \reg2, (2 * SIZE)(sp)
  lw \reg3, (3 * SIZE)(sp)
  lw \reg4, (4 * SIZE)(sp)
  addi sp, sp, (5 * SIZE)
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

.macro defheader label, flags=0, name
.data 1
  .word name_\label
.data
name_\label:
  .byte flags_\label - . - 1  # trick to have correct length of name
  .ascii "\name"
flags_\label:
  .byte \flags                # Flags
  .p2align 2                  # Padding to start of code
\label:                       # Execution pointer
.endm

/*

#  Defines an interpreted word

*/

.macro defword label, flags=0, name
defheader \label, \flags, \name
  .word enter               # Start of code
.endm


/*

# Creates a variable

*/

.macro defvariable label, flags=0, name
defheader \label, \flags, \name
  .word code_variable
.endm

/*

#  Defines a compiled word

  code_\label is pointer to .text code

*/

.macro defcodeword label, flags=0, name
defheader \label, \flags, \name
  .word code_\label         # Start of code
.text
code_\label:
.endm

