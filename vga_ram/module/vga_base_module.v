module vga_base_module(
   input [1:0] clk, // 100M, 25Mhz
   input rst_n,
   input iEn, //写ram使能
   input [15:0] iData, //写入数据
   output [10:0] oTag,//到SDRAM通知写入
   output VGA_HSYNC, VGA_VSYNC,
   output [15:0] VGAD
);

wire [15:0] DataU1;

vga_ram_module U1(
	.clk (clk),
	.rst_n (rst_n),
	.iEn({iEn, EnU2}),  // [1]write, [0]Read
	.iData (iData),
	.oData (DataU1)
);

wire EnU2;

vga_func_module U2(
	.clk (clk[0]),
	.rst_n (rst_n),
	.oEn (EnU2),
	.iData (DataU1),
	.oTag (oTag),
	.VGA_HSYNC (VGA_HSYNC), 
	.VGA_VSYNC (VGA_VSYNC),
   .VGAD (VGAD)
);

endmodule
