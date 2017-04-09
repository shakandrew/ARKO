;=====================================================================
;
; Autor: Andrei Shumak
; Data:  24.01.2017 03:05
;
;=====================================================================

;###################################################################;
; MACROS 															;
;###################################################################;
; Functions parameters stack addresses
%define IMAGE 	ebp+8
%define ZBUF 	ebp+12
%define XSIZE 	ebp+16
%define YSIZE 	ebp+20
%define VERT	ebp+24
%define RGB 	ebp+28
; Local variables stack addresses
%define	AX		ebp-4	 
%define	AY		ebp-8
%define	AZ		ebp-12
%define	BX		ebp-16	 
%define	BY		ebp-20
%define	BZ		ebp-24
%define	CX		ebp-28	 
%define	CY		ebp-32
%define	CZ		ebp-36
%define	ABX		ebp-40	 
%define	ABY		ebp-44
%define	ABZ		ebp-48
%define	BCX		ebp-52
%define	BCY		ebp-56
%define	BCZ		ebp-60
%define	ACX		ebp-64	 
%define	ACY		ebp-68
%define	ACZ		ebp-72

; Function call macro ==============================================
; With 1 parameter
%macro fcall 2			; %1 function name, %2 param
		push	%2
		call	%1
		add		esp, 4	; 1x4B params at stack
%endmacro
; With 2 parameters - 
%macro fcall 3			; %1 function name, %2-3 params
		push	%3		; pass params in reverse order
		push	%2
		call	%1
		add		esp, 8	; 2x4B params at stack
%endmacro
; With 4 parameters - 
%macro fcall 4			; %1 function name, %2-4 params
		push	%4		; pass params in reverse order
		push	%3
		push	%2
		call	%1
		add		esp, 12	; 3x4B params at stack
%endmacro
; With 5 parameters - 
%macro fcall 5			; %1 function name, %2-5 params
		push	%5		; pass params in reverse order
		push	%4
		push	%3
		push	%2
		call	%1
		add		esp, 16	; 4x4B params at stack
%endmacro
; With 6 parameters 
%macro fcall 6			; %1 function name, %2-6 params
		push	%6		; pass params in reverse order
		push	%5
		push	%4
		push	%3
		push	%2
		call	%1
		add		esp, 20	; 5x4B params at stack
%endmacro
; With 6 parameters 
%macro fcall 7			; %1 function name, %2-6 params
		push	%7		; pass params in reverse order
		push 	%6
		push	%5
		push	%4
		push	%3
		push	%2
		call	%1
		add		esp, 24	; 5x4B params at stack
%endmacro

; With 8 parameters 
%macro fcall 8			; %1 function name, %2-8 params
		push	%8		; pass params in reverse order
		push	%7
		push	%6
		push	%5
		push	%4
		push	%3
		push	%2
		call	%1
		add		esp, 28	; 7x4B params at stack
%endmacro
; ==================================================================
; Incoming ==============================================
; With 1 modified register.
%macro enter 2
		push 	ebp     	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, %2   	; Make room for local variables.
		push	%1			; Save registers that will be modified.
%endmacro
; With 2 modified registers.
%macro enter 3
		push 	ebp     	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, %3   	; Make room for local variables.
		push	%1			; Save registers that will be modified.
		push 	%2
%endmacro
; With 3 modified registers.
%macro enter 4
		push 	ebp  	  	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, %4   	; Make room for local variables.
		push	%1			; Save registers that will be modified.
		push 	%2
		push	%3
%endmacro
; With 4 modified registers.
%macro enter 5
		push 	ebp     	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, %5   	; Make room for local variables.
		push	%1			; Save registers that will be modified.
		push	%2
		push	%3
		push	%4
%endmacro
; With 5 modified registers.
%macro enter 6
		push 	ebp     	; Save the old base pointer value.
		mov 	ebp, esp 	; Set the new base pointer value.
		sub 	esp, %6   	; Make room for local variables.
		push	%1			; Save registers that will be modified.
		push	%2
		push	%3
		push	%4
		push	%5
%endmacro

