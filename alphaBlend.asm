

section .data
    trans: dq 255.0   ; transluence/alpha
	needed: dq 2.0	  ; 2, in case
	thick: dq 1.0	  ; thickness
section .text


global alpha_blend

alpha_blend:
	push 	r12
	push 	r13
	push 	r14
	push 	r15
	push 	rbx

	; change width and heigth
	mov 	r10, rcx
	mov 	r11, rdx
	dec 	r11	


x_loop_finish:
	dec 	r10


loop_y:
	cmp 	r10, 0
	jl 		end_y_loop

	mov 	r15, 0		; meanwhile for x


loop_x:
	mov 	rax, r10
	sub 	rax, r9	
	imul 	rax, rax

	mov 	rbx, r15
	sub 	rbx, r8	
	imul 	rbx, rbx	; x dif

	add 	rax, rbx

	push 	rax
	fild 	qword[rsp]
	fsqrt
	fdiv 	qword[thick]
	fsin
	fmul 	qword[trans]	;sinus and trans operations
	fadd 	qword[trans]
	fdiv 	qword[needed]
	fistp 	qword[rsp]
	pop		rax	

	cvtsi2sd xmm2, rax

	mov 	rcx, r8
	mov 	r14, r9

	mov 	r8, r15		; move x
	mov 	r9, r10		; move y

;pixels blending

	;first pic
	add 	r11, 1

	mov 	rax, r9
	mov 	rdx, r11
	shl 	rdx, 1
	add 	rdx, r11
	imul 	rax, rdx
	add 	rax, rsi

	;second pic
	mov 	rbx, r9
	mov 	rdx, r11
	shl 	rdx, 1		;
	add 	rdx, r11	; mul x3 bcs pixel is 3 bytes
	imul 	rbx, rdx
	add 	rbx, rdi

	sub 	r11, 1		; correction

	lea 	r13, [r8*2+r8]  ;offset, r8 is actual x
	add 	rax, r13		; pointers to actual pixels
	add 	rbx, r13		;


	movzx 	r12, byte[rax]	; get B   (<-----)
	movzx 	r13, byte[rbx]

	add 	r12, 64				;
	sub 	r12, r13			;
	cvtsd2si rdx, xmm2			;
	imul 	r12, rdx			;
	sar 	r12, 8 				; pure blend (i'm a duumie)
	add 	r12, r13			;
	cvtsd2si rdx, xmm2			;
	mov 	r13, rdx			;
	shr 	r13, 2				;
	sub 	r12, r13			;

	lea 	edx, [r12]
	mov 	byte[rbx], dl	    ; set B


	movzx 	r12, byte[rax+1]    ; get G
	movzx 	r13, byte[rbx+1]

	add 	r12, 64				; blend again
	sub 	r12, r13
	cvtsd2si rdx, xmm2
	imul 	r12, rdx
	sar 	r12, 8 
	add 	r12, r13
	cvtsd2si rdx, xmm2
	mov 	r13, rdx
	shr 	r13, 2
	sub 	r12, r13

	lea 	edx, [r12]
	mov 	byte[rbx+1], dl     ; set G


	movzx 	r12, byte[rax+2]    ; get R
	movzx 	r13, byte[rbx+2]

	add 	r12, 64				; and again
	sub 	r12, r13
	cvtsd2si rdx, xmm2
	imul 	r12, rdx
	sar 	r12, 8 
	add 	r12, r13
	cvtsd2si rdx, xmm2
	mov 	r13, rdx
	shr 	r13, 2
	sub 	r12, r13

	lea 	edx, [r12]
	mov 	byte[rbx+2], dl     ; set R
 

	mov 	r8, rcx
	mov 	r9, r14

	inc 	r15
	cmp 	r11, r15
	jl 		x_loop_finish

	jmp 	loop_x


end_y_loop:

	pop 	rbx
	pop 	r15
	pop 	r14
	pop 	r13
	pop 	r12
	ret

