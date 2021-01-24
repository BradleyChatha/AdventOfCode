SECTION .data
    ; If you add the first two characters of each entry name together, you get numbers in the non-conflicting range of 200-226.
    ; So that means we can easily transform the range into 0-26, allowing us to create a jump table to each verify method.
    ;
    ; Invalid indicies into the jump table will go to the "_trap" function which is just the int3 opcode.
    ;
    ; P.S Thank god the mapping was simple, because if I had to do anything more than "add then subtract" you'd instead be seeing "cmp -> jmp" hell.
    ;
    ; I wanted to have a comment on each line to specify each index, but then I couldn't escape the new line character to make this multiline :(
    JUMP_TABLE: dq eclValidator, \
                   _trap       , \
                   _trap       , \
                   hclValidator, \
                   cidValidator, \
                   _trap       , \
                   _trap       , \
                   hgtValidator, \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   pidValidator, \
                   _trap       , \
                   byrValidator, \
                   _trap       , \
                   _trap       , \
                   eyrValidator, \
                   _trap       , \
                   _trap       , \
                   _trap       , \
                   iyrValidator    

SECTION .text

; All jump table functions are in the format: bool function(passport_entry* entry, size_t valueLength)
;                                             For convenience, the pointer is advanced by 3 bytes to skip the name chars.
part2Validator:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    sub rsp, 32

    ; Register usage:
    ;   RAX = Return value and some temp calcs.
    ;   RCX = Param, pointer to the current passport_entry.
    ;   RDX = Param, also serves as a reverse counter for the loop.
    ;   R8  = Temp calcs, also stores the jump table result.
    ;   R9  = Temp iterator over entry's value.
    ;   R12 = Copy of JUMP_TABLE.
    ;   R13 = Counter of valid passports.
    ;
    ; Shadow space usage:
    ;   ebp+16..ebp+24 = Copy of RCX when we're calling another function.
    ;   ebp+24..ebp+32 = Copy of RDX for same reason as above.
    lea r12, [JUMP_TABLE]
    xor r13, r13

    ; Check to see if the passport passes part 1 first.
    mov [rbp + 16], rcx
    mov [rbp + 24], rdx
    call part1Validator
    mov rcx, [rbp + 16]
    mov rdx, [rbp + 24]
    test rax, rax
    jnz .passed
    xor rax, rax
    jmp .leave
.passed:

.loop:
    ; Add the first two chars of the name together, subtract 200, then multiply it by 8.
    xor r8, r8
    mov ax, [rcx]
    mov r8b, al
    shr ax, 8
    add r8w, ax
    sub r8w, 200
    shl r8w, 3

    ; Persist RCX and RDX
    mov [rbp + 16], rcx
    mov [rbp + 24], rdx

    ; Find the length of the entry's value.
    lea r9, [rcx + 3]
    xor rdx, rdx
.lengthLoop:
    ; You know, if I had any amount of foresight I would've tacked on the length into one of the entry's bytes during parsing,
    ; but I sort of neglected that I'd actually need the length, and I'm far too tired to have things break on me now by changing it.
    ;
    ; Sooooo we're doing a shitty strlen.
    ; Can't even use string opcodes since it'd clobber RCX, smh.
    inc rdx
    mov al, [r9]
    inc r9
    cmp al, 0
    jne .lengthLoop
.endLengthLoop:
    dec rdx ; Otherwise it includes the null terminator.

    ; Call the validator from the jump table.
    mov r8, [r12 + r8]
    add rcx, 3
    call r8
    mov rcx, [rbp + 16]
    mov rdx, [rbp + 24]

    ; Add bool value onto return result
    add r13, rax

    ; Advance pointer
    add rcx, passport_entry_size

    dec rdx
    jnz .loop
.endLoop:

    xor rax, rax
    cmp r13, 7
    jne .leave
    mov rax, 1

.leave:
    add rsp, 32
    pop r13
    pop r12
    leave
    ret

; Wow has it really been 5 hours?
; Time flies when you're intentionally melting your brain, I guess.
;
; ASM is actually really fun in the scope of small challenges like this. I'd never write anything proper in it though (outside of microcontrollers).

byrValidator:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    cmp rdx, 4
    jl .leaveFail

    call strToInt32
    cmp rax, 1920
    jl .leaveFail
    cmp rax, 2002
    jle .leaveSuccess

.leaveFail:
    xor rax, rax
    jmp .leave
.leaveSuccess:
    mov rax, 1