; ===================================================================
; Outcoming ===============================================
; With 1 modified register.
%macro leave 1
		pop 	%1			; Recover calle-saved register values.
		mov 	esp, ebp 	; Deallocate local variables.
		pop 	ebp 		; Restore the caller's base pointer value.
		ret
%endmacro
; With 2 modified registers.
%macro leave 2
		pop 	%2			; Recover calle-saved register values.
		pop		%1			
		mov 	esp, ebp 	; Deallocate local variables.
		pop 	ebp 		; Restore the caller's base pointer value.
		ret
%endmacro
; With 3 modified registers.
%macro leave 3
		pop 	%3			; Recover calle-saved register values.
		pop		%2
		pop		%1			
		mov 	esp, ebp 	; Deallocate local variables.
		pop 	ebp 		; Restore the caller's base pointer value.
		ret
%endmacro
; With 4 modified registers.
%macro leave 4
		pop 	%4			; Recover calle-saved register values.
		pop		%3
		pop		%2
		pop		%1			
		mov 	esp, ebp 	; Deallocate local variables.
		pop 	ebp 		; Restore the caller's base pointer value.
		ret
%endmacro
; With 4 modified registers.
%macro leave 5
		pop 	%5			; Recover calle-saved register values.
		pop		%4
		pop		%3
		pop		%2
		pop		%1			
		mov 	esp, ebp 	; Deallocate local variables.
		pop 	ebp 		; Restore the caller's base pointer value.
		ret
%endmacro
; ===================================================================

;section .data

section	.text
global  drawTriangle


;###################################################################;
; MAIN																;
;###################################################################;

drawTriangle:
		enter	ebx, ecx, esi, edi, 72	; Incoming

		; Save vertices to stack
		; A.X/Y/Z to stack
		mov		eax, [VERT]			; *A.X to eax
		mov 	ebx, [eax]		    ; A.X to ebx
		mov		[AX], ebx			; A.X to stack
		mov 	ebx, [eax+4]		; A.Y to ebx
		mov		[AY], ebx			; A.Y to stack
		mov 	ebx, [eax+8]		; A.Z to ebx
		mov		[AZ], ebx			; A.Z to stack	
		; B.X/Y/Z to stack
		mov		eax, [VERT]			; *B.X to eax
		mov 	ebx, [eax+12]		    ; B.X to ebx
		mov		[BX], ebx			; B.X to stack
		mov 	ebx, [eax+16]		; B.Y to ebx
		mov		[BY], ebx			; B.Y to stack
		mov 	ebx, [eax+20]		; B.Z to ebx
		mov		[BZ], ebx			; B.Z to stack
		; C.X/Y/Z to stack
		mov		eax, [VERT]			; *C.X to eax
		mov 	ebx, [eax+24]		    ; C.X to ebx
		mov		[CX], ebx			; C.X to stack
		mov 	ebx, [eax+28]		; C.Y to ebx
		mov		[CY], ebx			; C.Y to stack
		mov 	ebx, [eax+32]		; C.Z to ebx
		mov		[CZ], ebx			; C.Z to stack
		; ===========================================================
		
		; Sort vertices by Y.
		lea		eax, [AX]
		lea		ebx, [BX]
		lea		ecx, [CX]
		fcall	sort, eax, ebx, ecx
		
		; Set start drawing points
		; AB = A, AC = A, BC = B
		lea		eax, [ABX]
		lea		ebx, [AX]
		fcall	vassign, eax, ebx	; AB = A
		lea		eax, [ACX]
		lea		ebx, [AX]
		fcall	vassign, eax, ebx	; AC = A
		lea		eax, [BCX]
		lea		ebx, [BX]
		fcall	vassign, eax, ebx	; BC = B
		
		; Firstly draw lines between AB and AC sides of triangle.	
		
		; If A.Y != B.Y - fill triangle from A to B
		mov		eax, [AY]
		mov 	ebx, [BY]
		cmp		eax, ebx
		jne		AB_AC
		; Else draw horizontal line A-B and proceed to BC_AC
		lea		eax, [AX]
		lea		ebx, [BX]
		fcall	horizline, DWORD[IMAGE], DWORD[XSIZE], eax, ebx, DWORD[ZBUF], DWORD[RGB]
		jmp		AB_AC_end
		
