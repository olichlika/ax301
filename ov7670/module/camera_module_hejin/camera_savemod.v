module camera_savemod
(
    input CLOCK, RESET, 
	 input [1:0]iEn,
	 input [35:0]iData,
	 output [35:0]oData
);
   parameter XSIZE = 10'd160;

   reg [35:0] RAM [1023:0]; 
   reg [9:0]C1; // N+1
			  
   always @ ( posedge CLOCK or negedge RESET )
	    if( !RESET )
		     begin
			      C1 <= 10'd0;
			  end
       else if( iEn[1] ) 
		     begin   
			    RAM[ C1 ] <= iData; 
				 C1 <= (C1 == XSIZE -1) ? 10'd0 : C1 + 1'b1; 
			  end
	
	reg [35:0]D1;
	reg [9:0]C2;
		 
   always @ ( posedge CLOCK or negedge RESET )
	    if( !RESET )
		     begin
			      D1 <= 36'd0;
					C2 <= 10'd0;
			  end
		 else if( iEn[0] )
				begin 
				    D1 <= RAM[ C2 ]; 
					 C2 <= (C2 == XSIZE -1) ? 10'd0 : C2 + 1'b1; 
				end

   assign oData = D1;				
	
endmodule
