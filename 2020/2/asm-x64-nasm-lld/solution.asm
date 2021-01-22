SECTION .data
    PRINT_I32  db '%d', 0x0A, 0
    PRINT_PART_1 db 'Part 1: %d', 0x0A, 0
    PRINT_PART_2 db 'Part 2: %d', 0x0A, 0
    DEBUG_STR db 'Lower: %lld | Upper: %lld | Char: %c | StrLen: %lld | Str: %.*s', 0x0A, 0

SECTION .text

%include "numberParser.asm"

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0

    ;mov rcx, 1
    ;mov rdx, 10
    ;xor r8, r8
    ;mov r8, 'A'
    ;lea r9, [PRINT_PART_1]
    ;mov r10, 4
    ;call debug

    ;lea rcx, [debug]
    ;call parseAndCount
    
    lea rcx, [part1]
    call parseAndCount
    
    lea rcx, [PRINT_PART_1]
    mov edx, eax
    call printf

    lea rcx, [part2]
    call parseAndCount
    
    lea rcx, [PRINT_PART_2]
    mov edx, eax
    call printf
    
.leave:
    leave
    ret

part1:
    push rbp
    mov rbp, rsp

    ; Register usage:
    ;   RAX              = Copy of R8 for use with scasb.
    ;   RCX, RDX, and R8 = The parameters and their original values.
    ;   RDI              = Iterator over original R9 parameter
    ;   R9               = Counter for how many times the character R8 appears
    ;   R10              = The non-standard parameter and its original value.
    ;                      Also serves as a decrementing counter for the loop condition.
    ;   R11              = Used in calcs
    push rdi
    mov rdi, r9
    xor r9, r9
    mov rax, r8

    ; Count how many times r8 occurs
.loop:
    scasb
    jne .continueLoop
    inc r9
    
.continueLoop:
    dec r10
    jnz .loop
.endLoop:

    ; return (r9 >= rcx) && (r9 <= rdx);
    xor rax, rax
    cmp r9, rcx
    jl .leave
    cmp r9, rdx
    jg .leave

    inc rax

.leave:
    pop rdi
    leave
    ret

part2:
    ; RAX = return value
    ; R10 = Used to make sure only one index has the correct character.
    ;       Originally a parameter, but we don't need its value.
    ; R11 = Temp storage of the current character.
    ; RCX, RDX, R8, R9, and (non-standard) = Parameters unchanged
    mov rax, 1
    xor r10, r10

    ; The problem passes these in as 1-based indicies.
    dec rcx
    dec rdx

    mov r11b, [r9 + rcx] ; I love that you can do this!
    cmp r11b, r8b
    jne .next

    inc r10

.next:
    mov r11b, [r9 + rdx]
    cmp r11b, r8b
    jne .leave

    inc r10

.leave:
    and rax, r10 ; No matches: r10 = 0
                 ; 1 match:    r10 = 1
                 ; 2 matches:  r10 = 2
                 ;
                 ; When RAX = 1, then we only return 1 for the '1 match' case without the need of branches.
    ret

debug:
    push rbp
    mov rbp, rsp

    ; Shadow space usage:
    ;   + 16 = Copy of RCX

    mov [rbp + 16], rcx

    ; strLen, strLen, str)
    push r9
    push r10
    push r10
    sub rsp, 32
    
    ; (DEBUG_STR, lower, upper, ch
    lea rcx, [DEBUG_STR]
    mov r9, r8
    mov r8, rdx
    mov rdx, [rbp + 16]

    call printf

    mov rax, 1
    leave
    ret

; size_t (bool function(size_t lower, size_t upper, char ch, char* str, [R10] size_t strLen))
; Input it assumed to be correctly formed. Null terminator is used instead of g_inputLen as it simplifies register management slightly.
parseAndCount:
    push rbp
    mov rbp, rsp

    ;int3

    push rsi
    push r12
    push r13
    sub rsp, 32

    ; Register usage:
    ;   RSI = Iterator over str
    ;   RAX = Depends
    ;   RCX = Depends
    ;   RDX = Depends
    ;   R12 = Copy of the function pointer
    ;   R13 = The eventual return value.
    ;   
    ; Shadow space usage:
    ;   + 16..24 = Current value of `lower`
    ;   + 24..32 = Current value of `upper`
    ;   + 32..33 = Current value of 'ch'
    ;   + 33..34 = The endline/null terminator, stored for later use.

    mov rsi, [g_input]
    mov r12, rcx
    xor r13, r13

.loop:

    ; Read first number
    ;   RAX = Current character
    ;   RCX = Substring start
    ;   RDX = Substring length
    mov rcx, rsi
    xor rdx, rdx
.firstNumberLoop:
    ; Keep loading characters until we hit the '-' 
    lodsb
    inc rdx
    cmp al, '-'
    jne .firstNumberLoop

    dec rdx ; Don't include the '-'
    call strToInt32
    mov [rbp + 16], rax
.endFirstNumberLoop:

    ; Same thing as the first loop, but we stop on ' ' instead of '-'
    mov rcx, rsi
    xor rdx, rdx
.secondNumberLoop:
    lodsb
    inc rdx
    cmp al, ' '
    jne .secondNumberLoop

    dec rdx ; Don't include the ' '
    call strToInt32
    mov [rbp + 24], rax
.endSecondNumberLoop:

    ; Load the policy character.
    lodsb
    mov [rbp + 32], al

    ; Skip ':' and ' '
    lodsb
    lodsb

    ; Read until new line or null terminator
    ;   r9 = Substring start
    ;   r10 = Substring length
    mov r9, rsi
    xor r10, r10
.readPasswordLoop:
    lodsb
    inc r10
    cmp al, 0x0A
    je .isEndOfLine
    cmp al, 0
    je .isEndOfLine
    jmp .readPasswordLoop
    .isEndOfLine:

    dec r10 ; Don't include new line in slice.
    mov [rbp + 33], al ; So we can easily check in a second whether we had a null terminator or a new line.

    ; Call the function pointer.
    ; r9 and r10 are already the correct values
    ; Just need to move everything else back from shadow storage.

    mov rcx, [rbp + 16]
    mov rdx, [rbp + 24]
    xor r8, r8
    mov r8b, [rbp + 32]
    call r12
    add r13, rax ; Function returns bool, so either increment or don't do anything.

    mov al, [rbp + 33]
    cmp al, 0
    je .endLoop
    jmp .loop

.endReadPasswordLoop:

.endLoop:

.leave:
    mov rax, r13
    add rsp, 32
    pop r13
    pop r12
    pop rsi
    leave
    ret