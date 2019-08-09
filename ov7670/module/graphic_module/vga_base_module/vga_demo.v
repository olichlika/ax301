module vga_demo(
   input clk,
   input rst_n,
   output VGA_HSYNC, VGA_VSYNC,
   output [15:0] VGAD
);

wire clk_100mhz/*synthesis keep*/;
wire clk_25mhz;

pll_module U0(
	.inclk0 (clk),
	.c0 (clk_100mhz),
	.c1 (clk_25mhz)
);

wire [10:0] TagU1;

vga_base_module U1(
	.clk ({clk_100mhz, clk_25mhz}),
	.rst_n (rst_n),
	.iEn (isEn),
	.iData (D1),
	.oTag (TagU1),// [10] Update [9:0]Clean Y
	.VGA_HSYNC (VGA_HSYNC),
	.VGA_VSYNC (VGA_VSYNC),
	.VGAD (VGAD)
);

//*************检查上升沿*************
reg [10:0] F2, F1;
reg [9:0] CV;
always @(posedge clk or negedge rst_n) begin
   if(!rst_n)
		begin
			F1 <= 11'd0;
			F2 <= 11'd0;
			CV <= 10'd0;
		end
   else
		begin
			CV <= TagU1[9:0];
 			F1 <= TagU1;
			F2 <= F1;			
		end
end

wire isL2H = (F2[10] == 0 && F1[10] == 1);
//wire CV = F1[9:0];
//*************DEMO操作模仿SDRAM*************
reg [15:0] D1;
reg isEn;
reg [3:0] i;
reg [9:0] C1;//显示彩条标志位

always @(posedge clk_100mhz or negedge rst_n) begin
   if(!rst_n)
		begin
			i <= 4'd0;
			D1 <= 16'd0;
			isEn <= 1'b0;//使能写入
			C1 <= 10'd0;
		end
   else
		case(i)
			0:
				if(isL2H && (CV <= 120)) //等待警报 每一行1次
					i <= 4'd1;
				else if(isL2H && (CV <= 240))
					i <= 4'd7;
				else
					i <= i;
			1://写入
				begin
					isEn <= 1'b1;
					D1 <= {5'd31, 6'd0, 5'd0};
					if( C1 == 80 -1 ) 
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else 
						C1 <= C1 + 1'b1;					
				end
			2:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd0, 6'd0, 5'd31};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			3:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd31, 6'd0, 5'd31};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			4:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd0, 6'd31, 5'd0};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end		
			5:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd0, 6'd0, 5'd0};
					if(C1 == 192 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			6:
				begin isEn <= 1'b0; i <= 4'd0; end

			7://写入 倒叙
				begin
					isEn <= 1'b1;
					D1 <= {5'd0,6'd31,5'd0};
					if( C1 == 80 -1 ) 
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else 
						C1 <= C1 + 1'b1;					
				end
			8:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd31,6'd0,5'd31};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			9:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd0,6'd0,5'd31};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			10:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd31,6'd0,5'd0};
					if(C1 == 80 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end		
			11:
				begin 
					isEn <= 1'b1;
					D1 <= {5'd0, 6'd0, 5'd0};
					if(C1 == 192 -1)
						begin 
							C1 <= 10'd0; 
							i <= i + 1'b1; 
						end
					else
						C1 <= C1 + 1'b1;
				end
			12:
				begin isEn <= 1'b0; i <= 4'd0; end		
			
		endcase
end

endmodule
