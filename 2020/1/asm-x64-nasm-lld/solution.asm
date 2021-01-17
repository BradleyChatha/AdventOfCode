SECTION .bss
    g_numberBuffer: resd 1000 ; We'll have a hard limit of 1000 numbers because I'm lazy.
    
SECTION .data
    PRINT_I32  db '%d', 0x0A, 0
    TEST_NUM_1 db '0', 0
    TEST_NUM_2 db '9', 0
    TEST_NUM_3 db '32', 0
    TEST_NUM_4 db '420', 0
    
    g_numberBufferLen: dq 0

SECTION .text

%include "numberParser.asm"
%include "search.asm"
%include "part1.asm"
%include "part2.asm"

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0
    
    ;int3
    nop
    
    call parseNumbers
    call sortNumbers
    ;call printNumbers
    
    call part1
    
    lea rcx, [PRINT_I32]
    mov edx, eax
    call printf
    
.leave:
    leave
    ret
    
; Debug function
printNumbers:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    sub rsp, 32

    mov r12, [g_numberBufferLen]
    lea r13, [g_numberBuffer]
    xor rdx, rdx
    
.loop:
    test r12, r12
    jz .leave
    
    lea rcx, [PRINT_I32]
    mov edx, [r13]
    call printf
    
    add r13, 4
    
    dec r12	
    jmp .loop
    
.leave:
    add rsp, 32
    pop r13
    pop r12
    leave
    ret