
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32


.global app
app:
	// X0 contiene la direccion base del framebuffer
	mov x20, x0
	mov x21, 0
	mov x22, 50

animation:
	bl clear_screen

	// *************** PASTO *************** 
	movz x0, 120			// X0: X
	movz x1, 400			// X1: Y
	movz x2, 640			// X2: W
	movz x3, 80			// X3: H
	mov x4, 0x009900		// X4: Color
	bl draw_rect

	// *************** CUERPO CASA ***************
	movz x0, 170			// X0: X
	movz x1, 250			// X1: Y
	movz x2, 300			// X2: W
	movz x3, 150			// X3: H
	mov x4, 0xF7DD		// X4: Color
	add x4, x4, 0xFF0000
	bl draw_rect

	// *************** TECHO ***************
	// ***** IZQ *****
	movz x0, 220			// X0: X
	movz x1, 150			// X1: Y
	movz x2, 100			// X2: W
	movz x3, 100			// X3: H
	mov x4, 0x800000		// X4: Color
	bl draw_trian_left

	// ***** DER *****
	movz x0, 320			// X0: X
	movz x1, 150			// X1: Y
	movz x2, 100			// X2: W
	movz x3, 100			// X3: H
	mov x4, 0x800000		// X4: Color
	add x4, x4, 0xFF0000
	bl draw_trian

	cbz x21, _animation_non_animated

	// *************** LUZ ATRAS PUERTA ***************
	movz x0, 350			// X0: X
	movz x1, 300			// X1: Y
	movz x2, 50			// X2: W
	movz x3, 100			// X3: H
	mov x4, 0xFFFF00
	add x4, x4, 0x66
	bl draw_rect

	// *************** VENTANA PRENDIDA ***************
	movz x0, 240			// X0: X
	movz x1, 310			// X1: Y
	movz x2, 50			// X2: W
	movz x3, 50			// X3: H
	mov x4, 0xFFFF00
	add x4, x4, 0x66
	bl draw_rect

	cmp x22, #10
	b.eq _animation_door
	sub x22, x22, #1

	b _animation_door

_animation_non_animated:

	// *************** VENTANA ***************
	movz x0, 240			// X0: X
	movz x1, 310			// X1: Y
	movz x2, 50			// X2: W
	movz x3, 50			// X3: H
	mov x4, 0x0
	bl draw_rect

_animation_door:
	// *************** PUERTA ***************
	movz x0, 350			// X0: X
	movz x1, 300			// X1: Y
	mov x2, x22			// X2: W
	movz x3, 100			// X3: H
	mov x4, 0x990000
	add x4, x4, 0x6000
	add x4, x4, 0x633
	bl draw_rect

	cbnz x21, _animation_final

	bl uart_puts
wait_char:
	bl uart_received
	cbnz w0, wait_char
	bl uart_getc_noblock

	mov x21, 1

_animation_final:

	mov x0, 0xFFFF			// Cantidad delay
	bl wait_msec

	b animation

InfLoop: 
	b InfLoop

clear_screen:
	mov x0, x20				// Restaura base de Framebuffer a X0

	mov x2, 0
	movz x1, 0xB000
	movk x1, 0x4, LSL #16
	add x2, x2, 0x660000
	add x2, x2, 0xC000
	add x2, x2, 0xCFF

super_loop0:				// Solo para el clear_screen
		stur x2,[x0]	   // Set color of pixel N

		add x0,x0,4	   // Next pixel
		sub x1,x1,1	   // decrement X counter
		cbnz x1,super_loop0	   // If not end row jump
	ret // b lr

draw_rect: // x0: X, x1: Y, x2: W, x3: H, x4: Color

_draw_rect_loop_fila:
	mov	   x5, SCREEN_WIDTH				// X5: SCREEN_WIDTH
	mul    x5, x1, x5					// Numero del 1er pixel de la fila Y
	add    x5, x5, x0					// Numero del 1er pixel de la fila Y + X
	lsl	   x5, x5, #2					// Direccion relativa del pixel
	add    x5, x5, x20					// Direc rel pixel + base = Direc abs pixel
	mov    x6, x2						// Contador X
_draw_rect_loop_col:
		str x4, [x5]					// Set color of pixel in X5
		add x5, x5, #4					// Avanza al pixel siguiente en X
		sub x6, x6, #1					// Decrementa contador X
		cbnz x6, _draw_rect_loop_col
	add x1, x1, #1						// Pintar Xs siguientes
	sub x3, x3, #1						// Decremanta la altura, porque ya se pinto una fila
	cbnz x3, _draw_rect_loop_fila

	ret

draw_trian: // x0: X, x1: Y, x2: B, x3: H, x4: Color
		   
_draw_trian_loop_fila: 
	mov	   x5, SCREEN_WIDTH
	mul    x5, x1, x5
	add    x5, x5, x0
	lsl	   x5, x5, #2
	add    x5, x5, x20
	add	   x2,x2,  #1
	mov    x6, x2

_draw_trian_loop_col:
		str x4, [x5]
		add x5, x5, #4
		sub x6, x6, #1
		cbnz x6, _draw_trian_loop_col
	add x1, x1, #1
	sub x3, x3, #1
	cbnz x3, _draw_trian_loop_fila
	ret

draw_trian_left: // x0: X, x1: Y, x2: B, x3: H, x4: Color
		   
_draw_trian_left_loop_fila: 
	mov	   x5, SCREEN_WIDTH
	mul    x5, x1, x5
	sub	   x0, x0, #1
	add    x5, x5, x0
	lsl	   x5, x5, #2
	add    x5, x5, x20
	add	   x2,x2,  #1
	mov    x6, x2

_draw_trian_left_loop_col:
		str x4, [x5]
		add x5, x5, #4
		sub x6, x6, #1
		cbnz x6, _draw_trian_left_loop_col
	add x1, x1, #1
	sub x3, x3, #1
	cbnz x3, _draw_trian_left_loop_fila
	ret
