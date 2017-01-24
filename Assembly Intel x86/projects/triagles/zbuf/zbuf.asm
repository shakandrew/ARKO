###################################
# autor: Aleksander Szulc
# ARKO - projekt MIPS, zadanie 3.3 Z-bufor
###################################


################################################################
# Global defines								#
################################################################	
.eqv READ	0
.eqv WRITE	1
.eqv WIDTH	320
.eqv HEIGHT	240
.eqv FSIZE	230454	# bitmap+54B of header
.eqv HEADER	54	# header size
.eqv SIZE	230400	# WIDTH * HEIGHT * 3B - size of bmp
.eqv ZBUF_SIZE	307200 	# WIDTH * HEIGHT * 4B - size of zbufor
.eqv X_OFFSET	0
.eqv Y_OFFSET 	4
.eqv Z_OFFSET 	8
.eqv R_OFFSET	12
.eqv G_OFFSET	13
.eqv B_OFFSET	14

################################################################
# Data									#
################################################################
.data
# BitmapFileHeader - 14 bytes
		.align 0	# I absolutely don't understand this bloody padding... Why does 0(byte) work instead of 1(half)?...
bitmap:		.byte 'B'	# bfType1
		.byte 'M'	# bfType2
		.word FSIZE	# bfSize
		.word 0 	# bfReserved
		.word 54	# bfOffBits
# BitmapInfoHeader
		.word 40	# biSize
		.word WIDTH	# biWidth
		.word HEIGHT	# biHeight
		.half 1		# biPlanes
		.half 24	# biBitCount
		.word 0		# biCompression
		.word 0		# biSizeImage
		.word 0		# biXPelsPerMeter
		.word 0		# biYPelsPerMeter
		.word 0		# biClrUsed
		.word 0		# biClrImportant
# Bitmap (BGR)
bitmap_data:	.space SIZE
bitmap_end:	.byte 0
zbuf_bmp:	.space SIZE
zbuf_bmp_end:	.byte 0
#
opis:		.asciiz "opis.txt"
scena:		.asciiz "scena.bmp"
zbufor:		.asciiz "zbufor.bmp"
		.align 2
opis_des:		.word 
scena_des: 	.word
zbufor_des:	.word 
err_msg: 	.asciiz "\nError"
err_EOF:		.asciiz "\nError: reached end of file"
err_read:		.asciiz "\nError: reading from file"
err_write:		.asciiz "\nError: writing to file"
err_file:		.asciiz "\nError: opening file"
err_number:	.asciiz "\nError: wrong number"
		.align 4
buffer: 		.space 8
vA:		.space 16 # X1, Y1, Z1, R1, G1, B1
vB:		.space 16 # X2, Y2, Z2, R2, G2, B2
vC:		.space 16 # X3, Y3, Z3, R3, G3, B3
vAB:		.space 16 # X, Y, Z, R, G, B
vAC:		.space 16 # X, Y, Z, R, G, B
vBC:		.space 16 # X, Y, Z, R, G, B
CURR:		.space 16 # X, Y, Z, R, G, B
zbuf:		.space 307200 # WIDTH * HEIGHT * 4B - size of zbufor
zbuf_end:	.word 0
eol:		.asciiz "\n"



################################################################
# Macros									#
################################################################	

# Open file for read/write ---------------------------------------------------
.macro open_file(%filen, %flag, %des)
	# Open file
  	li   $v0, 13 		# system call for open file
 	la   $a0, %filen   	# output file name
  	li   $a1, %flag   	# Open for writing (flags are 0: read, 1: write)
	li   $a2, 0        	# mode is ignored
	syscall            	# open a file (file descriptor returned in $v0)
	
	# Check if succeed
	beq  $v0, -1, error_file	# branch if error occured
	sw $v0, %des			# save file descriptor in %des
.end_macro
# -----------------------------------------------------------------------

# Write file ---------------------------------------------------------------
.macro write_file(%des, %address, %num)
	# Write bytes to file
	li $v0, 15		# syscall for write to file
	lw $a0, %des		# file descriptor
	la $a1, %address 	# address of output buffer
	la $a2, %num		# number of characters to write
	syscall
	# Check if succeed
	bne $v0, %num, error_write	# error if wrote != %num characters
.end_macro
# -----------------------------------------------------------------------

# Close file ---------------------------------------------------------------
.macro close_file(%des)
	# Close
	li $v0, 16	# system call for close file
	lw $a0, %des	# file descriptor
	syscall
.end_macro
# -----------------------------------------------------------------------

# Error ------------------------------------------------------------------
.macro error(%err_msg)
	# Print error message
	li $v0, 4	# system call for print string
	la $a0, %err_msg
	syscall				
	
	# Terminate with code 1
	li $v0, 17	# system call for terminate with code	
	li $a0, 1	# terminate code
	syscall		
