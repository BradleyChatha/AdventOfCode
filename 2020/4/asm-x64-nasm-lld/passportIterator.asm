SECTION .text

; size_t (bool function(passport_entry* entries, size_t entryCount) isValid)
iteratePassports:
    push rbp
    mov rbp, rsp
    push rsi
    push r12
    push r13
    push r14
    push rbx
    sub rsp, 32
    ;int3

    ; Register usage:
    ;   RAX = Latest passport.
    ;   RBX = Counter of valid passports.
    ;   RCX = Param
    ;   RDX = Param
    ;   R12 = 'entries'
    ;   R13 = Copy of g_passportCount. Used as a counter.
    ;   R14 = Copy of isValid parameter.
    ;   RSI = Pointer into g_passports
    lea r12, [g_entries]
    mov r13, [g_passportCount]
    mov r14, rcx
    lea rsi, [g_passports]
    xor rax, rax
    xor rbx, rbx

.loop:
    ; Get the start address for the first entry
    lodsw
    shl rax, 5 ; * 32, sizeof(passport_entry)
    add rax, r12
    mov rcx, rax

    ; Get the entry count
    xor rax, rax
    lodsw
    mov rdx, rax

    call r14
    add rbx, rax ; Function returns a bool, which I define as 1 or 0
    
    dec r13
    jnz .loop
.loopEnd:
    
    mov rax, rbx
    add rsp, 32
    pop rbx
    pop r14
    pop r13
    pop r12
    pop rsi
    leave
    ret