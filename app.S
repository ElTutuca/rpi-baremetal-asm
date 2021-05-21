
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32


.global app
app:
	// X0 contiene la direccion base del framebuffer
	
	//---------------- CODE HERE ------------------------------------
	
	mov x10, 0x0FF000    // 0xF800 = RED
	mov x2,SCREEN_HEIGH         // Y Size 
loop1:
	mov x1,SCREEN_WIDTH         // X Size
loop0:
	stur x10,[x0]	   // Set color of pixel N
	//add x10,x10,1	   // Set color of pixel N
	add x0,x0,4	   // Next pixel
	sub x1,x1,1	   // decrement X counter
	cbnz x1,loop0	   // If not end row jump
	sub x2,x2,1	   // Decrement Y counter
	cbnz x2,loop1	   // if not last row, jump

	//---------------------------------------------------------------
	// Infinite Loop 
	adr x0, SALUDO
	bl uart_puts
InfLoop: 
	b InfLoop

SALUDO:
  .string "Test UART\nline\n"	