.end_macro
# -----------------------------------------------------------------------

# Set frame at stack - save ra and s registers, so another function can operate -------
.macro push_frame
	sw $ra, ($sp)		# save $ra to stack
	sw $s0, -4($sp)		# save $s0
	sw $s1, -8($sp)		# save $s1
	sw $s2, -12($sp)	# save $s2
	sw $s3, -16($sp)	# save $s3
	sw $s4, -20($sp)	# save $s4
	sw $s5, -24($sp)	# save $s5
	sw $s6, -28($sp)	# save $s6
	sw $s7, -32($sp)	# save $s7
	addi $sp, $sp, -36	# move stack pointer to first free
.end_macro
# -----------------------------------------------------------------------

# Pop frame from stack -----------------------------------------------------
.macro pop_frame
	addi $sp, $sp, 36	# move stack pointer back to $ra position
	lw $ra, ($sp)		# load $ra from stack
	lw $s0, -4($sp)		# load $s0
	lw $s1, -8($sp)		# load $s1
	lw $s2, -12($sp)	# load $s2
	lw $s3, -16($sp)	# load $s3
	lw $s4, -20($sp)	# load $s4
	lw $s5, -24($sp)	# load $s5
	lw $s6, -28($sp)	# load $s6
	lw $s7, -32($sp)	# load $s7

.end_macro
# -----------------------------------------------------------------------

# Swap vertices -----------------------------------------------------------
.macro swap(%addr1, %addr2, %reg1, %reg2)
	# Swap first word
	lw $t1, (%addr1)	# $t1 <- address1
	lw $t2, (%addr2)	# $t2 <- address2
	sw $t1, (%addr2)	# $t1 -> address2
	sw $t2, (%addr1)	# $t2 -> address1
	# Swap second word
	lw $t1, 4(%addr1)	# $t1 <- address1
	lw $t2, 4(%addr2)	# $t2 <- address2
	sw $t1, 4(%addr2)	# $t1 -> address2
	sw $t2, 4(%addr1)	# $t2 -> address1
	# Swap third word	
	lw $t1, 8(%addr1)	# $t1 <- address1
	lw $t2, 8(%addr2)	# $t2 <- address2
	sw $t1, 8(%addr2)	# $t1 -> address2
	sw $t2, 8(%addr1)	# $t2 -> address1
	# Swap fourth word	
	lw $t1, 12(%addr1)	# $t1 <- address1
	lw $t2, 12(%addr2)	# $t2 <- address2
	sw $t1, 12(%addr2)	# $t1 -> address2
	sw $t2, 12(%addr1)	# $t2 -> address1
	# Swap registers
	move $t1, %reg1		# $t1 <- %reg1
	move $t2, %reg2		# $t2 <- %reg2
	move %reg2, $t1		# $t1 -> %reg2
	move %reg1, $t2		# $t2 -> %reg1
.end_macro
# -----------------------------------------------------------------------

# Assign vertex -----------------------------------------------------------
.macro assign(%to_addr, %from_addr)
	# Assign first word
	lw $t0, (%from_addr)	# $t0 <- %from
	sw $t0, (%to_addr)	# $t0 -> %to
	# Assign second word
	lw $t0, 4(%from_addr)	# $t0 <- %from
	sw $t0, 4(%to_addr)	# $t0 -> %to
	# Assign third word
	lw $t0, 8(%from_addr)	# $t0 <- %from
	sw $t0, 8(%to_addr)	# $t0 -> %to
	# Assign fourth word
	lw $t0, 12(%from_addr)	# $t0 <- %from
	sw $t0, 12(%to_addr)	# $t0 -> %to
.end_macro
# -----------------------------------------------------------------------

