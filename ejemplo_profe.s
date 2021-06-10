.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32

.globl main
main:
	mov x20, x0 			// Guarda el framebuffer en X20
	mov x19, #0				// Inicializa el contador X19 para el movimiento del cuadrado

animation:
	bl clear_screen

	movz x0, 100			// X0: X
	movz x1, 100			// X1: Y
	movz x2, 200			// X2: W
	movz x3, 300			// X3: H
	mov x4, 0xFF0000		// X4: Color
	bl draw_rect

	mov x0, x19				// XO: X = X19 (Movimiento)
	movz x1, 150			// X1: Y
	movz x2, 100			// X2: W
	movz x3, 50				// X3: H
	mov x4, 0x00FF00		// X4: Color
	bl draw_rect
	//-------------	--------------------------------------------------
	// Infinite Loop
	add x19, x19, #1		// X + 1
	mov x0, 0xFFFFF			// Cantidad delay
	bl delay
	b animation

InfLoop:
	b InfLoop

clear_screen:
	mov x0, x20				// Restaura base de Framebuffer a X0

	mov x2, 0xFFFFFF   		// 0xFFFFFF = BLANCO
	movz x1, 0xB000			// X1 parte baja
	movk x1, 0x4, LSL #16	// X1 = 0x4B000 (cantidad pixelex)

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