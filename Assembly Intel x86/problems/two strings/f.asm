section .text
global f

f:

	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	push esi
	push edi

	mov eax, [ebp+12]
	mov esi, 0	;mask is stored there
mask_begin:
	mov ch, [eax]
	test ch, ch
	jz mask_end
	
	mov ebx, 1
	mov cl, ch
	sub cl,'a'
	shl ebx, cl
	or esi, ebx
	
	inc eax
	jmp mask_begin
mask_end:

	mov eax, [ebp+8]
	mov edi, [ebp+8]
algo_begin:
	mov ch, [eax]
	test ch,ch
	jz algo_end
	
	mov ebx, 1
	mov cl, ch
	sub cl,'a'
	shl ebx, cl
	and ebx, esi; ebx - are there any coincidences 
	
	inc eax
	cmp ebx, 0
	jnz algo_begin
	
	mov [edi], ch
	inc edi 
	jmp algo_begin
	
algo_end:
	
	mov byte [edi], 0

	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
ret

