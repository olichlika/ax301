module sdram_top_mdule(
   input rst_n,

	//到sdram信号
	output S_CLK, //SDRAM时钟
	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE, //输出命令信号
	output [1:0] S_BA,  //bank 片选
	output [12:0] S_A,  //13, CA0~CA8, RA0~RA12, BA0~BA1, 9+13+2 = 24;
	output [1:0] S_DQM,
	inout [15:0] S_DQ,//数据线
	
	//控制信号
	input [1:0] iClock,  // Main Clock , Sdram Clock
	input [2:0] iCall, //[2]page read [1]Write, [0]Read 外部控制信号
	output [2:0] oDone, //输出给上层 完成信号
	output oEn, //页读有效信号
	input [23:0] iAddr,
	input [23:0] iAddrPage,
	input [15:0] iData,
	output [15:0] oData
);

wire [4:0] CallU1; //Func module控制信号

sdram_control_module u1(
	.clk (iClock[1]),
	.rst_n (rst_n),
	.iCall (iCall), // < top
	.iDone (DoneU2), // < U2
	.oDone (oDone), // > top 
	.oCall (CallU1) // > U2 
);

wire DoneU2;

sdram_func_module u2(
	.clk (iClock[1]),
	.rst_n (rst_n),

	.S_CKE( S_CKE ),   // > top
	.S_NCS( S_NCS ),   // > top
	.S_NRAS( S_NRAS ), // > top
	.S_NCAS( S_NCAS ), // > top
	.S_NWE( S_NWE ), // > top
	.S_BA( S_BA ),   // > top
	.S_A( S_A ),     // > top
	.S_DQM( S_DQM ), // > top
	.S_DQ( S_DQ ),   // <> top  
	
	.iCall (CallU1),
	.iAddr (iAddr),
	.iAddrPage (iAddrPage),
	.iData (iData),
	.oData (oData),
	.oEn (oEn),
	.oDone (DoneU2)
);

assign S_CLK = iClock[1];

endmodule