AB_AC:		
		; Interpolate RGB values of AB.
		; AB.x = B.x * (AB.y-A.y)/(B.y-A.y) + A.x * (B.y-AB.y)/(B.y-A.y);
		fcall 	interpolate, DWORD[AX], DWORD[BX], DWORD[ABY], DWORD[AY], DWORD[BY]
		mov		[ABX], eax		; AB.X = X
		; AB.z = B.z * (AB.y-A.y)/(B.y-A.y) + A.z * (B.y-AB.y)/(B.y-A.y);	
		fcall 	interpolate, DWORD[AZ], DWORD[BZ], DWORD[ABY], DWORD[AY], DWORD[BY]
		mov		[ABZ], eax		; AB.Z = Z and save to zbuf
		; Interpolate RGB values of AC.
		; AC.x = C.x * (AC.y-A.y)/(C.y-A.y) + A.x * (C.y-AC.y)/(C.y-A.y);
		fcall 	interpolate, DWORD[AX], DWORD[CX], DWORD[ACY], DWORD[AY], DWORD[CY]
		mov		[ACX], eax		; AC.X = X
		; AC.z = C.z * (AC.y-A.y)/(C.y-A.y) + A.z * (C.y-AC.y)/(C.y-A.y);
		fcall 	interpolate, DWORD[AZ], DWORD[CZ], DWORD[ACY], DWORD[AY], DWORD[CY]
		mov		[ACZ], eax		; AC.Z = Z and save to zbuf
		; Draw horizline between AB and AC.
		lea		eax, [ABX]
		lea		ebx, [ACX]
		fcall 	horizline, DWORD[IMAGE], DWORD[XSIZE], eax, ebx, DWORD[ZBUF], DWORD[RGB]	

		; Increment AB.Y
		inc		DWORD [ABY]			; AB.Y++
		inc		DWORD [ACY]			; AC.Y++
		; If AB.Y >= B.Y - proceed to BC_AC
		mov		eax, [ABY]			; eax = AB.Y
		mov		ebx, [BY]			; ebx = B.Y
		cmp		eax, ebx
		jge		AB_AC_end
		; Else - continue AB_AC loop
		jmp AB_AC
		
AB_AC_end:		

		; Then secondly draw lines between BC and AC sides of triangle.		
		
		; If B.Y != C.Y - fill triangle from B to C
		mov		eax, [BY]
		mov 	ebx, [CY]
		cmp		eax, ebx
		jne		BC_AC
		; Else draw horizontal line B-C and end filling
		lea		eax, [BX]
		lea		ebx, [CX]
		fcall	horizline, DWORD[IMAGE], DWORD[XSIZE], eax, ebx, DWORD[ZBUF], DWORD[RGB]
		jmp		BC_AC_end
		
BC_AC:		
		; Interpolate RGB values of BC.
		; BC.x = C.x * (BC.y-B.y)/(C.y-B.y) + B.x * (C.y-BC.y)/(C.y-B.y);	
		fcall 	interpolate, DWORD[BX], DWORD[CX], DWORD[BCY], DWORD[BY], DWORD[CY]
		mov		[BCX], eax		; BC.X = X
		; BC.z = C.z * (BC.y-B.y)/(C.y-B.y) + B.z * (C.y-BC.y)/(C.y-B.y);	
		fcall 	interpolate, DWORD[BZ], DWORD[CZ], DWORD[BCY], DWORD[BY], DWORD[CY]
		mov		[BCZ], eax		; BC.Z = Z and save to zbuf
		; Interpolate RGB values of AC.
		; AC.x = C.x * (AC.y-A.y)/(C.y-A.y) + A.x * (C.y-AC.y)/(C.y-A.y);
		fcall 	interpolate, DWORD[AX], DWORD[CX], DWORD[ACY], DWORD[AY], DWORD[CY]
		mov		[ACX], eax		; AC.X = X
		; AC.z = C.z * (AC.y-A.y)/(C.y-A.y) + A.z * (C.y-AC.y)/(C.y-A.y);
		fcall 	interpolate, DWORD[AZ], DWORD[CZ], DWORD[ACY], DWORD[AY], DWORD[CY]
		mov		[ACZ], eax		; AC.Z = Z and save to zbuf
		; Draw horizline between BC and AC.
		lea		eax, [BCX]
		lea		ebx, [ACX]
		fcall 	horizline, DWORD[IMAGE], DWORD[XSIZE], eax, ebx, DWORD[ZBUF], DWORD[RGB]
		
		; Increment BC.Y
		inc		DWORD [BCY]			; BC.Y++
		inc		DWORD [ACY]			; AC.Y++
		; If AB.Y >= B.Y - proceed to BC_AC
		mov		eax, [BCY]			; eax = BC.Y
		mov		ebx, [CY]			; ebx = B.Y
		cmp		eax, ebx
		jge		BC_AC_end
		; Else - continue AB_AC loop
		jmp 	BC_AC
		
