SECTION .text

; Assumes string is ASCII encoded and is already a valid number.
; int32 (char* str, size_t strLen)
strToInt32:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    push rbp
    mov rbp, rsp
    sub rsp, 0 + 0
    
    ;int3
    
    ; Register usage:
    ;	RAX = Temp. MUL forces usage of RAX so result doesn't stay here.
    ;	R8  = Current character
    ;   R9 = Tens component
    ;	R10 = Index into str
    ;	R11 = Result
    xor rax, rax
    xor r8, r8
    xor r11, r11
    mov r9, 10
    mov r10, rdx
    
    test rcx, rcx ; Null check
    jz .leave
    
    test rdx, rdx ; Make sure we're not working on an empty string
    jz .leave
    
    dec r10 ; Convert length into index - We're working in reverse because that's how numbers work.
    
    ; First digit has slightly different logic, so to save a needless branch I'll just unroll the logic for it here.
    mov r8b, byte [rcx + r10]
    sub r8b, '0'
    add r11, r8
    mov rax, r11 ; Just in case we return
    dec r10
    
    cmp r10, 0
    jl .leave
    
    ; for(int64 r10 = strLen - 2; strLen >= 0; strLen--)
.loop:
    ; total += curr_digit * tens_component
    mov r8b, byte [rcx + r10]
    sub r8b, '0'
    mov rax, r9
    mul r8
    add r11, rax
    
    ; Multiply our tens component by 10, e.g. 10 -> 100 -> 1000
    mov rax, r9
    mov rdx, 10
    mul rdx
    mov r9, rax
    
    dec r10
    cmp r10, 0
    jge .loop
    
    ; return total
    mov rax, r11
    
.leave:
    leave
    ret