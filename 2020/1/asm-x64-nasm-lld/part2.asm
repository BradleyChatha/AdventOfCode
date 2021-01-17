SECTION .data
    PRINT_NUMBERS db '%d %d %d', 0x0A, 0

SECTION .text

part2:
    push rbp
    mov rbp, rsp
    push rsi
    push r10
    push r11
    push r12
    push r13
    sub rsp, 32 + 0 + 0

    ;int3

    ; Register usage:
    ;   RSI - Pointer into g_numberBuffer for inner loop
    ;   R9  - Counter for inner loop, copy of R8
    ;   R10 - Pointer into g_numberBuffer for outer loop
    ;   R8  - Counter for outer loop, copy of g_numberBufferLen
    ;   EAX - Temp
    ;   RCX - Temp
    ;   R11 - First number
    ;   R12 - Second number
    ;   R13 - Third number
    xor rax, rax
    xor r11, r11
    lea r10, [g_numberBuffer]
    mov r8, [g_numberBufferLen]

.outerLoop:
    mov r11d, dword [r10]
    add r10, 4
    
    cmp r11, 2020
    jge .continueOuterLoop

    mov rsi, r10
    mov r9, r8
    .innerLoop:
        lodsd
        mov r12, rax

        add rax, r11
        cmp rax, 2020
        jge .continueInnerLoop

        mov rcx, 2020
        sub rcx, rax
        mov r13, rcx

        call search

        test rax, rax
        jz .continueInnerLoop

        mov rax, r11
        mul r12
        mul r13
        jmp .leave

    .continueInnerLoop:
        dec r9
        jnz .innerLoop
    .endInnerLoop:

.continueOuterLoop:
    dec r8
    jnz .outerLoop
.endOuterLoop:

.leave:
    pop r13
    pop r12
    pop r11
    pop r10
    pop rsi
    leave
    ret