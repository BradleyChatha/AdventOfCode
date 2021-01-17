SECTION .text

; int ()
part1:
	push rbp
	mov rbp, rsp
	sub rsp, 32 + 0 + 0
	
	; Register usage:
	;   RAX = Current number
	;   RCX = Temp calcs
	;	R8  = Copy of g_numberBufferLen, serves as the loop counter
	;   RSI = Pointer into g_numberBuffer
	mov r8, [g_numberBufferLen]
	lea rsi, [g_numberBuffer]
	xor rcx, rcx
	
.loop:
	test r8, r8
	jz .leave
	
	lodsd
	mov rcx, 2020
	sub rcx, rax ; If this number exists in our list, then we've found the pair we want
	
	push rax
	push rcx
	call search
	mov rdx, rax
	pop rcx
	pop rax
	
	test rdx, rdx
	jnz .found

	dec r8
	jmp .loop

.found:
	mul rcx
	
.leave:	
	leave
	ret