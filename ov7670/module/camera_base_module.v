module camera_base_module(
   input clk, //100mhz
   input rst_n,
   output CMOS_SCL, 
	inout CMOS_SDA,
	output CMOS_XCLK,
	input CMOS_PCLK,
	input CMOS_HREF,
	input CMOS_VSYNC,
	input [7:0] CMOS_DQ,

	input iEn,
	output [35:0] oData //读出数据
	 
	//output test_CMOS_SCL, test_CMOS_SDA, test_EN
);
//assign test_CMOS_SCL = CMOS_SCL;
//assign test_CMOS_SDA = CMOS_SDA;
//assign test_EN = EnU1;

//wire clk_100mhz/*synthesis keep*/;
//wire clk_25mhz;
//
//pll_module U0(
//	.inclk0 (clk),
//	.c0 (clk_100mhz),
//	.c1 (clk_25mhz)
//);

wire [15:0] DataU1/*synthesis keep*/;
wire CallU1/*synthesis keep*/;
wire EnU1/*synthesis keep*/;

camera_control_module U1(
   .clk (clk),
   .rst_n (rst_n),
   .iDone (DoneU2),
   .oCall (CallU1),
   .oData (DataU1),
   .oEn (EnU1)
);

wire DoneU2/*synthesis keep*/;

sccb_func_module U2(
   .clk (clk),
   .rst_n (rst_n),
   .iCall (CallU1),
   .iData (DataU1),
   .oDone (DoneU2),
   .CMOS_SCL (CMOS_SCL), 
	.CMOS_SDA (CMOS_SDA)
);

wire EnU3;
wire [35:0] DataU3;
 
camera_func_module U3(
	.clk (clk),
	.rst_n (rst_n),
	.CMOS_PCLK (CMOS_PCLK),
	.CMOS_HREF (CMOS_HREF),
	.CMOS_VSYNC (CMOS_VSYNC),
	.CMOS_DQ (CMOS_DQ),
	.iEn (EnU1),
	.oEn (EnU3),
	.oData (DataU3)
);

camera_save_module U4(
	.clk (clk),
	.rst_n (rst_n),
	.iEn ({EnU3, iEn}),  // [1]Write [0]Read
	.iData (DataU3),
	.oData (oData)
);
	 
reg C;
always @(posedge clk)
	C <= ~C;
	
assign CMOS_XCLK = C;

endmodule
