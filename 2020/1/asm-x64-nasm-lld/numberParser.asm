; void ()	
sortNumbers:
    ; Yes, this is bubble sort... You can't blame me though! Sort of.
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    push rbx
    sub rsp, 0 + 0
    
    ; Register usage:
    ;	EAX - Temp
    ;	RSI - The pointer to the left-most value being compared
    ;   RDI - The pointer to the right-most value being compared
    ;	RBX - The amount of times we've iterated over the array (optimised bubble sort)
    ;   RCX - The iteration count for the inner loop.
    ;   R8  - Copy of g_numberBufferLen
    ;	R9 - Stores (r8 - rbx) calculations
    lea rsi, [g_numberBuffer]
    xor rbx, rbx,
    mov r8, [g_numberBufferLen]
    
    ; for(rbx = 0; rbx < r8; rbx++)
.loop:
    cmp rbx, r8
    jge .leave
    
    ; for(rcx = 1; rcx < r9; rcx++)
    mov rcx, 1
    lea rsi, [g_numberBuffer]
    mov rdi, rsi
    add rdi, 4
    mov r9, r8
    sub r9, rbx
    .innerLoop:
        cmp rcx, r9
        jge .endInnerLoop
        
        cmpsd
        jle .leftIsSmaller
            sub rdi, 4
            sub rsi, 4
            mov eax, [rdi]
            movsd
            mov [rsi-4], eax
        .leftIsSmaller:
        
        inc rcx
        jmp .innerLoop
    .endInnerLoop:
    
    inc rbx
    jmp .loop
    
.leave:
    add rsp, 0 + 0
    pop rbx
    pop rdi
    pop rsi
    leave
    ret
    
; void ()
parseNumbers:
    push rbp
    mov rbp, rsp
    ; Preserve non-volatile registers
    push rdi
    push rsi
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32 + 0 + 0
    
    ;int3
    
    ; Register usage:
    ;   RDI - Pointer into numberBuffer to store stuff.
    ;	RSI - The end index of a string slice.
    ;	R12	- The start index of a string slice.
    ;	R13 - Copy of g_inputLen
    ;	R14 - Copy of g_input
    ;	R15 - Amount of numbers found
    ;   RAX - Temp
    ;   RCX - Temp
    xor r12, r12
    xor r15, r15
    xor rsi, rsi
    lea rdi, [g_numberBuffer]
    mov r13, [g_inputLen]
    mov r14, [g_input]
    
    ; while(endIndex < g_inputLen)
.loop:
    cmp rsi, r13
    jge .endLoop
    
    ; Increment endIndex until we hit a new line character (or end of data)
    mov al, byte [r14 + rsi]
    inc rsi
    cmp al, 0x0A
    jne .loop

    inc r15
    
    ; Pass slice[startIndex..endIndex] into strToInt32, then set startIndex to endIndex
    lea rcx, [r14 + r12] ; &slice[startIndex]
    mov rdx, rsi
    sub rdx, r12 ; endIndex - startIndex
    dec rdx      ; Because it'll be including the \n otherwise
    call strToInt32
    mov r12, rsi
    
    ; Add the returned value into g_numberBuffer
    mov [rdi], rax
    add rdi, 4
    
    jmp .loop
.endLoop:
    
    ; Otherwise we miss the last one.
    inc r15
    lea rcx, [r14 + r12]
    mov rdx, rsi
    sub rdx, r12
    call strToInt32
    mov [rdi], rax
    
    mov [g_numberBufferLen], r15
    
.leave:
    add rsp, 32 + 0 + 0
    pop r15
    pop r14
    pop r13
    pop r12
    pop rsi
    pop rdi
    leave
    ret

; Assumes string is ASCII encoded and is already a valid number.
; int32 (char* str, size_t strLen)
strToInt32:
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