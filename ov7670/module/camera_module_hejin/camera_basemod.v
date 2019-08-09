module camera_basemod
(
    input CLOCK, RESET,

	 output CMOS1_SCL,
	 inout CMOS1_SDA,
    output CMOS1_XCLK,
	 input CMOS1_PCLK,
	 input CMOS1_HREF,
	 input CMOS1_VSYNC,
	 input [7:0]CMOS1_DQ,
	 input CMOS1_STROBE,
	 output CMOS1_PWDN,
	
	 input iEn,
	 output [35:0]oData
);
    wire CallU1,EnU1;
	 wire [15:0]DataU1;
	 
    camera_ctrlmod U1
	 (
	     .CLOCK( CLOCK ),
		  .RESET( RESET ),
		  .oCall( CallU1 ),
		  .iDone( DoneU2 ),
		  .oData( DataU1 ),
		  .oEn( EnU1 )
	 );
	 
	 wire DoneU2;
	 
	 sccb_funcmod U2
	 (
	     .CLOCK( CLOCK ), 
		  .RESET( RESET ),
	     .CMOS_SCL( CMOS1_SCL ),
	     .CMOS_SDA( CMOS1_SDA ),
	     .iCall( CallU1 ),
		  .oDone( DoneU2 ),
	     .iData( DataU1 )
	 );
	 
    wire EnU3;
	 wire [35:0]DataU3;
	
	 camera_funcmod U3
	 (
	     .CLOCK( CLOCK ),
	     .RESET( RESET ),
		  .CMOS_PCLK( CMOS1_PCLK ),
		  .CMOS_HREF( CMOS1_HREF ),
		  .CMOS_VSYNC( CMOS1_VSYNC ),
		  .CMOS_DQ( CMOS1_DQ ),
		  .iEn( EnU1 ),
		  .oEn( EnU3 ),
		  .oData( DataU3 )
	 );
	 
	 camera_savemod U4 
	 (
	    .CLOCK ( CLOCK ),
		 .RESET( RESET ),
		 .iEn ( {EnU3,iEn} ),  // [1]Write [0]Read
	    .iData ( DataU3 ),
		 .oData ( oData )
	 );
    
	 reg C;
    always @ ( posedge CLOCK ) C <= ~C;
	 
	 
	 assign CMOS1_XCLK = C;
	 assign CMOS1_PWDN = 1'b0;
	 
endmodule
