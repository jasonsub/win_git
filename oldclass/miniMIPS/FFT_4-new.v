// To clock this as normally open, lc7 input is rr
// To clock this as normally closed, lc7 input is la_

module FFT_4 (ri, ai, DI, ro, ao, DO, reset);

  input ri, ao, reset;
  input [31:0] DI;

  output ai, ro;
  output [31:0] DO;

  // pipe stage 0 wires
  wire [31:0] P0D, P0D1, P0D2, P0D3, P0D4;
  // pipe stage 1 wires
  wire [15:0] P1D1R, P1D1I, P1D2R, P1D2I, P1D3R, P1D3I, P1D4R, P1D4I;
  wire [15:0] P1S1, P1S2, P1S3, P1S4, P1D1, P1D2, P1D3, P1D4;
  // pipe stage 2 wires
  wire [15:0] P2O1, P2O2, P2O3, P2O4, P2O5, P2O6, P2O7, P2O8;
  wire [15:0] P2S1, P2S2, P2S3, P2S4, P2D1, P2D2, P2D3, P2D4;
  // pipe stage 3 wires
  wire [15:0] P3D1R, P3D1I, P3D2R, P3D2I, P3D3R, P3D3I, P3D4R, P3D4I;
  // pipe stage 4 wires
  wire [15:0] P4D1R, P4D1I, P4D2R, P4D2I, P4D3R, P4D3I, P4D4R, P4D4I;
  wire [31:0] P4D;

  // Buffer data coming in before decimator (for performance reasons)
  // between this controller and the next set is pipe stage 0.
  linear_control_FFT4 tk0 (ri, ai, p0r, p0a, ck0, reset);
  latch_32_FFT4       P0  (DI, ck0, P0D);

  // decimator and fork into real and imaginary parts.
  decimator_4 D4_0 (P0D, P0D1, P0D2, P0D3, P0D4, p0r, p0a,
                    p0r1, p0r2, p0r3, p0r4, p0a1, p0a2, p0a3, p0a4, reset);
  // fork x(0) into real and imaginary
  bcast_fork  f0  (p0r1, p0r1R, p0r1I, p0a1R, p0a1I, p0a1);
  // fork x(1) into real and imaginary
  bcast_fork  f1  (p0r2, p0r2R, p0r2I, p0a2R, p0a2I, p0a2);
  // fork x(2) into real and imaginary
  bcast_fork  f2  (p0r3, p0r3R, p0r3I, p0a3R, p0a3I, p0a3);
  // fork x(3) into real and imaginary
  bcast_fork  f3  (p0r4, p0r4R, p0r4I, p0a4R, p0a4I, p0a4);

  // controllers separating pipe stages 0 and 1.
  // x(0) storage
  linear_control_FFT4 tk1_0 (p0r1R, p0a1R, p1r1R, p1a1R, ck1_0, reset);
  latch_16_FFT4       P1_0  (P0D1[31:16], ck1_0, P1D1R);
  linear_control_FFT4 tk1_1 (p0r1I, p0a1I, p1r1I, p1a1I, ck1_1, reset);
  latch_16_FFT4       P1_1  (P0D1[15:0],  ck1_1, P1D1I);
  // x(1) storage
  linear_control_FFT4 tk1_2 (p0r2R, p0a2R, p1r2R, p1a2R, ck1_2, reset);
  latch_16_FFT4       P1_2  (P0D2[31:16], ck1_2, P1D2R);
  linear_control_FFT4 tk1_3 (p0r2I, p0a2I, p1r2I, p1a2I, ck1_3, reset);
  latch_16_FFT4       P1_3  (P0D2[15:0],  ck1_3, P1D2I);
  // x(2) storage
  linear_control_FFT4 tk1_4 (p0r3R, p0a3R, p1r3R, p1a3R, ck1_4, reset);
  latch_16_FFT4       P1_4  (P0D3[31:16], ck1_4, P1D3R);
  linear_control_FFT4 tk1_5 (p0r3I, p0a3I, p1r3I, p1a3I, ck1_5, reset);
  latch_16_FFT4       P1_5  (P0D3[15:0],  ck1_5, P1D3I);
  // x(3) storage
  linear_control_FFT4 tk1_6 (p0r4R, p0a4R, p1r4R, p1a4R, ck1_6, reset);
  latch_16_FFT4       P1_6  (P0D4[31:16], ck1_6, P1D4R);
  linear_control_FFT4 tk1_7 (p0r4I, p0a4I, p1r4I, p1a4I, ck1_7, reset);
  latch_16_FFT4       P1_7  (P0D4[15:0],  ck1_7, P1D4I);

  // pipe stage 1 computation
  // sum and difference for x(0) and x(2) real
  add_sub AS0 (P1D1R, P1D3R, P1S1, P1D1);
  // sum and difference for x(0) and x(2) imaginary
  add_sub AS1 (P1D1I, P1D3I, P1S2, P1D2);
  // sum and difference for x(1) and x(3) real
  add_sub AS2 (P1D2R, P1D4R, P1S3, P1D3);
  // sum and difference for x(1) and x(3) imaginary
  add_sub AS3 (P1D2I, P1D4I, P1S4, P1D4);

  // Each add_sub module has operands from two different sources
  // this requires a join module for each add_sub.
  bcast_fork f4 (p1aAS0, p1a1R, p1a3R, p1r1R, p1r3R, p1rAS0);
  bcast_fork f5 (p1aAS1, p1a1I, p1a3I, p1r1I, p1r3I, p1rAS1);
  bcast_fork f6 (p1aAS2, p1a2R, p1a4R, p1r2R, p1r4R, p1rAS2);
  bcast_fork f7 (p1aAS3, p1a2I, p1a4I, p1r2I, p1r4I, p1rAS3);

  // controllers separating pipe stages 1 and 2.
  linear_control_FFT4 tk2_0 (p1rAS0, p1aAS0, p2rAS0, p2aAS0, ck2_0, reset);
  latch_16_FFT4       P2_0  (P1S1, ck2_0, P2O1);
  latch_16_FFT4       P2_1  (P1D1, ck2_0, P2O2);
  linear_control_FFT4 tk2_1 (p1rAS1, p1aAS1, p2rAS1, p2aAS1, ck2_1, reset);
  latch_16_FFT4       P2_2  (P1S2, ck2_1, P2O3);
  latch_16_FFT4       P2_3  (P1D2, ck2_1, P2O4);
  linear_control_FFT4 tk2_2 (p1rAS2, p1aAS2, p2rAS2, p2aAS2, ck2_2, reset);
  latch_16_FFT4       P2_4  (P1S3, ck2_2, P2O5);
  latch_16_FFT4       P2_5  (P1D3, ck2_2, P2O6);
  linear_control_FFT4 tk2_3 (p1rAS3, p1aAS3, p2rAS3, p2aAS3, ck2_3, reset);
  latch_16_FFT4       P2_6  (P1S4, ck2_3, P2O7);
  latch_16_FFT4       P2_7  (P1D4, ck2_3, P2O8);

  // each of the results from the previous operation is being sent
  // to different computations than other. Must fork.
  bcast_fork f8  (p2rAS0, p2rO1, p2rO2, p2aO1, p2aO2, p2aAS0);
  bcast_fork f9  (p2rAS1, p2rO3, p2rO4, p2aO3, p2aO4, p2aAS1);
  bcast_fork f10 (p2rAS2, p2rO5, p2rO6, p2aO5, p2aO6, p2aAS2);
  bcast_fork f11 (p2rAS3, p2rO7, p2rO8, p2aO7, p2aO8, p2aAS3);

  // pipe stage 2 computation
  add_sub AS4 (P2O1, P2O5, P2S1, P2D1);
  add_sub AS5 (P2O3, P2O7, P2S2, P2D2);
  add_sub AS6 (P2O2, P2O8, P2S3, P2D3);
  add_sub AS7 (P2O4, P2O6, P2S4, P2D4);

  // there is need for more joins  because the operands come from
  // different places.
  bcast_fork f12 (p2aAS4, p2aO1, p2aO5, p2rO1, p2rO5, p2rAS4);
  bcast_fork f13 (p2aAS5, p2aO3, p2aO7, p2rO3, p2rO7, p2rAS5);
  bcast_fork f14 (p2aAS6, p2aO2, p2aO8, p2rO2, p2rO8, p2rAS6);
  bcast_fork f15 (p2aAS7, p2aO4, p2aO6, p2rO4, p2rO6, p2rAS7);

  // controllers separating pipe stages 2 and 3
  linear_control_FFT4 tk3_0 (p2rAS4, p2aAS4, p3rAS4, p3aAS4, ck3_0, reset);
  latch_16_FFT4       P3_0  (P2S1, ck3_0, P3D1R);
  latch_16_FFT4       P3_1  (P2D1, ck3_0, P3D3R);
  linear_control_FFT4 tk3_1 (p2rAS5, p2aAS5, p3rAS5, p3aAS5, ck3_1, reset);
  latch_16_FFT4       P3_2  (P2S2, ck3_1, P3D1I);
  latch_16_FFT4       P3_3  (P2D2, ck3_1, P3D3I);
  linear_control_FFT4 tk3_2 (p2rAS6, p2aAS6, p3rAS6, p3aAS6, ck3_2, reset);
  latch_16_FFT4       P3_4  (P2S3, ck3_2, P3D2R);
  latch_16_FFT4       P3_5  (P2D3, ck3_2, P3D4R);
  linear_control_FFT4 tk3_3 (p2rAS7, p2aAS7, p3rAS7, p3aAS7, ck3_3, reset);
  latch_16_FFT4       P3_6  (P2S4, ck3_3, P3D4I);
  latch_16_FFT4       P3_7  (P2D4, ck3_3, P3D2I);

  // fork so real and imaginary parts can come together.
  bcast_fork f16 (p3rAS4, p3r1R, p3r3R, p3a1R, p3a3R, p3aAS4);
  bcast_fork f17 (p3rAS5, p3r1I, p3r3I, p3a1I, p3a3I, p3aAS5);
  bcast_fork f18 (p3rAS6, p3r2R, p3r4R, p3a2R, p3a4R, p3aAS6);
  bcast_fork f19 (p3rAS7, p3r2I, p3r4I, p3a2I, p3a4I, p3aAS7);

  // controllers separating pipe stages 3 and 4
  linear_control_FFT4 tk4_0 (p3r1R, p3a1R, p4r1R, p4a1R, ck4_0, reset);
  latch_16_FFT4       P4_0  (P3D1R, ck4_0, P4D1R);
  linear_control_FFT4 tk4_1 (p3r1I, p3a1I, p4r1I, p4a1I, ck4_1, reset);
  latch_16_FFT4       P4_1  (P3D1I, ck4_1, P4D1I);
  linear_control_FFT4 tk4_2 (p3r2R, p3a2R, p4r2R, p4a2R, ck4_2, reset);
  latch_16_FFT4       P4_2  (P3D2R, ck4_2, P4D2R);
  linear_control_FFT4 tk4_3 (p3r2I, p3a2I, p4r2I, p4a2I, ck4_3, reset);
  latch_16_FFT4       P4_3  (P3D2I, ck4_3, P4D2I);
  linear_control_FFT4 tk4_4 (p3r3R, p3a3R, p4r3R, p4a3R, ck4_4, reset);
  latch_16_FFT4       P4_4  (P3D3R, ck4_4, P4D3R);
  linear_control_FFT4 tk4_5 (p3r3I, p3a3I, p4r3I, p4a3I, ck4_5, reset);
  latch_16_FFT4       P4_5  (P3D3I, ck4_5, P4D3I);
  linear_control_FFT4 tk4_6 (p3r4R, p3a4R, p4r4R, p4a4R, ck4_6, reset);
  latch_16_FFT4       P4_6  (P3D4R, ck4_6, P4D4R);
  linear_control_FFT4 tk4_7 (p3r4I, p3a4I, p4r4I, p4a4I, ck4_7, reset);
  latch_16_FFT4       P4_7  (P3D4I, ck4_7, P4D4I);

  // joins to bring real and imaginary parts together.
  bcast_fork f20 (p4a1, p4a1R, p4a1I, p4r1R, p4r1I, p4r1);
  bcast_fork f21 (p4a2, p4a2R, p4a2I, p4r2R, p4r2I, p4r2);
  bcast_fork f22 (p4a3, p4a3R, p4a3I, p4r3R, p4r3I, p4r3);
  bcast_fork f23 (p4a4, p4a4R, p4a4I, p4r4R, p4r4I, p4r4);

  // into the expander
  expander_4 E4_0 ({P4D1R,P4D1I}, {P4D2R,P4D2I}, {P4D3R,P4D3I}, {P4D4R, P4D4I},
                   P4D, p4r1, p4r2, p4r3, p4r4, p4a1, p4a2, p4a3, p4a4, 
                   p4r, p4a, reset);

  // buffer the output
  linear_control_FFT4 tk5 (p4r, p4a, ro, ao, ck5, reset);
  latch_32_FFT4       P5  (P4D, ck5, DO);

