`timescale 1ns/1ns

module sccb_func_module_tb();

parameter T=10; //100MHZ

reg clk;

reg rst_n;

reg iCall;

reg [15:0] iData;

wire CMOS_SCL;

wire CMOS_SDA;

wire oDone;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	iCall = 1'b0;
	iData = 16'd0;
	#100
	rst_n = 1'b1;
end


always #(T/2) clk = ~clk;

sccb_func_module u0(
	.clk (clk),
	.rst_n (rst_n),
	.iCall (iCall),
	.iData (iData),
	.CMOS_SCL (CMOS_SCL),
	.CMOS_SDA (CMOS_SDA),
	.oDone (oDone)
);

/* reg [3:0] i;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		i <= 4'd0;
	else
		case(i)
			0:
				begin
					if(oDone)
					else
						
				end	
		endcase
end */
reg [3:0] i;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		i <= 4'd0;
	else if(oDone)
		begin
			iCall <= 1'b0;
			iData <= 16'd0;
			$stop;
		end
	else
		begin
			iCall <= 1'b1;
			iData <= 16'hC7;
		end
end

endmodule
