// This contains unit-delay simulation for micropipeline designs



// This is the extra forward delay between 
`define data_delay  0


// provides a programmable delay line to the design
// delay based on macro data_delay
module FUNDEL(lr, rr);
   
   input  lr;
   output rr;
   reg 	  rr;

   always @(posedge lr)
     // make delay line in rising edge to match function logic
     rr <= #`data_delay lr;
   always @(negedge lr)
     // no delay line on fallling edge.
     rr <= lr;
endmodule // FUNDEL



// This is the "go" module.
// It gives a two gate delay turnaround between the req/ack pairs
// It asserts reset until go is asserted and then


// Left go signal also resets the system
module LHS(go_l, rst, out, in);
   output rst, out;
   input  go_l, in;

   assign rst = ~go_l;
   assign #1 out = go_l & ~in;

endmodule // HS2




// Right go signal pauses the output.
// Must ensure that this is lowered when in = 0!!!
module RHS(go_r, out, in);
   output out;
   input  in, go_r;

   assign #1 out = go_r & in;

endmodule // RHS

	



module UPIPELINE2 (lr, la, rr, ra, rst);
   input  lr, ra, rst;
   output rr, la;

   wire   rr_, ra_;

   C_ELEMENT c0 (.a(lr), .b(rr_), .c(la), .rst(rst));
   C_ELEMENT c1 (.a(la), .b(ra_), .c(rr), .rst(rst));
   INV_      i0 (.a(ra), .b(ra_));
   INV_      i1 (.a(rr), .b(rr_));

endmodule // UPIPELINE2



module UPIPELINE (lr, la, rr, ra, rst);
   input  lr, ra, rst;
   output rr, la;

   wire   ra_;

   C_ELEMENT c0 (.a(lr), .b(ra_), .c(la), .rst(rst));
   INV_      i0 (.a(ra), .b(ra_));
   assign rr = la;

endmodule // UPIPELINE






module UPIPELINE_4x (go_l, go_r);
   input go_l, go_r;
   wire  lr, la, rr, ra, r1, a1, r2, a2, r3, a3, rst;

   LHS       l0 (.go_l(go_l), .rst(rst), .out(lr), .in(la));
   UPIPELINE s0 (.lr(lr), .la(la), .rr(r1), .ra(a1), .rst(rst));
   FUNDEL    d0 (.lr(r1), .rr(r1d));
   UPIPELINE s1 (.lr(r1d), .la(a1), .rr(r2), .ra(a2), .rst(rst));
   FUNDEL    d1 (.lr(r2), .rr(r2d));
   UPIPELINE s2 (.lr(r2d), .la(a2), .rr(r3), .ra(a3), .rst(rst));
   FUNDEL    d2 (.lr(r3), .rr(r3d));
   UPIPELINE s3 (.lr(r3d), .la(a3), .rr(rr0), .ra(ra), .rst(rst));
   FUNDEL    d3 (.lr(rr0), .rr(rr));
   RHS       r0 (.go_r(go_r), .in(rr), .out(ra));

endmodule // UPIPELINE_4x


module UPIPELINE2_4x (go_l, go_r);
   input go_l, go_r;
   wire  lr, la, rr, ra, r1, a1, r2, a2, r3, a3, rst;

   LHS        l0 (.go_l(go_l), .rst(rst), .out(lr), .in(la));
   UPIPELINE2 s0 (.lr(lr), .la(la), .rr(r1), .ra(a1), .rst(rst));
   FUNDEL     d0 (.lr(r1), .rr(r1d));
   UPIPELINE2 s1 (.lr(r1d), .la(a1), .rr(r2), .ra(a2), .rst(rst));
   FUNDEL     d1 (.lr(r2), .rr(r2d));
   UPIPELINE2 s2 (.lr(r2d), .la(a2), .rr(r3), .ra(a3), .rst(rst));
   FUNDEL     d2 (.lr(r3), .rr(r3d));
   UPIPELINE2 s3 (.lr(r3d), .la(a3), .rr(rr0), .ra(ra), .rst(rst));
   FUNDEL     d3 (.lr(rr0), .rr(rr));
   RHS        r0 (.go_r(go_r), .in(rr), .out(ra));

endmodule // UPIPELINE2_4x
