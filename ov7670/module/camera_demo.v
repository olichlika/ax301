module camera_demo(
   input clk,
   input rst_n,

	//SDRAM输出引脚
	output S_CLK,
	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE,
	output [12:0] S_A, 
   output [1:0] S_BA,
   output [1:0] S_DQM,
   inout [15:0] S_DQ,
	
	//VGA输出脚
	output VGA_HSYNC, VGA_VSYNC,
	output [15:0] VGAD,	
	
	//OV7670输出脚
	output CMOS_SCL,
	inout CMOS_SDA,
   output CMOS_XCLK,
	input CMOS_PCLK,
	input CMOS_HREF,
	input CMOS_VSYNC,
	input [7:0] CMOS_DQ,
	//input CMOS1_STROBE,
	output test_CMOS_SCL, test_CMOS_SDA
);
assign test_CMOS_SCL = CMOS_SCL;
assign test_CMOS_SDA = CMOS_SDA;

wire CLOCK_MAIN, CLOCK_SDRAM, CLOCK_VGA;

pll_module U0(
	.inclk0 (clk),
	.c0 (CLOCK_MAIN),
	.c1 (CLOCK_SDRAM),
	.c2 (CLOCK_VGA),
);

wire [35:0] DataU1/*synthesis keep*/; //[35:26]X [25:16]Y [15:0]Color Data

camera_base_module U1(
   .clk (CLOCK_MAIN),
   .rst_n (rst_n),
	
	.CMOS_SCL (CMOS_SCL),
	.CMOS_SDA (CMOS_SDA),
   .CMOS_XCLK (CMOS_XCLK),
	.CMOS_PCLK (CMOS_PCLK),
	.CMOS_HREF (CMOS_HREF),
	.CMOS_VSYNC (CMOS_VSYNC),
	.CMOS_DQ (CMOS_DQ),
	.iEn (isEn),
	.oData (DataU1)
);
//	 camera_basemod U1
//	 (
//	     .CLOCK( CLOCK_MAIN ), 
//		  .RESET( rst_n ),
//	     .CMOS1_SCL( CMOS_SCL ),
//	     .CMOS1_SDA( CMOS_SDA ),
//        .CMOS1_XCLK( CMOS_XCLK ),
//	     .CMOS1_PCLK( CMOS_PCLK ),
//	     .CMOS1_HREF( CMOS_HREF ),
//	     .CMOS1_VSYNC( CMOS_VSYNC ),
//	     .CMOS1_DQ( CMOS_DQ ),
//	     .CMOS1_STROBE(  ),
//	     .CMOS1_PWDN( ),
//	     .iEn( isEn ),
//	     .oData( DataU1 )
//	 );    


wire [1:0] DoneU2;

wire [15:0] DataU2;

graphic_module U2(
	.rst_n( rst_n ),  
	.S_CLK ( S_CLK ),
	.S_CKE( S_CKE ),
	.S_NCS( S_NCS ),
	.S_NRAS( S_NRAS ),
	.S_NCAS( S_NCAS ),
	.S_NWE( S_NWE ),
	.S_A( S_A ),
	.S_BA( S_BA ),
	.S_DQM( S_DQM ),
	.S_DQ( S_DQ ),
	.VGA_HSYNC( VGA_HSYNC ), 
	.VGA_VSYNC( VGA_VSYNC ) ,
	.iClock( { CLOCK_MAIN,CLOCK_SDRAM,CLOCK_VGA } ),
	.VGAD( VGAD ),
	.iCall( isCall ),      // [1]Write , [0]Read
	.oDone( DoneU2 ),        
	.iAddr( D1 ),          // [23:0]
	.iData( D2 ),          // [15:0]
	.oData( DataU2 )	
);

reg [7:0] i;
reg [23:0] D1;//地址
reg [15:0]D2;//数据
reg [1:0] isCall;
reg [8:0] CX;//列地址
reg [14:0] CY;//行地址
reg isEn;//读camera

always @(posedge CLOCK_MAIN or negedge rst_n)
	if(!rst_n)
		begin
			i <= 8'd0;
			isCall <= 2'b00;
			D1 <= 24'd0;
			D2 <= 16'd0;
			CX <= 9'd0;
			CY <= 15'd0;
			isEn <= 1'b0;			
		end
	else
		case(i)
			0:	
				begin 
					isEn <= 1'b1;
					i <= i + 1'b1;
//					if(DoneU2[1]) //写完成
//						begin 
//							isCall[1] <= 1'b0; 
//							i <= i + 1'b1; 
//						end
//					else 
//						begin 
//							isCall[1] <= 1'b1; //写数据
//							D1 <= {CY, CX};
//							D2 <= {5'd31, 6'd0, 5'd0 }; 
//						end//16'hAAAA;end//{5'd31,6'd0,5'd0 }; end // 7'd0,CX					
				end
			1:
				begin
					isEn <= 1'b0;//输出数据 关闭
					if(DoneU2[1]) //写完成
						begin 
							isCall[1] <= 1'b0; 
							i <= 4'd0; //读下一位数据
						end
					else 
						begin 
							isCall[1] <= 1'b1; //写数据
							D1 <= {5'b00000, DataU1[25:16], DataU1[34:26]};//[35:26]X [25:16]Y [15:0]Color Data -> {15, 9}
							D2 <= DataU1[15:0]; 
						end//16'hAAAA;end//{5'd31,6'd0,5'd0 }; end // 7'd0,CX							
				end
			
		endcase
//reg [3:0]i;
//reg isEn/*synthesis keep*/;
//
//always @(posedge CLOCK_MAIN or negedge rst_n) begin
//   if(!rst_n)
//		begin
//			i <= 4'd0;
//			isEn <= 1'b0;
//		end
//   else
//		case(i)
//			0:	
//				begin isEn <= 1'b1; i <= i + 1'b1; end
//			1:
//				begin isEn <= 1'b0; i <= 4'd0; end				
//		endcase
//end
	 
endmodule
