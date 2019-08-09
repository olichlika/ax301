module vga_ram_module(
   input [1:0] clk,//[1]写时钟 100m [0]vga时钟 25M
   input rst_n,
   input [1:0] iEn, // [1]Write ,[0]Read,
   input [15:0] iData, //sdram写入数据线
   output [15:0] oData //ram读出到vga模块
);

parameter XSIZE = 10'd512; //sdram页写的长度

(* ramstyle = "no_rw_check , m9k" *) reg [15:0] RAM [1023:0]; //定义一个RAM空间

//*************VGA读数据*************
reg [9:0] RP;//读指针
reg [15:0] D1; //输出数据

always @(posedge clk[0] or negedge rst_n) begin
   if(!rst_n)
		begin
			RP <= 10'd0;
			D1 <= 16'd0;
		end
	else if(iEn[0])
		begin 
			RP <= RP + 1'b1; 
			D1 <= RAM[RP];
		end		
	else
		begin
			RP <= 10'd0;
			D1 <= 16'd0;
		end		
end

//*************SDRAM写数据*************
reg [9:0] WP;//写指针

always @(posedge clk[1] or negedge rst_n) begin
   if(!rst_n)
		WP <= 10'd0;
   else if(iEn[1])
		begin
			WP <= (WP == XSIZE -1 ) ? 10'd0 : WP + 1'b1;
			RAM[WP] <= iData;
		end		
end


assign oData = D1;

endmodule
