module camera_control_module(
   input clk,
   input rst_n,
   input iDone,
   output oCall,
   output [15:0]oData,
   output oEn
);

reg [15:0]D1;
always @(posedge clk or negedge rst_n)
	if(!rst_n)
		D1 <= 16'd0;
	else
		case(C1)
               0 	: 	D1	= 	16'h1280;	
	            1 	: 	D1	= 	16'h1180;	
	            2 	: 	D1	= 	16'h3a04;	
	            3 	: 	D1	=	16'h1200;	
	            4 	: 	D1	= 	16'h1713;	
	            5 	: 	D1	= 	16'h1801;	
	            6 	: 	D1	= 	16'h32b6;	
	            7 	: 	D1	= 	16'h1902;	
	            8 	: 	D1	= 	16'h1a7a;	
	            9 	: 	D1	= 	16'h030a;	
	            10	: 	D1	= 	16'h0c00;	
	            11	: 	D1	= 	16'h3e00;	
	            12 : 	D1	= 	16'h703a;	
	            13 : 	D1	= 	16'h7135;	
	            14 : 	D1	= 	16'h7211;	
	            15 : 	D1	= 	16'h73f0;	
	            16 : 	D1	= 	16'ha202;	    
	            17 : 	D1	= 	16'h7a20;	
	            18 : 	D1	= 	16'h7b10;
	            19 : 	D1	= 	16'h7c1e;	
	            20 : 	D1	= 	16'h7d35;
	            21 : 	D1	= 	16'h7e5a;
	            22 : 	D1	= 	16'h7f69;
	            23 : 	D1	= 	16'h8076;
	            24 : 	D1	= 	16'h8180;
	            25 : 	D1	= 	16'h8288;
	            26 : 	D1	= 	16'h838f;
	            27 : 	D1	= 	16'h8496;
	            28 : 	D1	= 	16'h85a3;
	            29 : 	D1	= 	16'h86af;
	            30 : 	D1	= 	16'h87c4;
	            31 : 	D1	= 	16'h88d7;
	            32 : 	D1	= 	16'h89e8;
	            33 : 	D1	= 	16'h13e0;
	            34 : 	D1	= 	16'h0150;
	            35 : 	D1	= 	16'h0268;
            	36 : 	D1	= 	16'h0000;
	            37 : 	D1	= 	16'h1000;
	            38 : 	D1	= 	16'h0d40;
	            39 : 	D1	= 	16'h1418;
	            40 : 	D1	= 	16'ha507;	
	            41 : 	D1	= 	16'hab08;
	            42 : 	D1	= 	16'h2495;
	            43 : 	D1	= 	16'h2533;
	            44 : 	D1	= 	16'h26e3;
	            45 : 	D1	= 	16'h9f78;
	            46 : 	D1	= 	16'ha068;
	            47 : 	D1	= 	16'ha103;
	            48 : 	D1	= 	16'ha6d8;
	            49 : 	D1	= 	16'ha7d8;
	            50 : 	D1	= 	16'ha8f0;
	            51 : 	D1	= 	16'ha990;
	            52 : 	D1	= 	16'haa94;
	            53 : 	D1	= 	16'h13e5;
	            54 : 	D1	= 	16'h0e61;	
	            55	: 	D1	= 	16'h0f4b;
	            56	: 	D1	= 	16'h1602;
	            57	: 	D1	= 	16'h1e37;
	            58 : 	D1	= 	16'h2102;
	            59 : 	D1	= 	16'h2291;
	            60 : 	D1	= 	16'h2907;
	            61 : 	D1	= 	16'h330b;
            	62 : 	D1	= 	16'h350b;
	            63 : 	D1	= 	16'h371d;
	            64 : 	D1	= 	16'h3871;
	            65 : 	D1	= 	16'h392a;
	            66 : 	D1	= 	16'h3c78;
	            67 : 	D1	= 	16'h4d40;
	            68	: 	D1	= 	16'h4e20;
	            69	: 	D1	= 	16'h6900;
	            70 : 	D1	= 	16'h6b0a;
	            71 : 	D1	= 	16'h7410;
	            72 : 	D1	= 	16'h8d4f;
	            73 : 	D1	= 	16'h8e00;
	            74 : 	D1	= 	16'h8f00;
	            75 : 	D1	= 	16'h9000;
	            76 : 	D1	= 	16'h9100;
	            77 : 	D1	= 	16'h9266;
	            78 : 	D1	= 	16'h9600;
	            79 : 	D1	= 	16'h9a80;
	            80 : 	D1	= 	16'hb084;
	            81 : 	D1	= 	16'hb10c;
	            82 : 	D1	= 	16'hb20e;
	            83	: 	D1	= 	16'hb382;
	            84  :	D1	=	16'hb80a;
	            85  :	D1	=	16'h4314;
	            86  :	D1	=	16'h44f0;
	            87  :	D1	=	16'h4534;
	            88  :	D1	=	16'h4658;
	            89  :	D1	=	16'h4728;
	            90  :	D1	=	16'h483a;
	            91  :	D1	=	16'h5988;
	            92  :	D1	=	16'h5a88;
	            93  :	D1	=	16'h5b44;
	            94  :	D1	=	16'h5c67;
	            95  :	D1	=	16'h5d49;
	            96  :	D1	=	16'h5e0e;
	            97  :	D1	=	16'h6404;
	            98  :	D1	=	16'h6520;
	            99  :	D1	=	16'h6605;
	            100 :	D1	=	16'h9404;
	            101 :	D1	=	16'h9508;
	            102 :	D1	=	16'h6c0a;
	            103 :	D1	=	16'h6d55;
	            104 :	D1	=	16'h6e11;
	            105 :	D1	=	16'h6f9f;
	            106 :	D1	=	16'h6a40;
	            107 :	D1	=	16'h0140;
	            108 :	D1	=	16'h0240;
	            109 :	D1	=	16'h13e7;
	            110 :	D1	= 	16'h4f80;
	            111 :	D1	= 	16'h5080;
	            112 :	D1	= 	16'h5100;
	            113 :	D1	= 	16'h5222;
	            114 :	D1	= 	16'h535e;
	            115 :	D1	= 	16'h5480;
	            116 :	D1	= 	16'h589e;
	            117 : D1	=	16'h4108;
	            118 : D1	=	16'h3f00;
	            119 : D1	=	16'h7503;
	            120 : D1	=	16'h76e1;
	            121 : D1	=	16'h4c00;
	            122 : D1	=	16'h7700;
	            123 : D1	=	16'h3dc2;
	            124 : D1	=	16'h4b09;
	            125 : D1	=	16'hc960;
	            126 : D1	=	16'h4138;
	            127 : D1	=	16'h5640;
	            128 : D1	=	16'h3411;
	            129 : D1	=	16'h3b0a;
	            130 : D1	=	16'ha488;
	            131 : D1	=	16'h9600;
	            132 : D1	=	16'h9730;
	            133 : D1	=	16'h9820;
	            134 : D1	=	16'h9930;
	            135 : D1	=	16'h9a84;
	            136 : D1	=	16'h9b29;
	            137 : D1	=	16'h9c03;
	            138 : D1	=	16'h9d98;
	            139 : D1	=	16'h9e3f;
	            140 :	D1	=	16'h7804;
	            141 :	D1	= 	16'h7901;
	            142 :	D1	= 	16'hc8f0;
	            143 :	D1	= 	16'h790f;
            	144 :	D1	= 	16'hc800;
	            145 :	D1	= 	16'h7910;
	            146 :	D1	= 	16'hc87e;
	            147 :	D1	= 	16'h790a;
	            148 :	D1	= 	16'hc880;
	            149 :	D1	= 	16'h790b;
	            150 :	D1	= 	16'hc801;
	            151 :	D1	= 	16'h790c;
	            152 :	D1	= 	16'hc80f;
	            153 :	D1	= 	16'h790d;
	            154 :	D1	= 	16'hc820;
	            155 :	D1	= 	16'h7909;
	            156 :	D1	= 	16'hc880;
	            157 :	D1	= 	16'h7902;
	            158 :	D1	= 	16'hc8c0;
	            159 :	D1	= 	16'h7903;
	            160 :	D1	= 	16'hc840;
	            161 :	D1	= 	16'h7905; 
	            162 :	D1	= 	16'hc830;
	            163 :	D1	= 	16'h7926;
	            164 :	D1	= 	16'h2d00;
	            165 :	D1	= 	16'h2e00;
			      167 : D1 =  16'h6b40;   // Overide
			      168 : D1 =  16'h1104;
			      169 : D1 =  16'h1204;
			      170 : D1 =  16'h40d0;
			      171 : D1 =  16'h0c04;
			      172 : D1 =  16'h7222;
			      173 : D1 =  16'h3e1a;
			      174 : D1 =  16'h7000;
			      175 : D1 =  16'h7100;  // 16'h7180 Color Bar, 16'h7100 camera
			      176 : D1 =  16'h73F2;
			      177 : D1 =  16'ha202;
			      178 : D1 =  16'h3280;
			      179 : D1 =  16'h171a;
			      180 : D1 =  16'h1808;
			      181 : D1 =  16'h0300;
			      182 : D1 =  16'h1903;
			      183 : D1 =  16'h1a7b;
		endcase
		
reg [3:0] i;
reg [15:0] C1;
reg isCall, isEn;

always @(posedge clk or negedge rst_n)
	if( !rst_n )
		begin
			i <= 4'd0;
			C1 <= 16'd0;
			{isCall, isEn} <= 2'b000;
		end
	else 
		case(i)	
			0: 
				if(iDone) begin isCall <= 1'b0; i <= i + 1'b1 ; end
				else begin isCall <= 1'b1; end 
					 
			1:
				if(C1 == 184 -1) begin C1 <= 16'd0; i <= i + 1'b1; end
				else begin C1 <= C1 + 1'b1; i <= 4'd0; end
					 
			2: isEn <= 1'b1;
					 
		endcase

assign oCall = isCall;
assign oData = D1;
assign oEn = isEn;

endmodule