SECTION .bss
    MAX_PASSPORTS: equ 1000
    MAX_ENTRIES:   equ 10_000

    g_entries:       resb passport_entry_size * MAX_ENTRIES
    g_passports:     resb passport_size * MAX_PASSPORTS
    g_passportCount: resq 0

SECTION .data
    struc passport_entry
        name:  resb 3
        value: resb 29
    endstruc

    struc passport
        entry_start: resw 1
        entry_count: resw 1
    endstruc

SECTION .text

; No error checking because fuck that.
; void ()
parsePassports:
    push rbp
    mov rbp, rsp

    push rsi
    push rdi

    ; Register usage:
    ;   RAX = Varies
    ;   RCX = Used as a counter for how many characters have been written into an entry's value array.
    ;   RDX = Varies
    ;   R8  = Pointer into g_passports
    ;   R9  = Counter of how many passports we've made
    ;   RSI = Pointer into g_input.
    ;   RDI = Pointer into g_entries.
    ; Shadow space usage:
    ;   rbp+16...rbp+20 = current_passport
    ;       rbp+16...rbp+18 = current_passport.entry_start
    ;       rbp+18...rbp+20 = current_passport.entry_count
    ;   rbp+20..rbp+22 = entry_count_so_far
    mov rsi, [g_input]
    lea rdi, [g_entries]
    lea r8, [g_passports]
    xor r9, r9
    xor rcx, rcx

    mov qword [rbp + 16], 0 ; Zero-out current_passport and entry_count_so_far variables.

.readEntryLoop:
    inc word [rbp + 18] ; inc current_passport.entry_count
    add rdi, rcx ; Pad the previous value with zeros.
    

    ; Read name (always 3 chars)
    movsb
    movsb
    movsb

    ; Skip past the ':'
    inc rsi

    ; Keep track of how many characters we've written, as we'll need to pad the rest of the space in zeros.
    mov rcx, 29

    ; Read until space, new line, or null terminator
    ; Register usage:
    ;   RAX = Stores the result of lodsb
.readValueLoop:
    lodsb

    ; If we hit a space, just read the next entry.
    ; If we hit a new line, check if the next line is blank:
    ;   If it is then push the current passport and init a new one.
    ;   Otherwise just parse the next entry.
    ; If we hit a null terminator then stop.
    ; Otherwise, we're still reading the value, so continue.

    cmp al, ' '
    je .readEntryLoop
    cmp al, 0x0A
    je .checkIfNextLineIsBlank
    cmp al, 0
    je .lineIsBlank ; lineIsBlank will then do another conidition check and cancel the loop.
    
    dec rcx
    stosb
    jmp .readValueLoop
.endReadValueLoop:
    ; NOTE: We're one character past the delimeter now.

.checkIfNextLineIsBlank:
    lodsb
    cmp al, 0x0A
    je .lineIsBlank
    dec rsi
    jmp .readEntryLoop

    ; Register usage:
    ;   rdx = Temp copy of data
.lineIsBlank:
    inc r9
    mov dword edx, [rbp+16]
    mov dword [r8], edx
    add r8, passport_size

    ; current_passport.entry_start += current_passport.entry_count
    ; current_passport.entry_count = 0
    shr edx, 16 ; entry_count is in the 16..32 bit range.
    add word [rbp+16], dx
    mov word [rbp+18], 0

    cmp al, 0
    jne .readEntryLoop
.endReadEntryLoop:

    mov [g_passportCount], r9

.leave:
    pop rdi
    pop rsi
    leave
    ret