module camera_funcmod
(
    input CLOCK, RESET,
	 input CMOS_PCLK,
	 input CMOS_HREF,
	 input CMOS_VSYNC,
	 input [7:0]CMOS_DQ,
	 
	 input iEn,
	 output oEn,
	 output [35:0]oData
); 
	 reg  F2_PCLK,F1_PCLK,B2_PCLK,B1_PCLK;
	 reg  F2_VS,F1_VS,B2_VS,B1_VS;
	 reg  F2_HREF,F1_HREF,B2_HREF,B1_HREF;
	 reg  [7:0]B2_DQ, B1_DQ;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      begin
			       { F2_PCLK,F1_PCLK,B2_PCLK,B1_PCLK } <= 4'b0000;
					 { F2_VS,F1_VS,B2_VS,B1_VS } <= 4'b0000;
					 { F2_HREF,F1_HREF,B2_HREF,B1_HREF } <= 4'b0000;
					 { B2_DQ,B1_DQ } <= 16'd0;
				end
		  else 
		      begin
		          { F2_PCLK,F1_PCLK,B2_PCLK,B1_PCLK } <= { F1_PCLK,B2_PCLK,B1_PCLK,CMOS_PCLK };
					 { F2_VS,F1_VS,B2_VS,B1_VS } <= { F1_VS, B2_VS,B1_VS, CMOS_VSYNC };
					 { F2_HREF,F1_HREF,B2_HREF,B1_HREF } <= { F1_HREF, B2_HREF,B1_HREF, CMOS_HREF };
					 { B2_DQ,B1_DQ } <= {B1_DQ,CMOS_DQ} ;
				end
				
	 wire isH2L_VS = iEn && (F2_VS == 1) && (F1_VS == 0);
	 wire isL2H_VS = iEn && (F2_VS == 0) && (F1_VS == 1);
	 reg isFrame;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      isFrame <= 1'b0;
		  else if( isH2L_VS )
		      isFrame <= 1'b1; 
		  else if( isL2H_VS )		
		      isFrame <= 1'b0;
					
    wire isH2L_PCLK = isFrame && (F2_PCLK == 1) && (F1_PCLK == 0);
    reg [11:0]CH;
	 
    always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      CH <= 12'd0;
			else if( !B2_HREF )
		      CH <= 12'd0;	
		  else if( isH2L_PCLK && B2_HREF )
		      CH <= CH + 1'b1;

	 wire isH2L_HREF = iEn && (F2_HREF == 1) && (F1_HREF == 0);
	 reg [9:0]CV;
	 
    always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      CV <= 10'd0;
		  else if( !isFrame )
		      CV <= 10'd0;
		  else if( isFrame && isH2L_HREF )
		      CV <= CV + 1'b1;

	 reg [7:0]D1; // LSB;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
				D1 <= 8'd0;
		  else if( isH2L_PCLK && B2_HREF ) 
		      D1 <= B2_DQ;  // LSB
	 
	 wire [9:0]CY = CV;
	 wire [9:0]CX = CH >>1;
	 reg [35:0]D2;  //  [35:26]X [25:16]Y [15:0]Color Data
	 reg isEn;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      begin
		          D2 <= 36'd0;
					 isEn <= 1'b0;
				end
		  else if( isH2L_PCLK && CH[0] && B2_HREF )
		      begin
				    isEn <= 1'b1;
					 D2 <= { CY,CX,D1, B2_DQ };
				end
		  else 
		     	begin
				    isEn <= 1'b0;
					 D2 <= 16'd0;
				end
				
    assign oEn = isEn;
	 assign oData = D2;
				
endmodule