module asyn_fetch (lr, la, rr, ra, _shift_reg, _latch, _rst);
	input lr, ra, _rst;
	output la, rr, _shift_reg;
	output [3:0] _latch;

	wire [2:0] e_lr;
	wire [2:0] e_la;
	wire [3:0] d_rr;
	wire [3:0] d_ra;
	wire p_lr, p_la, p_rr, p_ra;

	expander_4 fetch_exp (lr, e_lr[0], e_lr[1], e_lr[2], la, e_la[0], e_la[1], e_la[2], p_lr, p_la, _rst);
	pipe mid_pipe (p_lr, p_la, p_rr, p_ra, _rst, _shift_reg);
	decimator_4 fetch_dec (p_rr, p_ra, d_rr[0], d_rr[1], d_rr[2], d_rr[3], d_ra[0], d_ra[1], d_ra[2], d_ra[3], _rst);
	pipe lc_pipe3 (d_rr[3], d_ra[3], rr, ra, _rst, _latch[3]);
	pipe lc_pipe2 (d_rr[2], d_ra[2], e_lr[2], e_la[2], _rst, _latch[2]);
	pipe lc_pipe1 (d_rr[1], d_ra[1], e_lr[1], e_la[1], _rst, _latch[1]);
	pipe lc_pipe0 (d_rr[0], d_ra[0], e_lr[0], e_la[0], _rst, _latch[0]);
endmodule

module expander_4 (r1, r2, r3, r4, a1, a2, a3, a4, ro, ao, reset);

  input r1, r2, r3, r4, ao, reset;
  output a1, a2, a3, a4, ro;
  
  wire [3:0] enable;
  
  shift_reg_4 SR0 (ao, reset, enable);
  
   AOI22X1A12TR exp4_0 ( .A0(r1), .A1(enable[0]), .B0(r2), .B1(enable[1]), .Y(n0));
   AOI22X1A12TR exp4_1 ( .A0(r3), .A1(enable[2]), .B0(r4), .B1(enable[3]), .Y(n1));
   NAND2X1A12TR exp4_2 ( .A(n0), .B(n1), .Y(ro) );
  
   AND2X1A12TR exp4_4 ( .A(ao), .B(enable[0]), .Y(a1) );
   AND2X1A12TR exp4_5 ( .A(ao), .B(enable[1]), .Y(a2) );
   AND2X1A12TR exp4_6 ( .A(ao), .B(enable[2]), .Y(a3) );
   AND2X1A12TR exp4_7 ( .A(ao), .B(enable[3]), .Y(a4) );

endmodule // expander_4

module shift_reg_4(update, reset, out);

  input update, reset;
  output [3:0] out;
  reg [3:0] out;
  wire resetbar;
  assign resetbar = ~reset;
  
  
  always@(negedge update or negedge resetbar) begin
    if (~resetbar) begin
      out <= 4'b0001;
      end
    else begin
       out[3] <= out[2];
       out[2] <= out[1];
       out[1] <= out[0];
       out[0] <= out[3];
		end
    end
  
 endmodule // shift_reg

module decimator_4 (ri, ai, r1, r2, r3, r4, a1, a2, a3, a4, reset);

  input ri, a1, a2, a3, a4, reset;
  output ai, r1, r2, r3, r4;
  
  wire [3:0] enable;
 
  shift_reg_4 SR0 (ai, reset, enable);
 
   AND2X1A12TR dec4_0 ( .A(ri), .B(enable[0]), .Y(r1) );
   AND2X1A12TR dec4_1 ( .A(ri), .B(enable[1]), .Y(r2) );
   AND2X1A12TR dec4_2 ( .A(ri), .B(enable[2]), .Y(r3) );
   AND2X1A12TR dec4_3 ( .A(ri), .B(enable[3]), .Y(r4) );

 assign ai = a1 | a2 | a3 | a4;
  
endmodule // decimator_4

module pipe (lr, la, rr, ra, rst, clk);
   input  lr, ra, rst;
   output rr, la, clk;

   wire   rr_, ra_;

   C_ELEMENT c0 (.a(lr), .b(rr_), .c(la), .rst(rst));
   C_ELEMENT c1 (.a(la), .b(ra_), .c(rr), .rst(rst));
   INV      i0 (.a(ra), .b(ra_));
   INV      i1 (.a(rr), .b(rr_));

   assign clk = rr;
   
endmodule // UPIPELINE2

module C_ELEMENT(c, a, b, rst);
   output c;
   input  a, b, rst;
   assign #2 c = ~rst & ((a & b) | (a & c) | (b & c));
endmodule // C_ELEMENT

module INV(a, b);
   output b;
   input  a;
   assign #1 b = ~a;
endmodule // INV

module AND2X1A12TR (A, B, Y);
   input A, B;
   output Y;
   assign #1 Y = A & B;
endmodule // NAND2X2A12TH

module NAND2X1A12TR (A, B, Y);
   input A, B;
   output Y;
   assign #1 Y = ~(A & B);
endmodule // NAND2X2A12TH

module AOI22XA12TR (A0, A1, B0, B1, Y);
   input A0, A1, B0, B1;
   output Y;
   assign #1 Y = ~((A0 & A1) | (B0 & B1));
endmodule // AOI22X2A12TH
