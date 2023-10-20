
#include "common.S"

.global allot_memory

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

# mmaps a file (fd) into memory

arguments:
  a0: file descriptor (needs to be open)
  a1: size of file to map, in bytes

returns:
  a0: pointer if success, or -1 for failure

filemmap:
  mv t0, a0
  mv t1, a1
  li a0, 0
  li a1, t1
  li a2, PROT_READ
  li a3, MAP_PRIVATE
  li a4, t0
  li a5, 0
  li a7, SYS_MMAP
  ecall
  ret

*/
/*

# unmaps mapped memory

arguments:
  a0: address to unmap
  a1: size to unmap

returns:
  0 on success, -1 on failure

*/
munmap:
  li a7, SYS_MUNMAP
  ecall
  ret

/*

# open a file

a0: AT_FDCWD
const char *pathname,
int flags
mode_t mode
O_RDONLY 000000000
a0: AT_FDCWD
a1: pointer to file name in char?
a2: size
a3: flags
a4: mode
a7: SYS_OPENAT

arguments:
  a0: address of filename
  a1: size of filename

returns:
  a0: file descriptor


openfile:
  mv t0, a0
  mv t1, a1
  li a0, AT_FDCW
  li a1, t0
  li a2, t1
  li a3, O_RDONLY
  li a4, 0
  li a7 SYS_OPENAT
  ecall
  ret

*/

/*

# close a file
  a0: file descriptor

closefile:
  li SYS_CLOSE
  ecall
  ret

*/
/*

# lseek:
a0 fd
a1 ptr 0
a2 dir SEEK_END

a0 offset in bytes from start

*/