endmodule // FFT_4


module latch_32_FFT4
  (
   input  [31:0]     d,         // latch input data d
   input             clk,       // latch clock
   output reg [31:0] q          // latch output data q
   );

   /*LATQX1A12TR latch0   ( .G(clk), .D(d[0]),  .Q(q[0])  );
   LATQX1A12TR latch1   ( .G(clk), .D(d[1]),  .Q(q[1])  );
   LATQX1A12TR latch2   ( .G(clk), .D(d[2]),  .Q(q[2])  );
   LATQX1A12TR latch3   ( .G(clk), .D(d[3]),  .Q(q[3])  );
   LATQX1A12TR latch4   ( .G(clk), .D(d[4]),  .Q(q[4])  );
   LATQX1A12TR latch5   ( .G(clk), .D(d[5]),  .Q(q[5])  );
   LATQX1A12TR latch6   ( .G(clk), .D(d[6]),  .Q(q[6])  );
   LATQX1A12TR latch7   ( .G(clk), .D(d[7]),  .Q(q[7])  );
   LATQX1A12TR latch8   ( .G(clk), .D(d[8]),  .Q(q[8])  );
   LATQX1A12TR latch9   ( .G(clk), .D(d[9]),  .Q(q[9])  );
   LATQX1A12TR latch10  ( .G(clk), .D(d[10]), .Q(q[10]) );
   LATQX1A12TR latch11  ( .G(clk), .D(d[11]), .Q(q[11]) );
   LATQX1A12TR latch12  ( .G(clk), .D(d[12]), .Q(q[12]) );
   LATQX1A12TR latch13  ( .G(clk), .D(d[13]), .Q(q[13]) );
   LATQX1A12TR latch14  ( .G(clk), .D(d[14]), .Q(q[14]) );
   LATQX1A12TR latch15  ( .G(clk), .D(d[15]), .Q(q[15]) );
   LATQX1A12TR latch16  ( .G(clk), .D(d[16]), .Q(q[16]) );
   LATQX1A12TR latch17  ( .G(clk), .D(d[17]), .Q(q[17]) );
   LATQX1A12TR latch18  ( .G(clk), .D(d[18]), .Q(q[18]) );
   LATQX1A12TR latch19  ( .G(clk), .D(d[19]), .Q(q[19]) );
   LATQX1A12TR latch20  ( .G(clk), .D(d[20]), .Q(q[20]) );
   LATQX1A12TR latch21  ( .G(clk), .D(d[21]), .Q(q[21]) );
   LATQX1A12TR latch22  ( .G(clk), .D(d[22]), .Q(q[22]) );
   LATQX1A12TR latch23  ( .G(clk), .D(d[23]), .Q(q[23]) );
   LATQX1A12TR latch24  ( .G(clk), .D(d[24]), .Q(q[24]) );
   LATQX1A12TR latch25  ( .G(clk), .D(d[25]), .Q(q[25]) );
   LATQX1A12TR latch26  ( .G(clk), .D(d[26]), .Q(q[26]) );
   LATQX1A12TR latch27  ( .G(clk), .D(d[27]), .Q(q[27]) );
   LATQX1A12TR latch28  ( .G(clk), .D(d[28]), .Q(q[28]) );
   LATQX1A12TR latch29  ( .G(clk), .D(d[29]), .Q(q[29]) );
   LATQX1A12TR latch30  ( .G(clk), .D(d[30]), .Q(q[30]) );
   LATQX1A12TR latch31  ( .G(clk), .D(d[31]), .Q(q[31]) );
   */
   always @ (d or clk) begin
        if (clk) begin
             q <= d;
        end
   end

