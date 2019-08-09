`timescale 1ns/1ns

module vga_demo_tb();

parameter T = 20;

reg clk;

reg rst_n;

wire VGA_HSYNC;
wire VGA_VSYNC;
wire [15:0] VGAD

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	#(T+1)
	rst_n = 1'b1;
	#(1000 * 1000 * 2000)
    $finish;
end


always #(T/2) clk = ~clk;

vga_demo u0(
	.clk (clk),
	.rst_n (rst_n),
	.VGA_HSYNC (VGA_HSYNC),
	.VGA_VSYNC (VGA_VSYNC),
	.VGAD (VGAD)
);

endmodule
