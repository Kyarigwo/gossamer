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
