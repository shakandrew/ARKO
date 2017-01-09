section .data
	var DB 'a'
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

	mov eax, [ebp+12]
	mov esi, 0	;mask is stored there
mask_begin:
	mov dh, [eax]
	test dh, dh
	jz mask_end
	
	call bit_mask

	or esi, ebx
	
	inc eax
	jmp mask_begin
mask_end:

	mov eax, [ebp+8]
	mov ch, 0
algo_begin:

	mov dh, [eax]
	test dh, dh
	jz algo_end
	
	call bit_mask

	and ebx, esi
	
	test ebx, 0
	jnz next
		mov eax, 0
	next:
	inc ch
	jmp algo_begin
algo_end:
	
	mov eax, [ebp+8]
	mov edx, [ebp+8]
	mov cl, ch
zero_del_begin:
	test cl,cl
	jz zero_del_end
	
	mov ch, [eax]
	test ch,ch

	jz no_change
		mov eax, 0
		mov [edx], ch 	
		inc edx
	no_change:
	
	inc eax
	dec cl
zero_del_end:
	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
ret

bit_mask:
	mov ebx, 1
	mov dl, dh
	sub dl,[var]
	inc dl
	mov cl, dl
	shl ebx, cl
	ret

