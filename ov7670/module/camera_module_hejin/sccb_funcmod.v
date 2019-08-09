module sccb_funcmod
(
    input CLOCK, RESET,
	 output CMOS_SCL,
	 inout CMOS_SDA,
	 input iCall,
	 output oDone,
	 input [15:0]iData
);
    // 400Khz, TH 0.6us, TL 1.3us, TR/TF = 300ns, THD/TSU_STA 0.6us, TSU_STO = 0.6us
	 parameter FCLK = 16'd10000, FHALF = 16'd5000, FQUARTER = 16'd2500; 
	 parameter FF_WR = 5'd7;
	 
	 reg [4:0]i;
	 reg [4:0]Go;
    reg [15:0]C1;
	 reg [7:0]D;
	 reg rSCL,rSDA;
	 reg isAck, isDone,isQ;
	 
	 always @ ( posedge CLOCK or negedge RESET )
	     if( !RESET )
		      begin
				    { i,Go } <= { 5'd0,5'd0 };
					 C1 <= 16'd0;
					 D <= 8'd0;
					 { rSCL,rSDA,isAck,isDone,isQ } <= 5'b11101;
				end
		  else if( iCall ) // Write
		      case( i )
				    
				    0: // Start
					 begin
					      isQ = 1;
					      rSCL <= 1'b1;
						  
					     if( C1 == 0 ) rSDA <= 1'b1; 
						  else if( C1 == FHALF ) rSDA <= 1'b0;  
						  
						  if( C1 == (FCLK) -1) begin C1 <= 16'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					  
					 1: // Write Device Addr
					 begin D <= 8'h42; i <= FF_WR; Go <= i + 1'b1; end
					 
					 2: // Wirte Word Addr
					 begin D <= iData[15:8]; i <= FF_WR; Go <= i + 1'b1; end
					
				    3: // Write Data
					 begin D <= iData[7:0]; i <= FF_WR; Go <= i + 1'b1; end
					 
					 4: // Stop
					 begin
					     isQ = 1'b1;
						  
					     if( C1 == 0 ) rSCL <= 1'b0;
					     else if( C1 == FQUARTER ) rSCL <= 1'b1; 
		                  
						  if( C1 == 0 ) rSDA <= 1'b0;
						  else if( C1 == (FQUARTER + FHALF ) ) rSDA <= 1'b1;
					 	  
						  if( C1 == (FQUARTER + FCLK) -1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 5:
					 begin isDone <= 1'b1; i <= i + 1'b1; end
					 
					 6: 
					 begin isDone <= 1'b0; i <= 5'd0; end
					 
					 /*******************************/ //function
					 
					 7,8,9,10,11,12,13,14:
					 begin
					     isQ = 1'b1;
						  rSDA <= D[14-i];
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FQUARTER ) rSCL <= 1'b1;
						  else if( C1 == FQUARTER + FHALF ) rSCL <= 1'b0;
						  
						  if( C1 == FCLK -1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1;
					 end
					
					 15: // waiting for acknowledge
					 begin
					     isQ = 1'b0;
					     if( C1 == FHALF ) isAck <= CMOS_SDA;
						  
						  if( C1 == 0 ) rSCL <= 1'b0;
						  else if( C1 == FQUARTER ) rSCL <= 1'b1;
						  else if( C1 == FQUARTER + FHALF ) rSCL <= 1'b0;
	
						  if( C1 == FCLK -1 ) begin C1 <= 16'd0; i <= i + 1'b1; end
						  else C1 <= C1 + 1'b1; 
					 end
					 
					 16:
					 if( isAck != 0 ) i <= 5'd0;
					 else i <= Go; 
    					
				endcase
	
    assign CMOS_SCL = rSCL;
	 assign CMOS_SDA = isQ ? rSDA : 1'bz;	
    assign oDone = isDone;
				
endmodule