BC_AC_end:

end:
		leave	ebx, ecx, esi, edi	; Outcoming
		
;###################################################################;
; FUNCTIONS															;
;###################################################################;

; Draw horizontal line between P1 and P2 ============================
; Params: *image(ebp+8), xsize(+12), *P1.X(+16), *P2.X(+20), *zbuf(ebp+24), *RGB(ebp+28)
; Locals: P1'(ebp-4), P2'(ebp-28), CURR(ebp-52)
horizline:
		enter	ebx, 40		; Incoming, 40B of local variables

		; Copy P1 to P1'
		lea		eax, [ebp-4]		; eax = *P1'.X
		mov		ebx, [ebp+16]		; ebx = *P1.X
		fcall	vassign, eax, ebx	; P1' = P1
		
		; Copy P2 to P2'
		lea		eax, [ebp-16]		; eax = *P2'.X
		mov		ebx, [ebp+20]		; ebx = *P2.X
		fcall	vassign, eax, ebx	; P2' = P2
		
		; If P1.X <= P2.X - don't swap
		mov		eax, [ebp-4]		; eax = P1'.X
		mov		ebx, [ebp-16]		; ebx = P2'.X
		cmp		eax, ebx
		jle		horizline_noswap		
		; Else swap		
		lea		eax, [ebp-4]		; eax = *P1'.X
		lea		ebx, [ebp-16]		; ebx = *P2'.X
		fcall	vswap, eax, ebx
		
horizline_noswap:				
		; Copy P1' to CURR
		lea		eax, [ebp-28]		; eax = *CURR.X
		lea		ebx, [ebp-4]		; ebx = *P1'.X
		fcall	vassign, eax, ebx	; CURR = P1'
		
		; If P1.X != P2.X - draw horizline
		mov		eax, [ebp-4]		; eax = P1'.X
		mov		ebx, [ebp-16]		; ebx = P2'.X
		cmp		eax, ebx
		jne		horizline_loop
		; Else don't draw - end of horizline		
		leave	ebx			; Outcoming		
		
horizline_loop:		
		; Interpolate ZRGB values.
		; CURR.z = P2.z * (CURR.x-P1.x)/(P2.x-P1.x) + P1.z * (P2.x-CURR.x)/(P2.x-P1.x);
		fcall 	interpolate, DWORD[ebp-12], DWORD[ebp-24], DWORD[ebp-28], DWORD[ebp-4], DWORD[ebp-16]	
		mov		[ebp-36], eax		; CURR.Z = Z		
		; Set the pixel in the image buffer if it's at Z top.
		; If CURR.Z > zbuffer(X, Y) -> don't draw the pixel
		lea		eax, [ebp-28]
		fcall	getZbuf, DWORD[ebp+24], DWORD[ebp+12], eax	; eax = zbuffer(X, Y)
		mov		ebx, [ebp-36]		; ebx = CURR.Z
		cmp		ebx, eax
		ja		horizline_nodraw	; Jump if Above - for unsigned
		; Else draw the pixel in the image buffer
		lea		eax, [ebp-28]
		fcall 	drawPixel, DWORD[ebp+8], DWORD[ebp+12], eax, DWORD[ebp+28]
		lea		eax, [ebp-28]
		fcall	setZbuf, DWORD[ebp+24], DWORD[ebp+12], eax