# Set RGB value from X interpolation ----------------------------------------------
.macro interpolateRGB_X(%P1_addr, %P2_addr, %RES_addr, %col_OFFSET)
	# Set current's R	
	lw $t0, %RES_addr		# $t0 = RES.X
	lw $t1, (%P1_addr)		# $t1 = P1.X
	lw $t2, (%P2_addr)		# $t2 = P2.X
	# RES.COL = P2.COL * (CURR.X-P1.X)/(P2.X-P1.X) + P1.COL * (P2.X - CURR.X)/(P2.X-P1.X)
	subu $t3, $t2, $t1		# $t3 = P2.X - P1.X
	subu $t4, $t0, $t1		# $t4 = RES.X - P1.X
	subu $t5, $t2, $t0		# $t5 = P2.X - RES.X
	lbu $t6, %col_OFFSET(%P2_addr)	# $t6 = P2.COL = P2.X + offset that's P2.R or P2.G or P2.B
	mulu $t6, $t6, $t4		# $t6 = $t6*$t4 =  P2.COL * (RES.X-P1.X)
	divu $t6, $t6, $t3		# $t6 = $t6/$t3 = P2.COL * (RES.X-P1.X)/(P2.X-P1.X)
	lbu $t7, %col_OFFSET(%P1_addr)	# $t7 = P1.COL + offset that's P1.R or P1.G or P1.B
	mulu $t7, $t7, $t5		# $t7 = $t7*$t5 = P1.COL * (P2.X-RES.X)
	divu $t7, $t7, $t3		# $t7 = $t7/$t3 = P1.COL * (P2.X-RES.X)/(P2.X-P1.X)
	addu $t6, $t6, $t7		# $t6 = $t6+$t7 = P2.COL * (RES.X-P1.X)/(P2.X-P1.X) + P1.COL * (P2.X - RES.X)/(P2.X-P1.X)
	sb $t6, %RES_addr+%col_OFFSET	# Save $t6 to RES.R or RES.G or RES.B
.end_macro
# -----------------------------------------------------------------------

# Set RGB value from Y interpolation ----------------------------------------------
.macro interpolateRGB_Y(%P1_lab, %P2_lab, %RES_lab, %col_OFFSET)
	# Set current's R	
	lw $t0, %RES_lab+Y_OFFSET	# $t0 = RES.Y
	lw $t1, %P1_lab+Y_OFFSET	# $t1 = P1.Y
	lw $t2, %P2_lab+Y_OFFSET	# $t2 = P2.Y
	# RES.COL = P2.COL * (CURR.Y-P1.Y)/(P2.Y-P1.Y) + P1.COL * (P2.Y - CURR.Y)/(P2.Y-P1.Y)
	subu $t3, $t2, $t1		# $t3 = P2.Y - P1.Y
	subu $t4, $t0, $t1		# $t4 = CURR.Y - P1.Y
	subu $t5, $t2, $t0		# $t5 = P2.Y - CURR.Y
	lbu $t6, %P2_lab+%col_OFFSET	# $t6 = P2.COL = P2.X + offset that's P2.R or P2.G or P2.B
	mulu $t6, $t6, $t4		# $t6 = $t6*$t4 =  P2.COL * (CURR.Y-P1.Y)
	divu $t6, $t6, $t3		# $t6 = $t6/$t3 = P2.COL * (CURR.Y-P1.Y)/(P2.Y-P1.Y)
	lbu $t7, %P1_lab+%col_OFFSET	# $t7 = P1.COL + offset that's P1.R or P1.G or P1.B
	mulu $t7, $t7, $t5		# $t7 = $t7*$t5 = P1.COL * (P2.Y-CURR.Y)
	divu $t7, $t7, $t3		# $t7 = $t7/$t3 = P1.COL * (P2.Y-CURR.Y)/(P2.Y-P1.Y)
	addu $t6, $t6, $t7		# $t6 = $t6+$t7 = P2.COL * (CURR.Y-P1.Y)/(P2.Y-P1.Y) + P1.COL * (P2.Y - CURR.Y)/(P2.Y-P1.Y)
	sb $t6, %RES_lab+%col_OFFSET	# Save $t6 to RES.R or RES.G or RES.B
.end_macro
# -----------------------------------------------------------------------

# Set X value from Y interpolation ----------------------------------------------
.macro interpolateX(%P1_lab, %P2_lab, %RES_lab)
	# Set current's R	
	lw $t0, %RES_lab+Y_OFFSET		# $t0 = RES.Y
	lw $t1, %P1_lab+Y_OFFSET		# $t1 = P1.Y
	lw $t2, %P2_lab+Y_OFFSET		# $t2 = P2.Y
	# RES.X = P2.X * (RES.Y-P1.Y)/(P2.Y-P1.Y) + P1.X * (P2.Y - RES.Y)/(P2.Y-P1.Y)
	subu $t3, $t2, $t1		# $t3 = P2.Y - P1.Y
	subu $t4, $t0, $t1		# $t4 = RES.Y - P1.Y
	subu $t5, $t2, $t0		# $t5 = P2.Y - RES.Y
	lw $t6, %P2_lab+X_OFFSET	# $t6 = P2.X
	mulu $t6, $t6, $t4		# $t6 = $t6*$t4 =  P2.X * (RES.Y-P1.Y)
	div $t6, $t6, $t3		# $t6 = $t6/$t3 = P2.X * (RES.Y-P1.Y)/(P2.Y-P1.Y)
	lw $t7, %P1_lab+X_OFFSET	# $t7 = P1.X
	mulu $t7, $t7, $t5		# $t7 = $t7*$t5 = P1.X * (P2.Y-RES.Y)
	divu $t7, $t7, $t3		# $t7 = $t7/$t3 = P1.X * (P2.Y-RES.Y)/(P2.Y-P1.Y)
	addu $t6, $t6, $t7		# $t6 = $t6+$t7 = P2.X * (RES.Y-P1.Y)/(P2.Y-P1.Y) + P1.X * (P2.Y - RES.Y)/(P2.Y-P1.Y)
	sw $t6, %RES_lab+X_OFFSET	# Save $t6 to RES.X
