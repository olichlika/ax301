module vga_func_module(
   input clk,
   input rst_n,
   output VGA_HSYNC, VGA_VSYNC,
   output [15:0] VGAD
);

parameter SA = 10'd96, SB = 10'd48, SC = 10'd640, SD = 10'd16, SE = 10'd800;
parameter SO = 10'd2, SP = 10'd33, SQ = 10'd480, SR = 10'd10, SS = 10'd525;

//*************列同步信号*************
reg [9:0] CH;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		CH <= 10'd0;
   else if(CH == SE-1)
		CH <= 10'd0;
	else
		CH <= CH + 1'b1;
end

reg H;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		H <= 1'b0;
   else if(CH == SA-1)
		H <= 1'b1;
	else if(CH == SE-1)
		H <= 1'b0;
	else
		H <= H;
end

//*************行同步信号*************
reg [9:0] CV;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		CV <= 10'd0;
   else if(CV == SS-1)
		CV <= 10'd0;
	else if(CH == SE-1)
		CV <= CV + 1'b1;
	else
		CV <= CV;
end

reg V;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		V <= 1'b0;
   else if(CV == SO-1)
		V <= 1'b1;
	else if(CV == SS-1)
		V <= 1'b0;
	else
		V <= V;
end

//*************有效信号*************
wire isX = ((CH >= SA + SB - 1) && (CH <= SA + SB + SC - 1));
wire isY = ((CV >= SO + SP - 1) && (CV <= SO + SP + SQ - 1));

reg [15:0] D1;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		D1 <= 16'd0;
   else
		D1 <= (isX && isY) ? {5'd127,6'd127,5'd0} : 16'd0;
end

assign VGA_HSYNC = H;

assign VGA_VSYNC = V;

assign VGAD = D1;


endmodule