horizline_nodraw:

		; Increment CURR.X
		inc		DWORD [ebp-28]			; CURR.X++
		; If CURR.X > P2.X - end of loop
		mov		eax, [ebp-28]		; eax = CURR.X
		mov		ebx, [ebp-16]		; ebx = P2'.X
		cmp		eax, ebx
		jge		horizline_end
		; Else - continue loop
		jmp 	horizline_loop
						
horizline_end:
		leave	ebx			; Outcoming
; ===================================================================		
		
; Draw pixel ========================================================
; Params: *image(ebp+8), xsize(+12), *P.X(+16), *RGB(+20)
drawPixel:
		enter	ebx, ecx, 0			; Incoming
		
		; Pixel offset: (xsize*Y + X) * 3 --> 3B per pixel
		mov		ecx, [ebp+16]		; ecx = *P
		mov		eax, [ebp+12]		; eax = xsize
		mul		DWORD[ecx-4]		; eax = xsize * Y
		add		eax, [ecx]			; eax = (xsize*Y + X)
		imul	eax, 3				; eax = (xsize*Y + X) * 3
		
		mov 	ecx, [ebp+20]		; ecx = RGB[0] 
		add		eax, [ebp+8]		; eax = *image + offset <-- pix address
		mov		ebx, [ecx+12]		; ebx = B
		mov		[eax], ebx			; save B
		mov		ebx, [ecx+8]		; ebx = G
		mov		[eax+1], ebx		; save G
		mov		ebx, [ecx+4]		; ebx = R
		mov		[eax+2], ebx		; save R
				
		leave	ebx, ecx			; Outcoming
; ===================================================================

; Get zbuffer =======================================================
; Params: *zbuf(ebp+8), xsize(+12), *P.X(+16)
getZbuf:
		enter	ebx, 0				; Incoming
		
		; Pixel offset: (xsize*Y + X) * 4 --> 4B per pixel
		mov		ebx, [ebp+16]		; ebx = *P
		mov		eax, [ebp+12]		; eax = xsize
		mul		DWORD[ebx-4]		; eax = xsize * Y
		add		eax, [ebx]			; eax = (xsize*Y + X)
		imul	eax, 4				; eax = (xsize*Y + X) * 4
		
		add		eax, [ebp+8]		; eax = *image + offset <-- pix address
		mov		eax, [eax]			; ebx = zbuffer(X, Y)
				
		leave	ebx					; Outcoming
; ===================================================================

; Set zbuffer =======================================================
; Params: *zbuf(ebp+8), xsize(+12), *P.X(+16)
setZbuf:
		enter	ebx, ecx, 0				; Incoming
		
		; Pixel offset: (xsize*Y + X) * 4 --> 4B per pixel
		mov		ebx, [ebp+16]		; ebx = *P
		mov		eax, [ebp+12]		; eax = xsize
		mul		DWORD[ebx-4]		; eax = xsize * Y
		add		eax, [ebx]			; eax = (xsize*Y + X)
		imul	eax, 4				; eax = (xsize*Y + X) * 4
		
		add		eax, [ebp+8]		; eax = *image + offset <-- pix address
		mov		ecx, [ebx-8]		; ecx = P.Z
		mov		[eax], ecx		
				
		leave	ebx, ecx			; Outcoming
; ===================================================================