endmodule // latch_32_FFT4



module linear_control_FFT4 (lr, la, rr, ra, ck, rst);
   input  lr, ra, rst;
   output la, rr, ck;

   // This conforms to the following specification:
   // 
   // bi LEFT lr.'c1.'la.'c2.lr.'la.   LEFT
   // bi RIGHT    c1.'rr. c2.ra.'rr.ra.RIGHT
   // bi SPEC (LEFT | RIGHT) \ {c1, c2}
   //
   // c2 is a timed constraint, c1 is causal.
   // Artisan
   /////////////////////////////////////////////////////////////////////////
   // la+ |--> la- > y*-
   // rr+ |--> rr- > y*-
   // set_data_check -fall_to lcR0/lc6/Y -fall_from lcR0/lc2/Y -hold 0
   // set_data_check -fall_to lcR0/lc6/Y -fall_from lcR0/lc4/Y -hold 0
   //

   wire   ra_, y, y_, la_, rr_;

   INVX1A12TR      lc0  (.A(ra), .Y(ra_));
   AOI32X1A12TR    lc1  (.A0(lr), .A1(ra_), .A2(y_), .B0(lr), .B1(la), .Y(la_));
   // artisan only, no non-inverting AO32 cell:
   INVX1A12TR      lc2  (.A(la_), .Y(la));
   AOI32X1A12TR    lc3  (.A0(ra_), .A1(lr), .A2(y_), .B0(ra_), .B1(rr), .Y(rr_));
   NOR2X1A12TR     lc4  (.A(rr_), .B(rst), .Y(rr));
   // SI c-element in TSMC:
   c_element    lc5  (.a(la), .b(rr), .y(y));
   INVX1A12TR      lc6  (.A(y), .Y(y_));
   INVX1A12TR	lc7  (.A(rr), .Y(ck));