.leave:
    add rsp, 32
    leave
    ret

; Basically the function above, but with two values changed.
iyrValidator:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    cmp rdx, 4
    je .goodSize
    xor rax, rax
    jmp .leave
.goodSize:

    call strToInt32

    cmp rax, 2010
    jge .passCheck1
    xor rax, rax
    jmp .leave
.passCheck1:
    cmp rax, 2020
    jle .passCheck2
    xor rax, rax
    jmp .leave
.passCheck2:
    mov rax, 1

.leave:
    add rsp, 32
    leave
    ret

; Ditto
eyrValidator:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    cmp rdx, 4
    je .goodSize
    xor rax, rax
    jmp .leave
.goodSize:

    call strToInt32

    cmp rax, 2020
    jge .passCheck1
    xor rax, rax
    jmp .leave
.passCheck1:
    cmp rax, 2030
    jle .passCheck2
    xor rax, rax
    jmp .leave
.passCheck2:
    mov rax, 1

.leave:
    add rsp, 32
    leave
    ret

hgtValidator:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 32

    ; Keep a copy of the last char.
    mov r12b, [rcx + rdx - 1]

    ; So we can then clobber the registers when calling this func.
    sub rdx, 2 ; Ignore the "in"/"cm" suffix
    call strToInt32

    cmp r12b, 'n'
    je .inches
.cm:
    cmp rax, 120
    jl .leaveFail
    cmp rax, 193
    jg .leaveFail
    mov rax, 1
    jmp .leave
.inches:
    cmp rax, 59
    jl .leaveFail
    cmp rax, 76
    jg .leaveFail
    mov rax, 1
    jmp .leave
.leaveFail:
    xor rax, rax
.leave:
    add rsp, 32
    pop r12
    leave
    ret

hclValidator:
    cmp byte [rcx], '#'
    jne .leaveFail

    mov rax, [rcx + 1] ; Because I'm weird, let's do a single load and then just shift it.

; Easier than making a loop since it's a small fixed size.
; Too lazy to make a lookup table either.
%rep 6
    cmp al, '0'
    jl .leaveFail
    cmp al, '9'
    jle .leaveSuccess
    cmp al, 'a'
    jl .leaveFail
    cmp al, 'f'
    jle .leaveSuccess
    shr rax, 8
%endrep

.leaveSuccess:
    mov rax, 1
    jmp .leave
.leaveFail:
    xor rax, rax
.leave:
    ret

; cba(super tired) to figure out anything fancy now, so we'll just go for a lovely branching hellscape.
; I think you can see why I did the fancy things though.
eclValidator:
    mov rax, [rcx]

    cmp al, 'a'
    je .a
    cmp al, 'b'
    je .b
    cmp al, 'g'
    je .g
    cmp al, 'h'
    je .h
    cmp al, 'o'
    je .o
    jmp .leaveFail

.a:
    shr rax, 8
    cmp al, 'm'
    je .a_m
    jmp .leaveFail

.a_m:
    shr rax, 8
    cmp al, 'b'
    je .leaveSuccess
    jmp .leaveFail

.b:
    shr rax, 8
    cmp al, 'l'
    je .b_l
    cmp al, 'r'
    je .b_r
    jmp .leaveFail

.b_l:
    shr rax, 8
    cmp al, 'u'
    je .leaveSuccess
    jmp .leaveFail

.b_r:
    shr rax, 8
    cmp al, 'n'
    je .leaveSuccess
    jmp .leaveFail

.g:
    shr rax, 8
    cmp al, 'r'
    je .g_r
    jmp .leaveFail

.g_r:
    shr rax, 8
    cmp al, 'n'
    je .leaveSuccess
    cmp al, 'y'
    je .leaveSuccess
    jmp .leaveFail

.h:
    shr rax, 8
    cmp al, 'z'
    je .h_z
    jmp .leaveFail

.h_z:
    shr rax, 8
    cmp al, 'l'
    je .leaveSuccess
    jmp .leaveFail

.o:
    shr rax, 8
    cmp al, 't'
    je .o_t
    jmp .leaveFail

.o_t:
    shr rax, 8
    cmp al, 'h'
    je .leaveSuccess
    jmp .leaveFail
    
.leaveSuccess:
    mov rax, 1
    jmp .leave
.leaveFail:
    xor rax, rax
.leave:
    ret

pidValidator:
    cmp rdx, 9
    jne .fail
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

cidValidator:
    mov rax, 0
    ret

_trap:
    int3