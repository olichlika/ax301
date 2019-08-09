module sdram_func_module(
   input clk,
   input rst_n,
	
	//到sdram信号
	output S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE, //输出命令信号
	output [1:0] S_BA,  //bank 片选
	output [12:0] S_A,  //13, CA0~CA8, RA0~RA12, BA0~BA1, 9+13+2 = 24;
	output [1:0] S_DQM,
	inout [15:0] S_DQ,//数据线
	
	//FPGA内部信号
	input [4:0] iCall,//控制信号
	input [23:0] iAddr,  // [23:22]BA,[21:9]Row,[8:0]Column 单字节读写地址
	input [23:0] iAddrPage, //页地址
	input [15:0] iData, //输入数据线
	output [15:0] oData, //输出数据线
	output oEn, //页读有效信号
	output oDone //当前操作完成信号
);
//100M时钟
parameter T100US = 14'd10000, PAGE = 14'd512;

// tRP 30ns, tRRC 100ns, tRCD 20ns, tMRD 2CLK, tWR/tDPL 2CLK, CAS Latency 3CLK
parameter TRP = 14'd3, TRRC = 14'd10, TMRD = 14'd2, TRCD = 14'd3, TWR = 14'd2, CL = 14'd3;

//command
parameter _INIT = 5'b01111, _NOP = 5'b10111, _ACT = 5'b10011, _RD = 5'b10101, _WR = 5'b10100,
	       _BSTP = 5'b10110, _PR = 5'b10010, _AR = 5'b10001, _LMR = 5'b10000;