endmodule // linear_control_FFT4



// This decimator is used in all FFT modules, and the 4X4 crossbar.
module decimator_4 (DI, D1, D2, D3, D4, ri, ai, 
                    r1, r2, r3, r4, a1, a2, a3, a4, reset);

  input ri, a1, a2, a3, a4, reset;
  input [31:0] DI;
  output ai, r1, r2, r3, r4;
  output [31:0] D1, D2, D3, D4;
  
  wire [3:0] enable;
  /*wire w0;*/
  
  shift_reg_4 SR0 (ai, reset, enable);
  
   // Need to break cycles from a1 to r1, so make this be an explicit gate:
   /*
  assign r1 = ri & enable[0];
  assign r2 = ri & enable[1];
  assign r3 = ri & enable[2];
  assign r4 = ri & enable[3];
    */
   AND2X1A12TR dec4_0 ( .A(ri), .B(enable[0]), .Y(r1) );
   AND2X1A12TR dec4_1 ( .A(ri), .B(enable[1]), .Y(r2) );
   AND2X1A12TR dec4_2 ( .A(ri), .B(enable[2]), .Y(r3) );
   AND2X1A12TR dec4_3 ( .A(ri), .B(enable[3]), .Y(r4) );

   // Need to break cycles from ai to ai, so make this an explicit gate:
   /*
  bufif1 TB0 (w0, a1, enable[0]);
  bufif1 TB1 (w0, a2, enable[1]);
  bufif1 TB2 (w0, a3, enable[2]);
  bufif1 TB3 (w0, a4, enable[3]);
    */
   /*
   BUFZX1A12TR dec4_4 ( .A(a1), .OE(enable[0]), .Y(w0) );
   BUFZX1A12TR dec4_5 ( .A(a2), .OE(enable[1]), .Y(w0) );
   BUFZX1A12TR dec4_6 ( .A(a3), .OE(enable[2]), .Y(w0) );
   BUFZX1A12TR dec4_7 ( .A(a4), .OE(enable[3]), .Y(w0) );
  assign ai = w0;
    */
   // this cuts the cycle so we can express this logically
   assign ai = a1 | a2 | a3 | a4;
  
  assign D1 = DI;
  assign D2 = DI;
  assign D3 = DI;
  assign D4 = DI;