.end_macro
# -----------------------------------------------------------------------

# Set Z value from X or Y interpolation ----------------------------------------------
.macro interpolateZ(%P1_addr, %P2_addr, %RES_lab, %offset)
	# Save $ra and $s0-7 to stack
	push_frame
	# Set current's R	
	move $t1, %P1_addr
	move $t2, %P2_addr
	lw $s0, %RES_lab+%offset	# $s0 = RES.X or Y
	lw $s1, %offset($t1)		# $s1 = P1.X or Y
	lw $s2, %offset($t2)		# $s2 = P2.X or Y
	lw $s6, Z_OFFSET($t2)		# $s6 = P2.Z
	lw $s7, Z_OFFSET($t1)		# $s7 = P1.X or P2.Z
	# RES.Z = P2.Z * (RES.X-P1.X)/(P2.X-P1.X) + P1.Z * (P2.X - RES.X)/(P2.X-P1.X)
	subu $s3, $s2, $s1		# $s3 = P2.X - P1.X
	subu $s4, $s0, $s1		# $s4 = RES.X - P1.X
	subu $s5, $s2, $s0		# $s5 = P2.X - RES.X
	mulu $s6, $s6, $s4		# $s6 = $s6*$s4 =  P2.Z * (RES.X-P1.X)
	# Divide 64bits: ( $a0*2^32 + $a1 ) / $s2
	mfhi $a0			# $a0 = HI from $s6*$s4
	mflo $a1			# $a1 = LO from $s6*$s4
	move $a2, $s3			# $a2 = $s3
	jal div64			# $v1 = $s6/$s3 = P2.Z * (RES.X-P1.X)/(P2.X-P1.X)
	move $s6, $v1
	
	mulu $s7, $s7, $s5		# $s7 = $s7*$s5 = P1.Z * (P2.X-RES.X)
	# Divide 64bits: 
	mfhi $a0			# $a0 = HI from $s7*$s5
	mflo $a1			# $a1 = LO from $s7*$s5
	move $a2, $s3			# $s2 = $s3
	jal div64			# $v1 = $s7/$s3 = P1.Z * (P2.X-RES.X)/(P2.X-P1.X)
	move $s7, $v1
	addu $s6, $s6, $s7		# $s6 = $s6+$s7 = P2.Z * (RES.X-P1.X)/(P2.X-P1.X) + P1.Z * (P2.X - RES.X)/(P2.X-P1.X)
	sw $s6, %RES_lab+Z_OFFSET	# Save $s6 to RES.Z
	# Restore $ra and $s0-7
	pop_frame
.end_macro
# -----------------------------------------------------------------------

# Save VAR pixel color to bitmap according to Z value ----------------------------
.macro save_pixel(%X, %Y, %VAR)
	# Pixel address = bitmap + (Y * WIDTH + X) *3
	move $t0, %X		# $t0 = X
	li $t1, 239		# $t1 = 239
	subu $t1, $t1, %Y	# Y = 239 - Y  -> revert coordinate 	
	mul $t1, $t1, WIDTH	# $t1 = Y * WIDTH
	add $t0, $t0, $t1	# $t0 = Y * WIDTH + X
	mul $t1, $t0, 4		# $t1 = (Y * WIDTH + X) * 4 - zbuf offset
	mul $t0, $t0, 3		# $t0 = (Y * WIDTH + X) * 3 - RGB offset
	# Check Z value
	lw $t2, zbuf($t1)	# $t2 = zbuf[X, Y]
	lw $t3, %VAR+Z_OFFSET	# $t3 = VAR.Z
	bgeu $t3, $t2, save_pixel_end	# if VAR.Z > zbuf[X, Y] don't save pixel
	sw $t3, zbuf($t1)	# Update zbuf
	# Save colors from VARIABLE to bitmap
	lbu $t2, %VAR+B_OFFSET	# $t2 = VAR.B
	sb $t2, bitmap_data($t0)
	lbu $t2, %VAR+G_OFFSET	# $t2 = VAR.G
	sb $t2, bitmap_data+1($t0)
	lbu $t2, %VAR+R_OFFSET	# $t2 = VAR.R
	sb $t2, bitmap_data+2($t0)	
	save_pixel_end:	
