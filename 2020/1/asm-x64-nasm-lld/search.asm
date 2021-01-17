SECTION .text

; I absolutely cannot be fucked with making (and mostly debugging) binary search at this point, so it'll be a linear search unless I want to revisit it in the future.

; bool (int value)
search:
	push rbp
	mov rbp, rsp
	sub rsp, 0 + 0 + 0
	
	; Register usage:
	;	RDI - Normal usage for SCASD
	;   ECX - Normal usage for REPNE, copy of g_numberBufferLen
	;   EAX - Normal usage for SCASD, `value parameter`
	lea rdi, [g_numberBuffer]
	mov eax, ecx
	mov ecx, [g_numberBufferLen]
	
	repne scasd
	
	je .found
	xor rax, rax
	jmp .leave
.found:
	mov rax, 1
	
.leave:	
	leave
	ret