SECTION .data
    TEST_STR: db "ptr %.*s", 0x0A, 0

    VALID_NO_CID: equ 'b' + 'y' + 'r' \
                    + 'i' + 'y' + 'r' \
                    + 'e' + 'y' + 'r' \
                    + 'h' + 'g' + 't' \
                    + 'h' + 'c' + 'l' \
                    + 'e' + 'c' + 'l' \
                    + 'p' + 'i' + 'd'

    VALID_WITH_CID: equ VALID_NO_CID + 'c' + 'i' + 'd'

SECTION .text

; Logic: Since the problem ensures that there are no duplicate entry names, and that
;        the only names found are valid ones, we can check if all the names in a passport
;        add up to one of two defined values (VALID_NO_CID and VALID_WITH_CID) as a relatively
;        efficient means of verifying them.
part1Validator:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Register usage:
    ;   RAX = Return value (bool), also some temp storage
    ;   RCX = Pointer to current passport_entry
    ;   RDX = Downards counter for how many entries are left
    ;   R8  = Accumulator for the verify calc
    ;   R9  = Temp storage for calcs
    xor r8, r8

.loop:
    ; Add the entry's name into the accumulator and advance the pointer.
    mov rax, [rcx]
    and rax, 0xFFFFFF ; Only keep the first 3 bytes.
    
    ; Add first byte
    mov r9, rax
    and r9, 0xFF
    add r8, r9

    ; Add second byte
    mov r9, rax
    shr r9, 8
    and r9, 0xFF
    add r8, r9

    ; Add final byte
    shr rax, 16
    add r8, rax
    
    add rcx, passport_entry_size

    dec rdx
    jnz .loop
.endLoop:

    mov rax, 1
    cmp r8, VALID_WITH_CID
    je .leave
    cmp r8, VALID_NO_CID
    je .leave
    xor rax, rax

.leave:
    leave
    ret

_test:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov r8, rcx
    lea rcx, [TEST_STR]
    call printf

    leave
    ret