.end_macro
# -----------------------------------------------------------------------

################################################################
# Main									#
################################################################
.text
main:
	# Set background
	jal set_zbuf
	open_file(opis, READ, opis_des)
	jal set_background
	
	# Print triangles
	main_print_triangles:
		jal process_triangle
		j main_print_triangles
	
	# Generate .bmp and finish
	main_EOF:
	jal generate_scena
	jal generate_zbuf
	j exit

################################################################
# Functions and macros							#
################################################################

# Process triangle ----------------------------------------------------------
process_triangle:
	# Save $ra and $s0-7 to stack
	push_frame
	# Read triangle's parameters to A, B and C
	jal get_line	
	# Sort vertices
	jal sort_vertices
	
	# First draw lines between AB and AC sides of triangle ---------------------
	la $a1, vA			# address of A
	la $a2, vB			# address of B
	la $s0, vAB			# address of AB
	la $s1, vAC			# address of AC
	la $s2, vBC			# address of BC
	assign($s0, $a1)		# AB = A
	assign($s1, $a1)		# AC = A
	assign($s2, $a2)		# BC = B
	# If A.Y == B.Y draw horizline between them

	lw $t1, vB+Y_OFFSET		# $t1 = B.Y
	lw $t0, vA+Y_OFFSET		# $t0 = A.Y
	bne $t0, $t1, no_horizline_bot	# if A.Y != B.Y -> skip drawing line
	# Draw horizontal AB, arguments: $a1 = A address, $a2 = B address
	jal horizline
	# Set registers
	no_horizline_bot:
	lw $s0, vAB			# $s0 = AB.X		
	lw $s1, vAB+Y_OFFSET		# $s1 = AB.Y
	lw $s2, vAC			# $s2 = AC.X
	lw $s3, vAC+Y_OFFSET		# $s3 = AC.Y
	lw $s4, vB+Y_OFFSET		# $s4 = B.Y
	la $s5, vA			# $s5 = A address
	la $s6, vB			# $s6 = B address
	la $s7, vC			# $s7 = C address
	# Loop for printing horizontal lines from A to B
	process_triangle_loop_AB:
		# Until AB.Y < B.Y
		bge $s1, $s4, process_triangle_loop_AB_end
		# Set AB.X based on Y
		interpolateX(vA, vB, vAB)		
		# Set AB.Z based on Y
		interpolateZ($s5, $s6, vAB, Y_OFFSET)		
		# Set AB.R based on Y
		interpolateRGB_Y(vA, vB, vAB, R_OFFSET)
		# Set AB.G based on Y
		interpolateRGB_Y(vA, vB, vAB, G_OFFSET)
		# Set AB.B based on Y
		interpolateRGB_Y(vA, vB, vAB, B_OFFSET)
		# Set AC.X based on Y
		interpolateX(vA, vC, vAC)		
		# Set AC.Z based on Y
		interpolateZ($s5, $s7, vAC, Y_OFFSET)		
		# Set AC.R based on Y
		interpolateRGB_Y(vA, vC, vAC, R_OFFSET)
		# Set AC.G based on Y
		interpolateRGB_Y(vA, vC, vAC, G_OFFSET)
		# Set AC.B based on Y
		interpolateRGB_Y(vA, vC, vAC, B_OFFSET)
		# Save AB and AC to bitmap
		lw $s0, vAB		# update AB.X
		lw $s2, vAC		# update AC.X
		save_pixel($s0, $s1, vAB)
		save_pixel($s2, $s3, vAC)
		# Draw horizontal line between AB and AC
		la $a1, vAB
		la $a2, vAC
		jal horizline
		# Loop
		addi $s1, $s1, 1	# AB.Y ++
		sw $s1, vAB+Y_OFFSET 	# save AB
		addi $s3, $s3, 1	# AC.Y ++
		sw $s3, vAC+Y_OFFSET	# save AC
		j process_triangle_loop_AB
	process_triangle_loop_AB_end:
	#-----------------------------------------------------------------
	
	# Then draw lines between AC and BC sides of triangle ---------------------
	la $a1, vB			# address of B
	la $a2, vC			# address of C
	# If B.Y == C.Y draw horizline between them
	lw $t0, vB+Y_OFFSET		# $t0 = B.Y
	lw $t1, vC+Y_OFFSET		# $t1 = C.Y
	bne $t0, $t1, no_horizline_top	# if B.Y != C.Y -> skip drawing line
	# Draw horizontal BC, arguments: $a1 = B address, $a2 = C address
	jal horizline
	# Set registers
	no_horizline_top:
	lw $s0, vBC			# $s0 = BC.X		
	lw $s1, vBC+Y_OFFSET		# $s1 = BC.Y
	lw $s2, vAC			# $s2 = AC.X
	lw $s3, vAC+Y_OFFSET		# $s3 = AC.Y
	lw $s4, vC+Y_OFFSET		# $s4 = C.Y
	la $s5, vA			# $s5 = A address
	la $s6, vB			# $s6 = B address
	la $s7, vC			# $s7 = C address
	# Loop for printing horizontal lines from B to C
	process_triangle_loop_BC:
		# Until BC.Y < C.Y
		bge $s1, $s4, process_triangle_loop_BC_end
		# Set BC.X based on Y
		interpolateX(vB, vC, vBC)		
		# Set BC.Z based on Y
		interpolateZ($s6, $s7, vBC, Y_OFFSET)	
		# Set BC.R based on Y
		interpolateRGB_Y(vB, vC, vBC, R_OFFSET)
		# Set BC.G based on Y
		interpolateRGB_Y(vB, vC, vBC, G_OFFSET)
		# Set BC.B based on Y
		interpolateRGB_Y(vB, vC, vBC, B_OFFSET)
		# Set AC.X based on Y
		interpolateX(vA, vC, vAC)		
		# Set AC.Z based on Y
		interpolateZ($s5, $s7, vAC, Y_OFFSET)	
		# Set AC.R based on Y
		interpolateRGB_Y(vA, vC, vAC, R_OFFSET)
		# Set AC.G based on Y
		interpolateRGB_Y(vA, vC, vAC, G_OFFSET)
		# Set AC.B based on Y
		interpolateRGB_Y(vA, vC, vAC, B_OFFSET)
		# Save BC and AC to bitmap
		lw $s0, vBC		# update BC.X
		lw $s2, vAC		# update AC.X
		save_pixel($s0, $s1, vBC)
		save_pixel($s2, $s3, vAC)
		# Draw horizontal line between BC and AC
		la $a1, vBC
		la $a2, vAC
		jal horizline
		# Loop
		addi $s1, $s1, 1	# BC.Y ++
		sw $s1, vBC+Y_OFFSET	# save BC
		addi $s3, $s3, 1	# AC.Y ++
		sw $s3, vAC+Y_OFFSET	# save AC
		j process_triangle_loop_BC
	process_triangle_loop_BC_end:
	#--------------------------------------------------------------------
	# Restore $ra and $s0-7
	pop_frame
	
	jr $ra
