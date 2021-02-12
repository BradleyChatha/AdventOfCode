SECTION .bss
    ; A bit mask where each bit represents a set.
    ; 1 = Found in the input
    ; 0 = Not found
    ;
    ; This data is populated by part 1.
    part2_seatBitMasks resb ROW_COUNT
    part2_seatBitMasksDebugString resb BITMASK_DEBUG_STRING_LENGTH

SECTION .data
    ROW_COUNT: equ 128
    BITMASK_DEBUG_STRING_LENGTH: equ (ROW_COUNT * 9) + 1 ; * 9 for 8 characters (for one byte) + a new line char. + 1 for the null terminator.

    PRINT_PART_1 db 'Part 1: %lld', 0x0A, 0
    PRINT_PART_2 db 'Part 2: %lld', 0x0A, 0

    ; We're indexing via a nibble, hence why there's 15 entries.
    part1_jumpTable: dq part1.b, _trap, part1.f, _trap, part1.newline, part1.l, _trap, _trap, part1.r, _trap, _trap, _trap, _trap, _trap, _trap, _trap

%include "numberParser.asm"

SECTION .text

; void ()
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 32 + 0 + 0

    call part1
    
    lea rcx, [PRINT_PART_1]
    mov rdx, rax
    call printf

    ;call debugPrint

    call part2

    lea rcx, [PRINT_PART_2]
    mov rdx, rax
    call printf
    
.leave:
    leave
    ret

debugPrint:
    push rbp
    mov rbp, rsp

    push rsi
    push rdi

    ; Register usage:
    ;   RSI = Cursor into the bitmask array
    ;   RDI = Cursor into the debug string
    ;   RAX = The current byte being used
    ;   RCX = Loop counter (decrementing)
    ;   RDX = Calcs

    mov rcx, ROW_COUNT
    lea rsi, [part2_seatBitMasks]
    lea rdi, [part2_seatBitMasksDebugString]

.loop:
    lodsb
    mov dl, al
%rep 8
    and al, 1
    add al, '0'
    stosb
    shr dl, 1
    mov al, dl
%endrep
    mov al, 0x0A
    stosb
    dec rcx
    jnz .loop
.endLoop:

    pop rdi
    pop rsi

    sub rsp, 32
    lea rcx, [part2_seatBitMasksDebugString]
    call printf
    add rsp, 32

    leave 
    ret

part1:
    push rbp
    mov rbp, rsp
    push rsi
    push rbx

    ; Register usage:
    ;   RSI     = Cursor into g_input
    ;   CH      = Highest known row.
    ;   CL      = Highest known column.
    ;   DH      = Current row upper.
    ;   DL      = Current row lower.
    ;   BH      = Current column upper.
    ;   BL      = Current column lower.
    ;   R8      = Seat ID for highest known row-column pair.
    ;   R9      = Decrementing loop counter.
    ;   R10     = Temp calcs.
    ;   RAX     = Current character from input.
    ;             Also used for temp calcs, since we only need the character for a single branch check.

    mov rsi, [g_input]
    xor rcx, rcx
    xor r8, r8
    mov r9, [g_inputLen]

    mov dx, 0x7F00
    mov bx, 0x0700

    ;int3
    ;nop

.perLineLoop:
    xor rax, rax
    lodsb

    ; Some magic we can perform here!
    ; For the characters: \n, F, B, R, L
    ; Formula: f(char) = (char - 66) >> 2 
    ; Produces:
    ;   \n = 0xE4
    ;   B  = 0x00
    ;   F  = 0x02
    ;   L  = 0x05
    ;   R  = 0x08
    ;
    ; Notice that the lower nibble is unique? OwO
    ; *sniff sniff* do I smell.. Jump tables? UwU
    sub al, 66
    shr al, 1
    and al, 0x0F
    shl al, 3
    lea r10, part1_jumpTable
    add r10, rax
    jmp [r10]

; All of these are pretty much the same:
;   Find the difference between lower and upper.
;   Half the difference.
;   Add/subtract from the upper/lower.
.b:
    xor al, al
    or al, dh
    inc al
    sub al, dl
    shr al, 1
    add dl, al
    jmp .continuePerLineLoop
.f:
    xor al, al
    or al, dh
    inc al
    sub al, dl
    shr al, 1
    sub dh, al
    jmp .continuePerLineLoop
.r:
    xor al, al
    or al, bh
    inc al
    sub al, bl
    shr al, 1
    add bl, al
    jmp .continuePerLineLoop
.l:
    xor al, al
    or al, bh
    inc al
    sub al, bl
    shr al, 1
    sub bh, al
    jmp .continuePerLineLoop
.newline:
    ; Calculate the seat ID, and set r8 to to it if we've got a new high scoring one.
    movzx r10, dl
    shl r10, 3
    movzx rax, bl
    add r10, rax

    ; RAX, RDX and RBX are free for a moment, so we can use those to calculate an index into the bitmask array (and the bitmask itself!)
    and rdx, 0xFF ; index into array
    and rbx, 0x0F ; index into bitmask

    ; Turns out shl only allows cl as the second parameter, and I really can't be arsed with changing current usage of RCX, soooooo
    push rcx
    mov rax, 1
    mov cl, bl
    shl eax, cl
    lea rcx, [part2_seatBitMasks]
    add rcx, rdx
    or [rcx], al
    pop rcx

    mov dx, 0x7F00
    mov bx, 0x0700

    ; Then continue with the actual comparison stuff.
    cmp r10, r8
    jl .continuePerLineLoop
    mov r8, r10
    mov ch, dl
    mov cl, bl
.continuePerLineLoop:
    dec r9
    jnz .perLineLoop
.leavePerLineLoop:
    mov rax, r8
    pop rbx
    pop rsi
    leave
    ret

part2:
    push rbp
    mov rbp, rsp

    push rsi

    ; Register usage:
    ;   RSI = Cursor into the bitmask array
    ;   RAX = The current byte being used
    ;   RCX = Loop counter (decrementing)
    ;   RDX = Calcs
    ;   R8  = Bit counter
    ;   R9  = Flag

    mov rcx, ROW_COUNT
    lea rsi, [part2_seatBitMasks]
    xor rdx, rdx
    mov r9, 1

.loop:
    lodsb
    cmp al, 0
    je .continueLoop
    cmp al, 0xFF
    je .continueLoop
    dec r9 ; Skip the first empty seat we find. Because of the "We're not at the very front" part of the problem.
    jz .continueLoop

    mov dl, al
    xor r8, r8
%rep 8
    and al, 1
    jz .foundUnset
    inc r8
    shr dl, 1
    mov al, dl
%endrep
.foundUnset:
    dec rsi ; Otherwise we'd be one over
    lea rdx, [part2_seatBitMasks]
    sub rsi, rdx ; Address to byte index. a.k.a the row
    shl rsi, 3
    add rsi, r8
    mov rax, rsi    
    jmp .endLoop
.continueLoop:
    dec rcx
    jnz .loop
.endLoop:
    pop rsi
    leave
    ret

_trap:
    int3