endmodule // decimator_4

module bcast_fork (bi, bo0, bo1, ji0, ji1, jo);
   input  bi, ji0, ji1;
   output bo0, bo1, jo;

   // c-element related Timing constraints
   // set_data_check -clock */bcastc/celt0/ZN -fall_from */bcastc/celt0/C -rise_to */bcastc/celt0/A -hold 0
   // set_data_check -clock */bcastc/celt0/ZN -fall_from */bcastc/celt0/C -rise_to */bcastc/celt0/B -hold 0
   // set_data_check -clock */bcastc/celt0/ZN -rise_from */bcastc/celt0/C -fall_to */bcastc/celt0/A -hold 0
   // set_data_check -clock */bcastc/celt0/ZN -rise_from */bcastc/celt0/C -fall_to */bcastc/celt0/A -hold 0

   // The type of c-element will dictate the timing requirements
   c_element   bcastc  (.y(jo), .a(ji0), .b(ji1));
   assign bo0 = bi;
   assign bo1 = bi;

endmodule // bcast_fork

module latch_16_FFT4
  (
   input  [15:0]     d,         // latch input data d
   input             clk,       // latch clock
   output reg [15:0] q          // latch output data q
   );

   /*LATQX1A12TR latch0   ( .G(clk), .D(d[0]),  .Q(q[0])  );
   LATQX1A12TR latch1   ( .G(clk), .D(d[1]),  .Q(q[1])  );
   LATQX1A12TR latch2   ( .G(clk), .D(d[2]),  .Q(q[2])  );
   LATQX1A12TR latch3   ( .G(clk), .D(d[3]),  .Q(q[3])  );
   LATQX1A12TR latch4   ( .G(clk), .D(d[4]),  .Q(q[4])  );
   LATQX1A12TR latch5   ( .G(clk), .D(d[5]),  .Q(q[5])  );
   LATQX1A12TR latch6   ( .G(clk), .D(d[6]),  .Q(q[6])  );
   LATQX1A12TR latch7   ( .G(clk), .D(d[7]),  .Q(q[7])  );
   LATQX1A12TR latch8   ( .G(clk), .D(d[8]),  .Q(q[8])  );
   LATQX1A12TR latch9   ( .G(clk), .D(d[9]),  .Q(q[9])  );
   LATQX1A12TR latch10  ( .G(clk), .D(d[10]), .Q(q[10]) );
   LATQX1A12TR latch11  ( .G(clk), .D(d[11]), .Q(q[11]) );
   LATQX1A12TR latch12  ( .G(clk), .D(d[12]), .Q(q[12]) );
   LATQX1A12TR latch13  ( .G(clk), .D(d[13]), .Q(q[13]) );
   LATQX1A12TR latch14  ( .G(clk), .D(d[14]), .Q(q[14]) );
   LATQX1A12TR latch15  ( .G(clk), .D(d[15]), .Q(q[15]) );
   */
   always @ (d or clk) begin
	if (clk) begin
	    q <= d;
	end
   end