# -----------------------------------------------------------------------

# Print horizontal line between P1 and P2 with interpolaton -----------------------
# Arguments: a1 - heap address of P1, a2 - heap address of P2 
horizline:
	# Save $ra and $s0-7 to stack
	push_frame
	# Save $a1 and $a2 addresses
	la $s6, ($a1)
	la $s7, ($a2)
	# Load P1.X and P2.X to registers
	lw $s1, ($a1)	# P1.X to $s1
	lw $s2, ($a2)	# P2.X to $s2
	# Swap P1 - P2 if P1.X > P2.X
	ble $s1, $s2, no_swap	# if P1.X <= P2.X don't swap
	swap($a1, $a2, $s1, $s2)
	no_swap:
	# CURR = P1
	la $a0, CURR	# $a0 = CURR address
	assign($a0, $a1)
	lw $s3, CURR	# $s3 = CURR.X
	lw $s4, CURR+4	# $s4 = CURR.Y
	
	horizline_loop:
		# Until CURR.X < P2.X
		bge $s3, $s2, horizline_end		# if CURR.X >= P2.X end loop
		# Set current's Z based on X
		interpolateZ($s6, $s7, CURR, X_OFFSET)
		# Set current's R based on X
		interpolateRGB_X($s6, $s7, CURR, R_OFFSET)		# 12 - R's offset
		# Set current's G based on X
		interpolateRGB_X($s6, $s7, CURR, G_OFFSET)		# 13 - G's offset
		# Set current's R based on X
		interpolateRGB_X($s6, $s7, CURR, B_OFFSET)		# 14 - B's offset
		# Save pixel to bitmap
		save_pixel($s3, $s4, CURR)
		# Loop
		addi $s3, $s3, 1	# CURR.X ++
		sw $s3, CURR		# save CURR.X
		j horizline_loop
	
	horizline_end:	
	# Restore $ra and $s0-7
	pop_frame	
	jr $ra
# -----------------------------------------------------------------------

