module vga_func_module(
   input clk, //25MHZ
   input rst_n,
   output VGA_HSYNC, VGA_VSYNC,
   output [15:0] VGAD,
	output oEn, //从ram里读使能
	input [15:0] iData, //ram输出数据总线
	output [10:0] oTag //通知sdram转载信号线 使能、第几行
);

parameter FRAME_DELAY = 8'd60;//延迟显示的帧数

parameter SA = 10'd96, SB = 10'd48, SC = 10'd640, SD = 10'd16, SE = 10'd800;

parameter SO = 10'd2, SP = 10'd33, SQ = 10'd480, SR = 10'd10, SS = 10'd525;

parameter XSIZE = 10'd320, YSIZE = 10'd240, XOFF = 10'd0, YOFF = 10'd0;//显示区间 320x240 不能超过640x480

//*************延迟信号*************
reg isON; //开关显示信号
reg [7:0] CF; //计数器

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			isON <= 1'b0;
			CF <= 8'd0;
		end
   else if(CF == FRAME_DELAY-1)
		begin
			CF <= 8'd0;
			isON <= 1'b1; //使能显示
		end
	else if(CV == SS-1 && !isON)
		CF <= CF + 1'b1;
		
end
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
wire isX = ((CH >= SA + SB - 1) && (CH <= SA + SB + XSIZE - 1)) && isON;
wire isY = ((CV >= SO + SP - 1) && (CV <= SO + SP + YSIZE - 1)) && isON;

//*************产生RAM读信号*************
wire isStart = (CH == SA + SB - 1 - 2 );
wire isStop = (CH == SA + SB + XSIZE - 1 - 2);

reg isEn;
reg [15:0] D1;

always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			D1 <= 16'd0;
			isEn <= 1'b0;
		end
   else
		begin
			if(isStart && isY) //有效行 开始有效列的时候
				isEn <= 1'b1; 
			else if(isStop && isY)
				isEn <= 1'b0;
			D1 <= (isX && isY) ? iData : 16'd0;
		end
end

//*************产生通知SDRAM转载信号*************
reg isUpdate;
reg [9:0] CY;
always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin 
			isUpdate <= 1'b0; 
			CY <= 10'd0; 
		end
   else if(isY && CH == 1)
		begin
			isUpdate <= 1'b1;
			CY <= (CV - (SO + SP) +1); //转载第几行
		end
	else
		isUpdate <= 1'b0;
end


assign VGA_HSYNC = H;

assign VGA_VSYNC = V;

assign VGAD = D1;

assign oEn = isEn;

assign oTag [10] = isUpdate;
assign oTag [9:0] = CY;

endmodule
