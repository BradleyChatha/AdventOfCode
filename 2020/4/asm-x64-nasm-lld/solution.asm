SECTION .bss
    
SECTION .data
    PRINT_PART_1 db 'Part 1: %lld', 0x0A, 0
    PRINT_PART_2 db 'Part 2: %lld', 0x0A, 0

%include "numberParser.asm"
%include "passportParser.asm"
%include "passportIterator.asm"
%include "part1.asm"
%include "part2.asm"

SECTION .text

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0

    call parsePassports

    lea rcx, [part1Validator]
    call iteratePassports
    
    lea rcx, [PRINT_PART_1]
    mov rdx, rax
    call printf

    lea rcx, [part2Validator]
    call iteratePassports
    
    lea rcx, [PRINT_PART_2]
    mov rdx, rax
    call printf
    
.leave:
    leave
    ret