# Sort vertices by Y --------------------------------------------------------
sort_vertices:
	# Save $ra and $s0-7 to stack
	push_frame
	# Load vertices
	lw $s0, vA+Y_OFFSET	# $s0 = A.Y
	lw $s1, vB+Y_OFFSET 	# $s1 = B.Y
	lw $s2, vC+Y_OFFSET	# $s2 = C.Y
	la $s3, vA		# $s3 = A address
	la $s4, vB		# $s4 = B address 
	la $s5, vC		# $s5 = C address
	# Comparisons and swaps
	sort_vertices_AB:
		# A <-> B
		ble $s0, $s1, sort_vertices_AC	# if A.Y <= B.Y then next comparison
		swap($s3, $s4, $s0, $s1)	# else swap	
	sort_vertices_AC:
		# A <-> C
		ble $s0, $s2, sort_vertices_BC	# if A.Y <= C.Y then next comparison
		swap($s3, $s5, $s0, $s2)	# else swap
	sort_vertices_BC:
		# B <-> C
		ble $s1, $s2, sort_vertices_end	# if B.Y <= C.Y then end sorting
		swap($s4, $s5, $s1, $s2)	# else swap
		
	sort_vertices_end:
	# Restore $ra and $s0-7
	pop_frame
	jr $ra
# -----------------------------------------------------------------------

# Get line and set triangle's parameters----------------------------------------
get_line:
	# Save $ra and $s0-7 to stack
	push_frame
	# Load heap address
	la $s0, vA 	# load begin address to iterator
	la $s1, vC	# load end address
	li $s2, 239	# $s2 = 239 = max Y
	get_line_read:
		# Read X
		jal read_number
		bge $v0, WIDTH, error_number
		sw $v0, X_OFFSET($s0) 
		# Read Y 
		jal read_number
		bge $v0, HEIGHT, error_number
		#subu $v0, $s2, $v0	# Y = 239 - Y, to revert Y coordinate
		sw $v0, Y_OFFSET($s0)
		# Read Z
		jal read_number
		bgeu $v0, 0xFFFFFFFF, error_number
		sw $v0, Z_OFFSET($s0) 
		# Read R
		jal read_number
		bgt $v0, 255, error_number
		sb $v0, R_OFFSET($s0)
		# Read G
		jal read_number
		bgt $v0, 255, error_number
		sb $v0, G_OFFSET($s0)
		# Read B
		jal read_number
		bgt $v0, 255, error_number
		sb $v0, B_OFFSET($s0)
		# Shift address and loop
		beq $s0, $s1, get_line_end	# if read third - end
		addiu $s0, $s0, 16		# otherwise shift address to the next vertex
		j get_line_read
	
	get_line_end:
	#Restore $ra and $s0-7
	pop_frame
	jr $ra
# -----------------------------------------------------------------------

# Read number from file ----------------------------------------------------
read_number:
	li $t1, 0		# reset $t1
	li $t2, 0		# digits flag: 0 - haven't read yet, 1 - have some already
	# Skip white chars
	read_number_loop:
		# Read byte
		li $v0, 14		# system call for read from file
		lw $a0, opis_des	# load file descriptor
		la $a1, buffer		# input buffer
		li $a2, 1		# number of bytes to read
		syscall
		# Check if succeed
		beq $v0, 0, main_EOF		# branch if read EOF
		blt $v0, 0, error_read		# branch if error occured
		# Add digit to digit_buf
		lbu $t0, buffer			# load char to $t0		
		blt $t0, '0', read_number_wc	# if read white char
		bgt $t0, '9', read_number_wc	# if read white char
		j read_number_digit		# read digit
		# Read white char
		read_number_wc:
		# If haven't read any digits yet - skip and continue
		beq $t2, 0, read_number_loop
		# Else this is the end of the number, end function
		j read_number_end
		# Read digit
		read_number_digit:
		li $t2, 1			# digits flag - read some digits
		subiu $t0, $t0, '0'		# char -> number
		mulu $t1, $t1, 10		# shift one position
		addu $t1, $t1, $t0		# add next digit
		j read_number_loop		# loop
		
	# Write space and the end of digit_buf
	read_number_end:
	move $v0, $t1	# save number to $v0
	jr $ra
# -----------------------------------------------------------------------
	
# Set background color -----------------------------------------------------
set_background:
	# Save $ra and $s0-7 to stack
	push_frame
	# Read R background value to $s0
	jal read_number
	bgt $v0, 255, error_number
	move $s0, $v0
	# Read G background value to $s1
	jal read_number
	bgt $v0, 255, error_number
	move $s1, $v0
	# Read B background value to $s2
	jal read_number
	bgt $v0, 255, error_number
	move $s2, $v0
	# Set all pixels to background color
	la $t0, bitmap_data	# set $t0 to bitmap_data address
	la $t1, bitmap_end	# set $t1 to bitmap_end address
	set_background_loop:
		bge $t0, $t1, set_background_end	# branch if set all pixels
		sb $s2, ($t0)		# save B
		sb $s1, 1($t0)		# save G
		sb $s0, 2($t0)		# save R
		addi $t0, $t0, 3	# go to next pixel
		j set_background_loop	# loop
	# End
	set_background_end:
	# Restore $ra and $s0-7
	pop_frame
	jr $ra
