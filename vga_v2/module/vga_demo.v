module vga_demo(
   input clk,
   input rst_n,
   output VGA_HSYNC, VGA_VSYNC,
   output [15:0] VGAD
);

wire clk_25mhz;

pll_module u1(
	.inclk0 (clk),
	.c0 (clk_25mhz)
);

vga_func_module u2(
	.clk (clk_25mhz),
	.rst_n (rst_n),
	.VGA_HSYNC (VGA_HSYNC),
	.VGA_VSYNC (VGA_VSYNC),
	.VGAD (VGAD)
);

endmodule
