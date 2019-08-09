module sccb_func_module(
   input clk,//100M
   input rst_n,
   input iCall,
   input [15:0] iData,
   output oDone,
   output CMOS_SCL, 
	inout CMOS_SDA
);

parameter FCLK = 16'd10000, FHALF = 16'd5000, FQUARTER = 16'd2500;
parameter FF_WR = 5'd7;

reg [4:0] i;
reg [4:0] Go;
reg [15:0] C1;//计算器
reg isQ; //SDA OUTPUT INPUT FLAG
reg rSCL, rSDA;
reg [7:0] D; //数据寄存器
reg isAck;
reg isDone;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= 5'd0;
			Go <= 5'd0;
			C1 <= 16'd0;
			isQ <= 1'b1;
			rSCL <= 1'b1;
			rSDA <= 1'b1;
			D <= 8'd0;
			isAck <= 1'b1;
			isDone <= 1'b0;
		end
   else if(iCall)//write
		case(i)
			0://start
				begin
					isQ <= 1'b1;
					rSCL <= 1'b1;
					
					if(C1 == 0) rSDA <= 1'b1;
					else if(C1 == FHALF) rSDA <= 1'b0;
					
					if(C1 == (FCLK - 1)) begin C1 <= 16'd0; i <= i + 1'b1; end
					else C1 <= C1 + 1'b1;
				end
			1://write device addr
				begin
					D <= 8'h42; //固定
					i <= FF_WR; //写步骤
					Go <= i + 1'b1;//传输完8字节进行下一步
				end
			2://write reg addr
				begin
					D <= iData[15:8];
					i <= FF_WR; //写步骤
					Go <= i + 1'b1;//传输完8字节进行下一步
				end
			3://write reg data
				begin
					D <= iData[7:0];
					i <= FF_WR; //写步骤
					Go <= i + 1'b1;//传输完8字节进行下一步
				end
			4://stop
				begin
					isQ <= 1'b1;
					
					if(C1 == 0) rSCL <= 1'b0;
					else if(C1 == FQUARTER) rSCL <= 1'b1;
					
					if(C1 == 0) rSDA <= 1'b0;
					else if(C1 == (FQUARTER + FHALF)) rSDA <= 1'b1;
					
					if(C1 == (FQUARTER + FCLK - 1)) begin C1 <= 16'd0; i <= i + 1'b1; end
					else C1 <= C1 + 1'b1;
				end
			5:
				begin
					isDone <= 1'b1;
					i <= i + 1'b1;
				end
			6:
				begin
					isDone <= 1'b0;
					i <= 5'd0;
				end				
			7, 8, 9, 10, 11, 12, 13, 14:
				begin
					isQ <= 1'b1;
					rSDA <= D[14 - i];
					
					if(C1 == 0) rSCL <= 1'b0;
					else if(C1 == FQUARTER) rSCL <= 1'b1;
					else if(C1 == FQUARTER + FHALF) rSCL <= 1'b0;
					
					if(C1 == (FCLK - 1)) begin C1 <= 16'd0; i <= i + 1'b1; end
					else C1 <= C1 + 1'b1;					
				end
			15: //waiting for ack
				begin
					isQ <= 1'b0;//输入
					
					if(C1 == FHALF) isAck <= CMOS_SDA;

					if(C1 == 0) rSCL <= 1'b0;
					else if(C1 == FQUARTER) rSCL <= 1'b1;
					else if(C1 == FQUARTER + FHALF) rSCL <= 1'b0;
					
					if(C1 == (FCLK - 1)) begin C1 <= 16'd0; i <= i + 1'b1; end
					else C1 <= C1 + 1'b1;					
				end
			16: //judge for ack
				if(isAck != 0) i <= 5'd0;//重新开始
				else i <= Go;
		endcase
end

assign CMOS_SDA = isQ ? rSDA : 1'bz;
assign CMOS_SCL = rSCL;
assign oDone = isDone;

endmodule