# -----------------------------------------------------------------------

# Set zbufor initial value ----------------------------------------------------
set_zbuf:
	# Save $ra and $s0-7 to stack
	push_frame
	# Set all points to 0xFFFFFFFF = INF
	la $t0, zbuf		# set $t0 to zbuf address
	la $t1, zbuf_end	# set $t1 to zbuf_end address
	li $s0, 0xFFFFFFFF	# $s0 = 0xFFFFFFFF = INF
	set_zbuf_loop:
		bge $t0, $t1, set_zbuf_end	# branch if set all points
		sw $s0, ($t0)		# set point initial value
		addi $t0, $t0, 4	# go to next point
		j set_zbuf_loop		# loop
	# End
	set_zbuf_end:
	# Restore $ra and $s0-7
	pop_frame
	jr $ra
# -----------------------------------------------------------------------

# Generate scena.bmp -----------------------------------------------------
generate_scena:
	# Write bmp data from heap to file
	open_file(scena, WRITE, scena_des)
	write_file(scena_des, bitmap, FSIZE)
	close_file(scena_des)
	jr $ra
# -----------------------------------------------------------------------

# Generate zbuf.bmp -----------------------------------------------------
generate_zbuf:
	# Set RGB values based on zbuf
	la $t0, zbuf		# $t0 = zbuf address
	la $t1, zbuf_end	# $t1 = zbuf_end address
	la $t2, zbuf_bmp	# $t2 = zbuf_bmp address
	li $t3, 0xFF		# $t3 = 255 - max RGB value
	generate_zbuf_loop:
		beq $t0, $t1, generate_zbuf_write	# if reached zbuf_end
		lw $t4, ($t0)		# $t4 = next zbuf value
		srl $t4, $t4, 24	# RGB = MSB of zbuf (31:24)
		subu $t4, $t3, $t4	# $t4 = 255 -  $t4 so that 0xFF is black and 0x00 white
		sb $t4, ($t2)		# B
		sb $t4, 1($t2)		# G
		sb $t4, 2($t2)		# R
		addiu $t0, $t0, 4	# next word
		addiu $t2, $t2, 3	# next pixel
		j generate_zbuf_loop
	# Write bmp data from heap to file
	generate_zbuf_write:
	open_file(zbufor, WRITE, zbufor_des)
	write_file(zbufor_des, bitmap, HEADER)
	write_file(zbufor_des, zbuf_bmp, SIZE)
	close_file(zbufor_des)
	jr $ra
# -----------------------------------------------------------------------

# Divide 64bit ------------------------------------------------------------
div64:
	# Save $ra and $s0-7 to stack
	push_frame
	# Divide: ($a0x2^32 + $a1) / $a2
	# $a2should be < 2^16 !

	divu $a0, $a2 
	mflo $v0 		# HI result register, quotient is bits 63:32 of result
	mfhi $t1 		# remainder is 31:16 bits of next division 
	
	sll $t1, $t1, 16 	# high 16 bits from remainder
	srl $t2, $a1, 16 	# high 16 bits from $a2 at 15:0 position
	add $t2, $t2, $t1 
	divu $t2, $a2
	mflo $v1		# LO result register, quotient is bits 31:16 of result
	sll $v1, $v1, 16 	# shift quotient into place 31:16 in result register 
	mfhi $t1 		# remainder is 31:16 bits of next division 

	sll $t1, $t1, 16	# high 16 bits from remainder
	andi $t2, $a1, 0xFFFF	# low 16 bits from $a2 at 15:0 position
	add $t2, $t2, $t1 
	divu $t2, $a2 
	mflo $t1 		# LO result register, quotient is bits 15:0 of result 
	addu $v1, $v1, $t1 	# set quotient at place 15:0 in result register
	#mfhi $s1 		# result remainder 
	
	# Done. Result is in v0(high) and v1(low).
	# Restore $ra and $s0-7
	pop_frame
	jr $ra
# -----------------------------------------------------------------------

# Errors------------------------------------------------------------------
error_read:
	error(err_read)
error_write:
	error(err_write)
error_file:
	error(err_file)
error_number:
	error(err_number)
# -----------------------------------------------------------------------

# End of program ---------------------------------------------------------
exit:
	# Terminate with code 0
	la $v0, 10	# system call for terminate
	syscall
# -----------------------------------------------------------------------

