module graphic_module(
   input [2:0] iClock,// Main Clock 100Mhz, sdram_clock 100Mhz 180, vga_clock 25Mhz;
   input rst_n,
	
	//外部输入脚
	input [23:0] iAddr, //单字节操作地址
	input [15:0] iData,
	input [1:0] iCall,// [1]Write, [0]Read
	
	//外部输出引脚
	output [1:0] oDone,//单字节 写 读完成
	output [15:0] oData,//输出数据脚
	
	//SDRAM输出引脚
	output S_CLK,
	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE,
	output [12:0] S_A, 
   output [1:0] S_BA,
   output [1:0] S_DQM,
   inout [15:0] S_DQ,
	
	//VGA输出脚
	output VGA_HSYNC, VGA_VSYNC,
	output [15:0] VGAD
);
//*************实例化SDRAM模块*************
wire EnU1;
wire [2:0] DoneU1;
wire [15:0] DataU1;//SDRAM输出的数据

sdram_top_mdule U1(
	.iClock (iClock[2:1]),
	.rst_n (rst_n),
	
	.S_CLK (S_CLK),
	.S_CKE( S_CKE ),
	.S_NCS( S_NCS ), 
	.S_NRAS( S_NRAS ),
	.S_NCAS( S_NCAS ),
	.S_NWE( S_NWE ),
	.S_BA( S_BA ),
	.S_A( S_A ),
	.S_DQM( S_DQM ),
	.S_DQ( S_DQ ),
	
	.iCall (isCall ? {isCall, 2'b00} : {1'b0, iCall}),
	.oEn (EnU1), // > U2 (写VGA RAM使能) 页读有效信号
	.oDone (DoneU1), //页读完成 写完成 读完成 信号
	.iAddr (iAddr),
	.iAddrPage (D1),
	.iData (iData),
	.oData (DataU1)
);
wire isDone = DoneU1[2];
assign oDone = DoneU1[1:0];   // top
assign oData = DataU1;
//*************实例化VGA模块*************
wire [10:0] TagU2;

vga_base_module U2(
	.clk ({iClock[2], iClock[0]}),
	.rst_n (rst_n),
	.iEn (EnU1),
	.iData (DataU1),
	.oTag (TagU2),// [10] Update [9:0]Clean Y
	.VGA_HSYNC (VGA_HSYNC),
	.VGA_VSYNC (VGA_VSYNC),
	.VGAD (VGAD)
);

//*************检查上升沿*************
reg [10:0] F2, F1;
always @(posedge iClock[2] or negedge rst_n) begin
   if(!rst_n)
		begin
			F1 <= 11'd0;
			F2 <= 11'd0;
		end
   else
		begin
 			F1 <= TagU2;
			F2 <= F1;			
		end
end

wire isL2H = (F2[10] == 0 && F1[10] == 1);

reg isA;

reg [9:0] CY;

always @(posedge iClock[2] or negedge rst_n) begin
   if(!rst_n)
		begin
			isA <= 1'b0; 
			CY <= 10'd0;
		end
	else if(isL2H) //检测到上升沿
		begin 
			isA <= ~isA; 
			CY <= F2[9:0]; 
		end
end

reg [3:0] i;
reg isB, isCall;
reg [23:0] D1;//页读地址寄存器

always @(posedge iClock[2] or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= 4'd0;
			isB <= 1'b0;
			isCall <= 1'b0;
			D1 <= 24'd0;
		end
   else
		case(i)
			0:
				if(isA !=isB)
					begin 
						isB <= isA; //锁起
						i <= i + 1'b1; 
					end
				else
					i <= i;
			1:
				if(isDone)
					begin 
						isCall <= 1'b0; 
						i <= 4'd0; 
					end
				else 
					begin 
						isCall <= 1'b1; 
						D1 <= {5'd0, CY, 9'd0}; 
					end			
		endcase
end

endmodule