reg [4:0] i;
reg [13:0] C1;
reg [13:0] CX; //页读计数
reg [4:0] rCMD;
reg [1:0] rBA;
reg [12:0] rA;
reg [1:0] rDQM;
reg isDone;
reg isOut;
reg [15:0] D1, D2;
reg isEn;
always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= 4'd0;
			C1 <= 14'd0;
			CX <= 14'd0;
			rCMD <= _NOP;
			rBA <= 2'b11;
			rA <= 13'h1fff;
			isDone <= 1'b0;
			rDQM <= 2'b00;
			isOut <= 1'b1; //默认写
			D1 <= 16'd0; //数据清零
			D2 <= 16'd0; //数据清零
			isEn <= 1'b0;
		end
	else if(iCall[4])//页读操作
		case(i)
			0:
				begin 
					isOut <= 1'b0; 
					//D1 <= 16'd0; 
					i <= i + 1'b1;
					isEn <= 1'b0;
				end
			1: // Send Active command with Bank and Row address
            begin 
					rCMD <= _ACT; 
					rBA <= iAddr[23:22]; 
					rA <= iAddrPage[21:9]; 
					i <= i + 1'b1;
				end
			2: // wait TRCD 20ns
				if(C1 == TRCD -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1;
					end
			3: // Send Write command with row address, pull up A10 1 clk to Auto Precharge
				begin 
					rCMD <= _RD; 
					rBA <= iAddr[23:22]; 
					rA <= {4'b0010, iAddrPage[8:0]}; 
					i <= i + 1'b1; 
				end
         4: // wait CL 3 clock CAS Latency
            if( C1 == CL -1 ) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end 				
			5: // Read Data
				begin 
					D2 <= S_DQ;
					isEn <= 1'b1;
					if(CX == PAGE -1)
						begin 
							CX <= 14'd0; 
							i <= i + 1'b1; 
						end  
					else
						CX <= CX + 1'b1;
				end
			6: // Generate done signal
				begin
					isEn <= 1'b0; 
					rCMD <= _BSTP;
					isDone <= 1'b1; 
					i <= i + 1'b1;
				end
			7:
				begin 
					rCMD <= _NOP;
					isDone <= 1'b0; 
					i <= 4'd0; 
				end				
		endcase		
	else if(iCall[3])//写操作
		case(i)
			0:
				begin 
					isOut <= 1'b1;
					i <= i + 1'b1; 
				end
			1: // Send Active command with Bank and Row address
            begin 
					rCMD <= _ACT; 
					rBA <= iAddr[23:22]; 
					rA <= iAddr[21:9]; 
					i <= i + 1'b1;
				end
			2: // wait TRCD 20ns
				if(C1 == TRCD -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1;
					end
			3:// Send Write command with columns address, pull up A10 1 clk to Auto Precharge
				begin 
					rCMD <= _WR; 
					rBA <= iAddr[23:22];//bank
					rA <= { 4'b0010, iAddr[8:0] }; 
					i <= i + 1'b1;
					D1 <= iData;
				end
			4:
				begin 
					rCMD <= _BSTP; 
					i <= i + 1'b1; 
				end
			5: // wait TWR 2 clock
				if(C1 == TWR -1)
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			6: // wait TRP 30ns
				if(C1 == TRP -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			7: // Generate done signal
				begin 
					isDone <= 1'b1; 
					i <= i + 1'b1;
				end
			8:
				begin 
					isDone <= 1'b0; 
					i <= 4'd0; 
				end				
		endcase
	else if(iCall[2])//读操作
		case(i)
			0:
				begin 
					isOut <= 1'b0; 
					D1 <= 16'd0; 
					i <= i + 1'b1; 
				end
			1: // Send Active command with Bank and Row address
            begin 
					rCMD <= _ACT; 
					rBA <= iAddr[23:22]; 
					rA <= iAddr[21:9]; 
					i <= i + 1'b1;
				end
			2: // wait TRCD 20ns
				if(C1 == TRCD -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1;
					end
			3: // Send Write command with row address, pull up A10 1 clk to Auto Precharge
				begin 
					rCMD <= _RD; 
					rBA <= iAddr[23:22]; 
					rA <= {4'b0010, iAddr[8:0]}; 
					i <= i + 1'b1; 
				end
         4: // wait CL 3 clock CAS Latency
            if( C1 == CL -1 ) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end 				
			5: // Read Data
				begin 
					D2 <= S_DQ; 
					i <= i + 1'b1; 
				end
			6:
				begin 
					rCMD <= _BSTP; 
					i <= i + 1'b1; 
				end
			7: // Generate done signal
				begin
					rCMD <= _NOP;
					isDone <= 1'b1; 
					i <= i + 1'b1;
				end
			8:
				begin 
					isDone <= 1'b0; 
					i <= 4'd0; 
				end				
		endcase
	else if(iCall[1])//刷新
		case(i)
			0:// Send Precharge Command
				begin
					rCMD <= _PR; 
					{rBA, rA} <= 15'h7fff; 
					i <= i + 1'b1; 
				end
			1: // wait TRP 30ns
				if(C1 == TRP -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			2: // Send Auto Refresh Command
				begin 
					rCMD <= _AR; 
					i <= i + 1'b1; 
				end
			3: // wait TRRC 63ns
				if(C1 == TRRC -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			4: // Send Auto Refresh Command
				begin 
					rCMD <= _AR; 
					i <= i + 1'b1; 
				end
			5: // wait TRRC 63ns
				if(C1 == TRRC -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			6: // Generate done signal
				begin 
					isDone <= 1'b1; 
					i <= i + 1'b1;
				end
			7:
				begin 
					isDone <= 1'b0; 
					i <= 4'd0; 
				end			
		endcase
   else if(iCall[0])//初始化
		case(i)
			0:// delay 100us
				if(C1 == T100US -1)
					begin
						C1 <= 14'd0; 
						i <= i + 1'b1;
					end
				else
					C1 <= C1 + 1'b1;
			1:// Send Precharge Command
				begin
					rCMD <= _PR; 
					{rBA, rA} <= 15'h7fff; 
					i <= i + 1'b1; 
				end
			2: // wait TRP 30ns
				if(C1 == TRP -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			3: // Send Auto Refresh Command
				begin 
					rCMD <= _AR; 
					i <= i + 1'b1; 
				end
			4: // wait TRRC 63ns
				if(C1 == TRRC -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			5: // Send Auto Refresh Command
				begin 
					rCMD <= _AR; 
					i <= i + 1'b1; 
				end
			6: // wait TRRC 63ns
				if(C1 == TRRC -1) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			7: // Send LMR Cmd. Burst Read & Write,  3'b010 mean CAS latecy = 3, Sequential, 1 burst length
				begin 
					rCMD <= _LMR; 
					rBA <= 2'b11; 
					rA <= {3'd0, 1'b0, 2'd0, 3'b011, 1'b0, 3'b111}; 
					i <= i + 1'b1; 
				end
			8: // Send 2 nop CLK for tMRD
				if( C1 == TMRD -1 ) 
					begin 
						C1 <= 14'd0; 
						i <= i + 1'b1; 
					end
            else 
					begin 
						rCMD <= _NOP; 
						C1 <= C1 + 1'b1; 
					end
			9: // Generate done signal
				begin 
					isDone <= 1'b1; 
					i <= i + 1'b1;
				end
			10:
				begin 
					isDone <= 1'b0; 
					i <= 4'd0; 
				end
		endcase
end

assign {S_CKE, S_NCS, S_NRAS, S_NCAS, S_NWE} = rCMD;
assign {S_BA, S_A} = {rBA, rA};
assign oDone = isDone;
assign S_DQM = rDQM;
assign S_DQ = isOut ? D1 : 16'hzzzz;
assign oData = D2;
assign oEn = isEn;

endmodule
