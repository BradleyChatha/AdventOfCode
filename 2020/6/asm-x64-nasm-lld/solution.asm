SECTION .bss
    MAX_PEOPLE_PER_SET: equ 20
    APPROX_SET_COUNT:   equ 2000

    g_part2Buffer: resd MAX_PEOPLE_PER_SET ; One dword per person

SECTION .data

SECTION .text

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0
    
    call solution

.leave:
    leave
    ret

solution:
    push rbp
    mov rbp, rsp

    push rsi
    push r10
    push r11
    push r12
    push r13

    ; Register usage:
    ;   RAX = Current char + calcs.
    ;   RCX = Used for arithmetic and temps.
    ;   RDX = Decementing loop counter.
    ;   RSI = Index into the input.
    ;   R8D = Current set for part 1
    ;   R13D = Current set for part 2
    ;   R9  = Flags.
    ;   R10 = Sum for part 1
    ;   R11 = Sum for part 2
    ;   R12 = Index into g_part2Buffer

    mov rdx, [g_inputLen]
    mov rsi, [g_input]
    xor r8, r8
    xor r9, r9
    xor r10, r10
    xor r11, r11
    xor r12, r12
    xor r13, r13
    ;int3
    nop

.loop:
    lodsb
    cmp al, 0x0A
    je .newLine

    ; We are using a single dword as a set.
    ; This is because the input range is from 'a'-'z', which we can map to 0-26, which fits nicely into a dword.
    
    mov cl, al
    sub cl, 'a'
    mov eax, 1
    shl eax, cl
    or r8d, eax ; Add the character to the set.
    or r13d, eax

    ; Unset "new line" flag
    and r9b, 0xFE

    jmp .continueLoop

.newLine:
    ; We don't care about the character anymore, so RAX is freed up until the next loop.
    mov rax, r9
    and rax, 0x01
    jnz .endOfSet

    ; For part 2, we'll push the set into the part 2 buffer.
    lea rax, [g_part2Buffer]
    mov rcx, r12
    shl rcx, 2
    add rax, rcx
    mov [rax], r13d
    inc r12
    xor r13, r13 ; Reset part 2's set, since we're going per-person for that one.

    or r9, 0x01
    jmp .continueLoop

.endOfSet:
    ; For part 1, we can just count the number of set bits in its set.
    xor rax, rax
    popcnt eax, r8d
    add r10, rax
    xor r8d, r8d

    ; For part 2, we need to do something slightly different.
    ; AND all the sets into a single value, and *then* count the bits.
    lea rax, [g_part2Buffer]
    mov ecx, 0x7FFFFFFF
.innerLoop:
    and ecx, dword [rax]
    add rax, 4
.continueInnerLoop:
    dec r12
    jnz .innerLoop
.endInnerLoop:
    popcnt eax, ecx
    add r11, rax

    jmp .continueLoop

.continueLoop:
    dec edx
    jnz .loop

.leave:
    mov [g_part1Answer], r10
    mov [g_part2Answer], r11

    pop r13
    pop r12
    pop r11
    pop r10
    pop rsi
    leave
    ret