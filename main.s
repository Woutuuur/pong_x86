# A simple example that uses bootlib.

.global main, time

.text
main:
	pushl	$1000
	call	set_timer_frequency
	addl	$4, %esp

	call	set_handlers

	# Set up VGA stuff
	call 	color_text_mode
	call 	hide_cursor

	call	clear

loop:
	movl	$50, %ebx
	call	delay

	movl	xdir, %eax
	addl	%eax, ballx
	movl	ydir, %eax
	addl	%eax, bally

	cmpl	$0, bally
	jle		invert_bally
	cmpl	$25, bally
	jge		invert_bally
	bally_invert_end:

	cmpl	$0, ballx
	jle		invert_ballx
	cmpl	$158, ballx
	jge		invert_ballx
	ballx_invert_end:

	call	clear
	call	render

	movl	$0, time
	jmp		loop

invert_ballx:
	negl	xdir
	jmp		ballx_invert_end

invert_bally:
	negl	ydir
	jmp		bally_invert_end

delay:
	cmpl	%ebx, time
	jl		delay 
	ret

render:	
	# Render the ball
	movl	$160, %eax
	movl	bally, %ebx
	mull	%ebx
	addl	ballx, %eax
	movl	%eax, %ebx		

	movl 	$vga_memory, %eax
	addl	%ebx, %eax
	movb 	$254, (%eax)

	# Render player 1
	movl	$160, %eax
	movl	p1y, %ebx
	mull	%ebx
	movl	%eax, %ebx

	movl 	$vga_memory, %eax
	addl 	%ebx, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax

	# Render player 2
	movl	$160, %eax
	movl	p2y, %ebx
	mull	%ebx
	addl	$158, %eax
	movl	%eax, %ebx

	movl 	$vga_memory, %eax
	addl 	%ebx, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax
	movb 	$219, (%eax)
	addl	$160, %eax

	ret
			
clear:
	pushl   %eax
	pushl   %ecx

	movb    $' ', %al 
	movb    $0x0F, %ah 
	movl    $25*80, %ecx
	movl    $vga_memory, %edi
	cld 
	rep     stosw

	popl	%ecx
	popl	%eax
	ret

.data
	time: 	.long 0
	p1y:	.long 12
	p2y:	.long 12
	ballx:	.long 10
	bally:	.long 15
	xdir:	.long 2
	ydir:	.long 1