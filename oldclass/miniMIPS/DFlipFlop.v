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
