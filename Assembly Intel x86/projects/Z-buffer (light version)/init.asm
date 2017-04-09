;=====================================================================
;
; Autor: Andrei Shumak
; Data:  24.01.2017 03:05
;
;=====================================================================
%define IMAGE 	ebp+8
%define ZBUF 	ebp+12
%define XSIZE 	ebp+16
%define YSIZE 	ebp+20
%define RGB 	ebp+24
%define R 		4
%define G		8
%define B		12

;section .data

section	.text
global  initBuffers

initBuffers:
		; Incoming ========================================
		push 	ebp     	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, 12   	; Make room for 3x4B local variables
		push 	edi     	; Save the values of registers that the function
		push 	esi     	; will modify. This function uses EDI and ESI.
		push 	ebx
		push	ecx
		; ============================================================

		; Save R, G, B to stack
		mov		eax, [RGB]			; address *rgb to eax
		mov 	ebx, [eax]			; R to ebx
		mov		[ebp-R], ebx		; R to stack
		mov 	ebx, [eax+4]		; G to ebx
		mov		[ebp-G], ebx		; G to stack
		mov 	ebx, [eax+8]		; B to ebx
		mov		[ebp-B], ebx		; B to stack
		
		
		; Set iterators.
		mov		esi, 0				; y iterator
yloop:	
		mov 	edi, 0				; x iterator
xloop:
		; Save RGB values.
		mov 	eax, [IMAGE]
		mov 	bx, [ebp-B]		; R to ebx
		mov		[eax], bx		; R to image
		mov 	bx, [ebp-G]		; G to ebx
		mov		[eax+1], bx		; G to image
		mov 	bx, [ebp-R]		; B to ebx
		mov		[eax+2], bx		; B to image
		add     DWORD [IMAGE], 3; next byte
		; Set z-bufor to INF
		mov 	eax, [ZBUF]
		mov 	DWORD [eax], 0xFFFFFFFF
		add		DWORD [ZBUF], 4	; next word
;xloop	; If edi < xsize -> continue
		inc		edi					; edi++ - increment iterator
		cmp		edi, [XSIZE]
		jl		xloop
;yloop	; If esi < ysize -> continue
		inc		esi					; esi++ - increment iterator
		cmp		esi, [YSIZE]
		jl		yloop
		
		
	
end:
		; Outcoming =====================================
		pop 	ecx			; recover calle-saved register values
		pop		ebx
		pop 	esi      	
		pop 	edi
		mov 	esp, ebp 	; Deallocate local variables
		pop 	ebp 		; Restore the caller's base pointer value
		ret
		; =========================================================

