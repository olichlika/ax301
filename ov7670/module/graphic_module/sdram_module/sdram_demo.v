module sdram_demo(
   input clk,
   input rst_n,
	output S_CLK,
	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE,
	output [12:0] S_A, 
   output [1:0] S_BA,
   output [1:0] S_DQM,
   inout [15:0] S_DQ,
	output [2:0] led
);

wire clk_100mhz/*synthesis keep*/;
wire clk_100mhz_180;

pll_module u0(
	.inclk0 (clk),
	.c0 (clk_100mhz),
	.c1 (clk_100mhz_180)
);

wire [2:0] DoneU1; //完成信号
wire EnU1;
wire [15:0] DataU1;

sdram_top_mdule u1(
	.iClock ({clk_100mhz, clk_100mhz_180}),
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
	
	.iCall (isCall),
	.oEn (EnU1),
	.oDone (DoneU1),
	.iAddr (D1),
	.iAddrPage (D1),
	.iData (D2),
	.oData (DataU1)
);

reg [2:0] isCall;
reg [23:0] D1; //地址信号
reg [15:0] D2; //输入数据

reg [5:0]i;
reg [2:0] rled;

reg [27:0] C1;//节拍计数器

parameter T1S = 28'd1_0000_0000;

always @(posedge clk_100mhz or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= 6'd0;
			isCall <= 3'd0;
			D1 <= 24'd0;
			D2 <= 16'd0;
			C1 <= 28'd0;
			rled <= 3'b000;
		end
   else
		case(i)
			0://wait 1s
				if(C1 == T1S - 1)
					begin
						C1 <= 28'd0;
						i <= i + 1'b1; 
					end
				else
					C1 <= C1 + 1'b1;
				
			1://写512个字
				if(DoneU1[1])
					begin 
						isCall[1] <= 1'b0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						isCall[1] <= 1'b1;
						D1 <= {15'd0, C1[8:0]}; 
						D2 <= {7'd0, C1[8:0]};
					end					
			2://循环写
				if(C1 == 512 - 1)
					begin 
						C1 <= 28'd0;
						i <= i + 1'b1;
					end
				else 
					begin 
						C1 <= C1 + 1'b1;
						i <= 6'd1;
					end
			3://页读
				if(DoneU1[2])
					begin 
						isCall[2] <= 1'b0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						isCall[2] <= 1'b1;
						D1 <= 24'd0;
					end
			4:
				i <= i;
		endcase
end


assign led = rled;

endmodule