endmodule // latch_16_FFT4



// The adder/subtractor units for the FFT 4 module
module add_sub (A, B, S, D);

input [15:0] A, B;
output [15:0] S, D;

assign S = A + B;
assign D = A - B;

endmodule // add_sub



// Used in the FFT 4 and 16 modules, and both crossbar modules.
module expander_4 (D1, D2, D3, D4, DO, r1, r2, r3, r4, 
                   a1, a2, a3, a4, ro, ao, reset);

  input r1, r2, r3, r4, ao, reset;
  input [31:0] D1, D2, D3, D4;
  output a1, a2, a3, a4, ro;
  output [31:0] DO;
  
  wire [3:0] enable;
  
  shift_reg_4 SR0 (ao, reset, enable);
  
   // Need to break cycles ra(ao)->rr(ro) cycle, so make this be an explicit gate:
   /*
  bufif1 TB0 (ro, r1, enable[0]);
  bufif1 TB1 (ro, r2, enable[1]);
  bufif1 TB2 (ro, r3, enable[2]);
  bufif1 TB3 (ro, r4, enable[3]);
    */
   /*
   BUFZX1A12TR exp4_0 ( .A(r1), .OE(enable[0]), .Y(ro) );
   BUFZX1A12TR exp4_1 ( .A(r2), .OE(enable[1]), .Y(ro) );
   BUFZX1A12TR exp4_2 ( .A(r3), .OE(enable[2]), .Y(ro) );
   BUFZX1A12TR exp4_3 ( .A(r4), .OE(enable[3]), .Y(ro) );
    */
   // this cuts the cycle so we can express this logically
   //assign    ro = r1 & enable[0] | r2 & enable[1] | r3 & enable[2] | r4 & enable[3];
   // kss: This has potential races and hazards...  Need to redo the expander cells?
   AOI22X1A12TR exp4_0 ( .A0(r1), .A1(enable[0]), .B0(r2), .B1(enable[1]), .Y(n0));
   AOI22X1A12TR exp4_1 ( .A0(r3), .A1(enable[2]), .B0(r4), .B1(enable[3]), .Y(n1));
   NAND2X1A12TR exp4_2 ( .A(n0), .B(n1), .Y(ro) );

  buffer_4 U0 (D1, D2, D3, D4, DO, enable);
  
   // Need to break cycles ao -> ai, so make this an explicit gate:
   /*
  assign a1 = ao & enable[0];
  assign a2 = ao & enable[1];
  assign a3 = ao & enable[2];
  assign a4 = ao & enable[3];
    */
   AND2X1A12TR exp4_4 ( .A(ao), .B(enable[0]), .Y(a1) );
   AND2X1A12TR exp4_5 ( .A(ao), .B(enable[1]), .Y(a2) );
   AND2X1A12TR exp4_6 ( .A(ao), .B(enable[2]), .Y(a3) );
   AND2X1A12TR exp4_7 ( .A(ao), .B(enable[3]), .Y(a4) );


