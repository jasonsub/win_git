module fetch_datapath (DI, _latch, DO, DO_B, CLR_B);

	input [7:0] DI;
	input [3:0] _latch;
	input CLR_B;
	output reg [7:0] DO, DO_B;

	DFlipFlop_8 dff0 (DI, CLR_B, _latch[0], DO, DO_B);
	DFlipFlop_8 dff1 (DI, CLR_B, _latch[1], DO, DO_B);
	DFlipFlop_8 dff2 (DI, CLR_B, _latch[2], DO, DO_B);
	DFlipFlop_8 dff3 (DI, CLR_B, _latch[3], DO, DO_B);

endmodule

module DFlipFlop_8 (D, CLR_B, CLK, Q, QB);

	input [7:0] D;
	input CLR_B, CLK;
	output reg [7:0] Q, QB;

	DFlipFlop dff_0 (D[0], CLR_B, CLK, Q[0], QB[0]);
	DFlipFlop dff_0 (D[1], CLR_B, CLK, Q[1], QB[1]);
	DFlipFlop dff_0 (D[2], CLR_B, CLK, Q[2], QB[2]);
	DFlipFlop dff_0 (D[3], CLR_B, CLK, Q[3], QB[3]);
	DFlipFlop dff_0 (D[4], CLR_B, CLK, Q[4], QB[4]);
	DFlipFlop dff_0 (D[5], CLR_B, CLK, Q[5], QB[5]);
	DFlipFlop dff_0 (D[6], CLR_B, CLK, Q[6], QB[6]);
	DFlipFlop dff_0 (D[7], CLR_B, CLK, Q[7], QB[7]);

endmodule

module DFlipFlop (D, CLRB, CLK, Q, QB);
   input D, CLRB, CLK;
   output reg Q, QB;

   always @(posedge CLK)
     if(CLRB == 1'b0)
       begin 
	  Q <= 1'b0;
	  QB <= 1'b1;
       end
     else
       begin
	  Q <= D;
	  QB <= ~D;
       end
   
endmodule
