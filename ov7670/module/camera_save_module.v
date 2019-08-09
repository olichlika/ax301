module camera_save_module(
   input clk,
   input rst_n,
   input [1:0] iEn,
   input [35:0] iData,
   output [35:0] oData
);

parameter XSIZE = 10'd160;
reg [35:0] RAM [1023:0];

//***********写**********
reg [9:0] C1;
always @(posedge clk or negedge rst_n)
   if(!rst_n)
		C1 <= 10'd0;
   else if(iEn[1])
		begin   
			RAM[C1] <= iData; 
			C1 <= (C1 == XSIZE -1) ? 10'd0 : C1 + 1'b1; 
		end
//***********读**********
reg [35:0] D1;
reg [9:0] C2;
always @(posedge clk or negedge rst_n)
   if(!rst_n)
		begin
			C2 <= 10'd0;
			D1 <= 36'd0;
		end
   else if(iEn[0])
		begin   
			D1 <= RAM[C2];
			C2 <= (C2 == XSIZE -1) ? 10'd0 : C2 + 1'b1; 
		end

assign oData = D1;
		
endmodule
