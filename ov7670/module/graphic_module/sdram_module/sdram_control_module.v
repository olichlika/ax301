module sdram_control_module(
   input clk,
   input rst_n,
   input [2:0] iCall, // [1]Write, [0]Read 外部控制信号
	output [2:0] oDone, //输出给上层 完成信号
	
   input iDone, //Func module过来的完成信号
   output [4:0] oCall //Func module控制信号
);

parameter IDLE = 4'd0, GREAD = 4'd1, WRITE = 4'd4, READ = 4'd7, REFRESH = 4'd10, INITIAL = 4'd11;
parameter TREF = 11'd750;

reg [3:0] i;
reg [10:0] C1;
reg [4:0] isCall;
reg [2:0] isDone;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= INITIAL;//先进性初始化
			C1 <= 11'd0;
			isCall <= 5'd0;
			isDone <= 3'd0;
		end
   else
		case(i)
			IDLE://等待刷新 或者 写 读信号
				if(C1 >= TREF)
					begin
						C1 <= 11'd0;
						i <= REFRESH;
					end
				else if(iCall[2]) //页读
					begin 
						C1 <= TREF; 
						i <= GREAD; 
					end				
				else if(iCall[1]) //单字节写
					begin 
						C1 <= C1 + 1'b1; 
						i <= WRITE; 
					end
				else if(iCall[0]) //单字节读
					begin 
						C1 <= C1 + 1'b1; 
						i <= READ; 
					end 
            else 
					begin 
						C1 <= C1 + 1'b1; 
					end
			GREAD://页读
				if(iDone)
					begin 
						isCall[4] <= 1'b0; 
						C1 <= C1 + 1'b1; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						isCall[4] <= 1'b1; 
						C1 <= C1 + 1'b1; 
					end
			2:
				begin 
					isDone[2] <= 1'b1; 
					C1 <= C1 + 1'b1; 
					i <= i + 1'b1; 
				end
			3:
				begin 
					isDone[2] <= 1'b0; 
					C1 <= C1 + 1'b1; 
					i <= IDLE;//返回空闲状态
				end				
			WRITE://写入操作
				if(iDone) 
					begin 
						isCall[3] <= 1'b0; 
						C1 <= C1 + 1'b1; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						isCall[3] <= 1'b1; 
						C1 <= C1 + 1'b1; 
					end
			5:
				begin 
					isDone[1] <= 1'b1; 
					C1 <= C1 + 1'b1; 
					i <= i + 1'b1; 
				end
			6:
				begin 
					isDone[1] <= 1'b0; 
					C1 <= C1 + 1'b1; 
					i <= IDLE;//返回空闲状态
				end
			READ://读操作
				if(iDone) 
					begin 
						isCall[2] <= 1'b0; 
						C1 <= C1 + 1'b1; 
						i <= i + 1'b1; 
					end
				else 
					begin 
						isCall[2] <= 1'b1; 
						C1 <= C1 + 1'b1; 
					end
			8:
				begin 
					isDone[0] <= 1'b1; 
					C1 <= C1 + 1'b1; 
					i <= i + 1'b1; 
				end
			9:
				begin 
					isDone[0] <= 1'b0; 
					C1 <= C1 + 1'b1; 
					i <= IDLE;//返回空闲状态
				end
			REFRESH://刷新操作
				if(iDone)
					begin 
						isCall[1] <= 1'b0; 
						i <= IDLE;//返回空闲状态
					end
				else 
					begin 
						isCall[1] <= 1'b1; 
					end
			INITIAL: // Initial 
				if(iDone)
					begin 
						isCall[0] <= 1'b0; 
						i <= IDLE;//返回空闲状态
					end
				else 
					begin 
						isCall[0] <= 1'b1; 
					end
		endcase
end

assign oCall = isCall;
assign oDone = isDone;

endmodule
