SECTION .bss
    
SECTION .data
    PRINT_PART_1 db 'Part 1: %lld', 0x0A, 0
    PRINT_PART_2 db 'Part 2: %lld', 0x0A, 0

    g_charsPerLine dq 0

SECTION .text

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0

    ;int3
    
    call calcLineSize
    call part1
    
    lea rcx, [PRINT_PART_1]
    mov rdx, rax
    call printf

    call part2
    
    lea rcx, [PRINT_PART_2]
    mov rdx, rax
    call printf

    mov rcx, [g_input]
    ;call printf
    
.leave:
    leave
    ret

; Does not contain error checking as I CBA
calcLineSize:
    push rbp
    mov rbp, rsp
    push rdi

    ;int3

    lea rdi, [g_input]
    mov rcx, [g_inputLen]
    mov rax, 0x0A

    repnz scasb

    sub rcx, 2 ; Don't ask, I give up with understanding why RCX's value is inconsistant. This works for me though.
    mov rax, [g_inputLen]
    sub rax, rcx
    mov [g_charsPerLine], rax

.leave:
    pop rdi
    leave
    ret

part1:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov rcx, 3
    mov rdx, 1
    call countTrees

    leave
    ret

part2:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 32

    mov rcx, 1
    mov rdx, 1
    call countTrees
    mov r12, rax

    mov rcx, 3
    mov rdx, 1
    call countTrees
    mul r12
    mov r12, rax

    mov rcx, 5
    mov rdx, 1
    call countTrees
    mul r12
    mov r12, rax

    mov rcx, 7
    mov rdx, 1
    call countTrees
    mul r12
    mov r12, rax

    mov rcx, 1
    mov rdx, 2
    call countTrees
    mul r12

    add rsp, 32
    pop r12
    leave
    ret

; size_t (size_t deltaX, size_t deltaY)
; I spent about 40 minutes debugging this, because I thought there was some issue inside the loop.
; Turns out I just forgot to move the return value into RAX.
; lol
countTrees:
    push rbp
    mov rbp, rsp
    push r12

    ;int3

    ; Register usage:
    ;   R8  = Copy of deltaX
    ;   R9  = Copy of deltaY
    ;   R10 = Cursor X
    ;   R11 = Cursor Y
    ;   RAX = Index into g_input, later the actual character is stored here.
    ;   RCX = TEMP
    ;   R12 = Tree Count
    mov r8, rcx
    mov r9, rdx
    mov r10, r8
    mov r11, r9
    xor r12, r12

; while(rax < g_inputLen)
.loop:
    ;   rax = (g_charsPerLine * r11) + r10
    ; & check loop condition
    mov rax, [g_charsPerLine]
    inc rax ; Include new lines
    mul r11
    add rax, r10
    mov rcx, [g_inputLen]
    cmp rax, rcx
    jge .endLoop

    ; al = g_input[rax]
    mov rcx, [g_input]
    add rcx, rax
    mov al, byte [rcx]
    ;mov [rcx], byte 'X'
    
    cmp al, '#'
    jne .notATree
    inc r12
.notATree:

    add r11, r9

    ; cursorX = (cursorX + deltaX) % g_charsPerLine
    add r10, r8
    mov rax, r10
    xor rdx, rdx
    mov rcx, [g_charsPerLine]
    div rcx
    mov r10, rdx ; Remainder
    
    jmp .loop
.endLoop:

.leave:
    mov rax, r12
    pop r12
    leave
    ret