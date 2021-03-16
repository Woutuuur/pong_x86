.global main, time, ballx, bally, xdir, ydir, p1y, p2y

.text
main:
	pushl	$1000
	call	set_timer_frequency
	addl	$4, %esp

	call	set_handlers

	# Set up VGA stuff
	call 	color_text_mode
	call 	hide_cursor

	# Clear top bar
	movb    $' ', %al 
	movb    $0x70, %ah 
	movl    $80, %ecx
	movl    $vga_memory, %edi
	cld 
	rep     stosw

	# Clear the screen
	call	clear

	# Reset score
	movb	$'0', vga_memory + 72
	movb	$' ', vga_memory + 74
	movb	$' ', vga_memory + 76
	movb	$'-', vga_memory + 78
	movb	$' ', vga_memory + 80
	movb	$' ', vga_memory + 82
	movb	$'0', vga_memory + 84
	
	call	render
loop:
	call	read_inputs

	movl	xdir, %eax
	addl	%eax, ballx
	movl	ydir, %eax
	addl	%eax, bally

	cmpl	$1, bally
	jle		invert_bally
	cmpl	$24, bally
	jge		invert_bally
	bally_invert_end:

	cmpl	$0, ballx
	jle		check_player1_collision
	cmpl	$158, ballx
	jge		check_player2_collision
	ballx_invert_end:

	call	clear
	call	render

	movl	$0, time
	jmp		loop

check_player1_collision:
	movl	bally, %eax
	movl	p1y, %ebx

	cmpl	p1y, %eax
	jl		player2_score
	addl	$7, %ebx
	cmpl	%ebx, %eax
	jg		player2_score

	jmp		collsion_check_end

check_player2_collision:
	movl	bally, %eax
	movl	p2y, %ebx

	cmpl	p2y, %eax
	jl		player1_score
	addl	$7, %ebx
	cmpl	%ebx, %eax
	jg		player1_score

	jmp		collsion_check_end

collsion_check_end:
	call 	invert_ballx
	jmp		ballx_invert_end

player1_score:
	movl 	$vga_memory, %eax
	addl	$72, %eax
	incl	(%eax)
	call	reset_ball
	jmp		collsion_check_end

player2_score:
	movl 	$vga_memory, %eax
	addl	$84, %eax
	incl	(%eax)
	call	reset_ball
	jmp		collsion_check_end

reset_ball:
	movl	$80, ballx
	movl	$12, bally
	movl	xdir, %eax
	negl	%eax
	movl	%eax, prev_dir
	movl	$0, xdir
	movl 	$0, ydir
	movl	$2000, round_delay
	ret

invert_ballx:
	negl	xdir
	ret

invert_bally:
	negl	ydir
	jmp		bally_invert_end

read_inputs:
	movl	main_delay, %ebx
	read_loop:
		call 	paddle_inputs
		cmpl	%ebx, time
		jl		read_loop
	ret

clear:
	pushl   %eax
	pushl   %ecx

	movb    $' ', %al 
	movb    $0x0F, %ah 
	movl    $25*80, %ecx
	movl    $vga_memory, %edi
	addl	$160, %edi
	cld 
	rep     stosw

	popl	%ecx
	popl	%eax
	ret

paddle_inputs:
	pushl	%ebp
	movl	%esp, %ebp

	cmpb    $1, (curr_key)
	je      move_paddle_up
	cmpb    $2, (curr_key)
	je      move_paddle_down

	movl	%ebp, %esp
	popl	%ebp
	ret

move_paddle_up:
	movl    p1y, %eax

	cmpl    $17, %eax
	jge     move_paddle_done

	incl    p1y

	jmp     move_paddle_done

move_paddle_down:
	movl    p1y, %eax

	cmpl    $1, %eax
	jle     move_paddle_done

	decl    p1y

	jmp     move_paddle_done

move_paddle_done:
	movb    $0, curr_key

	movl	%ebp, %esp
	popl	%ebp
	ret

.data
	time: 			.long 0
	p1y:			.long 12
	p2y:			.long 12
	ballx:			.long 80
	bally:			.long 12
	xdir:			.long -2
	ydir:			.long 1
	prev_dir: 		.long 0
	round_delay:	.long 2000
	main_delay:		.long 50