; Calculate interpolation ===========================================
; P.a = P2.a * (P.b-P1.b)/(P2.b-P1.b) + P1.a * (P2.b-P.b)/(P2.b-P1.b);
; Params: P1.a(ebp+8), P2.a(+12), P.b(+16), P1.b(+20), P2.b(+24)
interpolate:
		enter	ebx, ecx, edx, esi, edi, 20	; Incoming
		
		mov		eax, [ebp+12]			; eax = P2.a
		mov		ebx, [ebp+16]			; ebx = P.b
		sub		ebx, [ebp+20]			; ebx = P.b-P1.b
		mov		ecx, [ebp+24]			; ecx = P2.b
		sub		ecx, [ebp+20]			; ecx = P2.b-P1.b
		mov		edx, 0					; clean 63-32 bits of multiplication
		mul		ebx						; eax = eax*ebx = P2.a * (P.b-P1.b); res=edx:eax
		div		ecx						; eax = edx:eax / ecx = P2.a * (P.b-P1.b)/(P2.b-P1.b)
		
		mov		edi, eax				; copy of result
		
		mov		eax, [ebp+8]			; eax = P1.a
		mov 	esi, [ebp+24]			; esi = P2.b
		sub		esi, [ebp+16]			; esi = P2.b-P.b
		mov		edx, 0					; clean 63-32 bits of multiplication
		mul		esi						; eax = eax*esi = P1.a * (P2.b-P.b); res = edx:eax
		div		ecx						; eax = edx:eax / ecx = P1.a * (P2.b-P.b)/(P2.b-P1.b)
		
		add		eax, edi				; eax = P2.a * (P.b-P1.b)/(P2.b-P1.b) + P1.a * (P2.b-P.b)/(P2.b-P1.b)		
		
		leave	ebx, ecx, edx, esi, edi	; Outcoming
; ====================================================================

; Sort vertices by Y =================================================
; Params: *A.X(ebp+8), *B.X(+12), *C.X(+16)
sort:
		enter	ebx, esi, edi, 0	; Incoming
		
		; 1) A<->B
		; Load vertices to registers.
		mov		eax, [ebp+8]		; eax = *A.X
		mov		ebx, [ebp+12]		; ebx = *B.X		
		mov		esi, [eax-4]		; eax = A.Y
		mov 	edi, [ebx-4]		; ebx = B.Y
		; If eax <= ebx -> jump to next comparizon
		cmp		esi, edi			
		jle		sortAC			
		; Else call vswap function
		fcall	vswap, eax, ebx
		
sortAC:	; 2) A<->C
		; Load vertices to registers.
		mov		eax, [ebp+8]		; eax = *A.X
		mov		ebx, [ebp+16]		; ebx = *C.X		
		mov		esi, [eax-4]		; eax = A.Y
		mov 	edi, [ebx-4]		; ebx = C.Y
		; If eax <= ebx -> jump to next comparizon
		cmp		esi, edi			
		jle		sortBC			
		; Else call vswap function
		fcall	vswap, eax, ebx
		
sortBC:	; 3) B<->C
		; Load vertices to registers.
		mov		eax, [ebp+12]		; eax = *B.X
		mov		ebx, [ebp+16]		; ebx = *C.X		
		mov		esi, [eax-4]		; eax = B.Y
		mov 	edi, [ebx-4]		; ebx = C.Y
		; If eax <= ebx -> next of sort
		cmp		esi, edi			
		jle		sort_end		
		; Else call vswap function
		fcall	vswap, eax, ebx

sort_end:		
		leave	ebx, esi, edi		; Outcoming
; ====================================================================

; Swap vertices ======================================================
; Params: *P1.X, *P2.X
vswap:
		enter	ebx, esi, edi, 0	; Incoming
		mov		esi, [ebp+8]		; load *V1.X
		mov		edi, [ebp+12]		; load *V2.X
		
		mov 	eax, [esi]		; swap every 4 bytes
		mov 	ebx, [edi]
		mov 	[edi], eax
		mov 	[esi], ebx
		
		mov 	eax, [esi-4]
		mov 	ebx, [edi-4]
		mov 	[edi-4], eax
		mov 	[esi-4], ebx
		
		mov 	eax, [esi-8]
		mov 	ebx, [edi-8]
		mov 	[edi-8], eax
		mov 	[esi-8], ebx
		
		leave	ebx, esi, edi		; Outcoming
;=====================================================================

; Assign vertices (P1 = P2) ==========================================
; Params: *P1.X, *P2.X
vassign:
		enter	esi, edi, 0			; Incoming
		mov		esi, [ebp+8]		; load *P1.X
		mov		edi, [ebp+12]		; load *P2.X
		
		mov 	eax, [edi]			; assign every 4 bytes
		mov 	[esi], eax		
		mov 	eax, [edi-4]
		mov 	[esi-4], eax		
		mov 	eax, [edi-8]
		mov 	[esi-8], eax
		
		leave	esi, edi			; Outcoming
;=====================================================================

