DEFAULT REL
GLOBAL main
BITS 64

SECTION .data
    MSG_TIME_TAKEN      db 'Time: %lld us', 0x0A, 0
    MSG_READING_INPUT 	db 'Reading input file.', 0x0A, 0
    INPUT_FILE 			db '../input1.txt', 0
    READ_MODE			db 'rb', 0
    PRINT_STRING_LINE   db '%s', 0x0A, 0
    PRINT_PART_1        db 'Part 1: %lld', 0x0A, 0
    PRINT_PART_2        db 'Part 2: %lld', 0x0A, 0
    
    SEEK_END			equ 2
    
    g_input               dq 0 ; Ptr to allocated memory
    g_inputLen            dq 0 ; Length of g_input
    g_ticksBeforeSolution dq 0 ; Ticks before the solve function is called.
    g_ticksAfterSolution  dq 0 ; Ticks after the solve function was called.
    g_part1Answer         dq 0
    g_part2Answer         dq 0

SECTION .text

extern printf

extern fopen
extern fclose
extern fread
extern fseek
extern ftell

extern malloc
extern free

extern QueryPerformanceCounter

%include "solution.asm"

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0 ; 32 for the shadow space, x for our own variables, then y for alignment.
    
    ;int3
    
    ; Register usage:
    ;	r12 = FILE* to the input file.
    ;   r13 = Length of file & buffer.
    ;   r14 = void* to the buffer.
    xor r14, r14
    
    lea rcx, [MSG_READING_INPUT]
    call printf
    
    ; Open the file with a null check
    lea rcx, [INPUT_FILE]
    lea rdx, [READ_MODE]
    call fopen
    
    mov r12, rax
    
    test r12, r12
    jz .leave
    
    ; Get the file's length
    mov rcx, r12
    mov rdx, 0
    mov r8, SEEK_END
    call fseek
    
    test rax, rax
    jnz .leave
    
    mov rcx, r12
    call ftell
    
    mov [g_inputLen], rax
    mov r13, rax
    
    mov rcx, r12
    mov rdx, 0
    mov r8, 0
    call fseek
    
    ; Allocate the memory needed.
    lea rcx, [r13 + 1]
    call malloc
    
    mov r14, rax
    
    test r14, r14
    jz .leave
    
    lea rax, [r14 + r13]
    mov [rax], byte 0
    
    ; Read in the text file.
    mov rcx, r14
    mov rdx, 1
    mov r8, r13
    mov r9, r12
    call fread
    
    cmp r13, rax
    jne .leave

    ; Get ticks for timing purposes.
    lea rcx, [g_ticksBeforeSolution]
    call QueryPerformanceCounter
    
    ; Call the solving code.
    mov [g_input], r14
    call solve

    ; Get ticks after, and print out the time the solve function took.
    lea rcx, [g_ticksAfterSolution]
    call QueryPerformanceCounter

    mov rdx, [g_ticksAfterSolution]
    sub rdx, [g_ticksBeforeSolution]
    lea rcx, [MSG_TIME_TAKEN]
    call printf

    lea rcx, [PRINT_PART_1]
    mov rdx, [g_part1Answer]
    call printf

    lea rcx, [PRINT_PART_2]
    mov rdx, [g_part2Answer]
    call printf
    
.leave:
    mov rcx, r12
    call fclose
    
    test r14, r14
    jz .noBuffer
        mov rcx, r14
        call free
.noBuffer:
    
    xor rax, rax
    leave
    ret