endmodule // expander_4



// This module is used in several modules, mostly the
// 1 to 4 decimator, and 4 to 1 expander.
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
       // too inefficient:
//        case (out)
//          4'b0001: out <= 4'b0010;
//          4'b0010: out <= 4'b0100;
//          4'b0100: out <= 4'b1000;
//          4'b1000: out <= 4'b0001;
//          default: out <= 4'b0001;
//        endcase
      end
    end
  
 endmodule // shift_reg



module c_element (y, a, b);
   input  a, b;
   output y;
   // behavioral description:
   //assign #2 y = (a & b) | (a & y) | (b & y);
   
   // Artisan
   /////////////////////////////////////////////////////////////////////////
   // LOCAL CONSTRAINTS (with Artisan):
   // y+ |--> a- > by-   or   y+ |--> ab+ > by-
   // y+ |--> b- > ay-   or   y+ |--> ab+ > ay-
   // Assume external delay is sufficient, make it a setup constraint:
   // Speed up feedback, don't slow down input to output path...
   // set_data_check -rise_from */c_element3/A -fall_to */c_element3/C -setup 0
   // set_data_check -rise_from */c_element3/A -fall_to */c_element3/B -setup 0
   /////////////////////////////////////////////////////////////////////////
   //
   wire   ab, ay, by;
   NAND2X1A12TR  c_element0  (.A(a), .B(b), .Y(ab));
   NAND2X1A12TR  c_element1  (.A(a), .B(y), .Y(ay));
   NAND2X1A12TR  c_element2  (.A(b), .B(y), .Y(by));
   NAND3X1A12TR  c_element3  (.A(ab),.B(ay),.C(by), .Y(y));

endmodule // c_element



// Just a module to buffer the outputs for the 4 to 1 expander
// and the FFT 16 constant blocks.
module buffer_4 (B1, B2, B3, B4, BO, enable);

  input [31:0] B1, B2, B3, B4;
  input [3:0] enable;
  output [31:0] BO;
  
     // too complex:
  //reg [31:0] BO;
//   always @(enable or B1 or B2 or B3 or B4)
//     begin
//      case (enable)
//        4'b0001: BO <= B1;
//        4'b0010: BO <= B2;
//        4'b0100: BO <= B3;
//        4'b1000: BO <= B4;
//        default: BO <= B1;
//      endcase
//     end

   assign BO =
	  (enable[0] == 1) ? B1 :
	  (enable[1] == 1) ? B2 :
	  (enable[2] == 1) ? B3 :
	  (enable[3] == 1) ? B4 : B1;


endmodule // buffer_4

