//-------------------------------------------------------
// ElasticComponents.v
//-------------------------------------------------------

// module DELAY2 (output Y, input A);

// wire A1;
//INVX1 U0 (.Y(A1),.A(A));
//INVX1 U1 (.Y(Y),.A(A1));

//endmodule



module PDFFS (input                  clk, set,
                 input       d, 
                 output   q);
 


// A workaround as the UofU library doesn't contain PDFFS.
wire qi;
ILatchLR U0 (.clk(clk),.rst(set),.d(d),.q(qi));
ILatchHS U1 (.clk(clk),.set(set),.d(qi),.q(q));

endmodule



module PDFF (input                  clk,
                 input       d, 
                 output reg  q);
 
   always @(posedge clk)
       q <= d;
endmodule




module ILatchHR (input                  clk,rst,d,
            output  q);
// 1 bit, Latch HI, active HI asynchronous reset, Q is inverted with respect to D.

wire rstb;
INVX1 U0 (.Y(rstb), .A(rst));
LCX1 U1 (.Q(q),.CLR(rstb),.D(d),.G(clk));
endmodule



module ILatchLR (input                  clk,rst,d,
            output  q);
// 1 bit, Latch LO, active HI asynchronous reset, Q is inverted with respect to D.

wire rstb;
INVX1 U0 (.Y(rstb), .A(rst));
LCNX1 U1 (.Q(q),.CLR(rstb),.D(d),.G(clk));
endmodule


module ILatchHS (input                  clk,set,d,
            output q);
// 1 bit, Latch HI, active HI synchronous set, Q is inverted with respect to D. 

wire db,di,clr;
INVX1 U0 (.Y(db), .A(d));
NOR2X1 U1 (.Y(di),.A(set),.B(db)); //.B is faster
TIEHI U2 (.Y(clr));
LCX1 U3 (.Q(q),.CLR(clr),.D(di),.G(clk));
endmodule


module ILatchLS (input                  clk,set,d,
            output   q);
// 1 bit, Latch LO, active HI synchronous set, Q is inverted with respect to D. 

wire db,di,clr;
INVX1 U0 (.Y(db), .A(d));
NOR2X1 U1 (.Y(di),.A(set),.B(db));
TIEHI U2 (.Y(clr));
LCNX1 U3 (.Q(q),.CLR(clr),.D(di),.G(clk));
endmodule

module ILatchHREn (input clk,rst,en, input  d, output  q);

// 1 bit, Latch HI, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.
wire rstb, clki;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
INVX1 U1 (.Y(rstb), .A(rst));
NAND2X2 U2 (.Y(clki), .A(en), .B(clk)); // .B is faster
// LCNX1 U3 (.Q(q),.CLR(rstb),.D(di),.G(clki));
LCNX1 U3 (.Q(q),.CLR(rstb),.D(d),.G(clki));   
endmodule



module ILatchHR2En (input clk,rst,en1,en2, input  d, output  q);

// 1 bit, Latch HI, active HI asynchronous reset, active HI enable1, active HI enable2, Q is inverted with respect to D.
wire rstb, clki;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
INVX1 U1 (.Y(rstb), .A(rst));
NAND3X1 U2 (.Y(clki), .A(en1), .B(en2), .C(clk)); // .c is faster
// LCNX1 U3 (.Q(q),.CLR(rstb),.D(di),.G(clki));
LCNX1 U3 (.Q(q),.CLR(rstb),.D(d),.G(clki));
   
endmodule





module ILatchHEn (input clk,en, input  d, output  q);

// 1 bit, Latch HI, no reset, active HI enable, Q is inverted with respect to D.
wire clr, clki;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
TIEHI U1 (.Y(clr));
NAND2X2 U2 (.Y(clki), .A(en), .B(clk)); // .B is faster
// LCNX1 U3 (.Q(q),.CLR(clr),.D(di),.G(clki));
LCNX1 U3 (.Q(q),.CLR(clr),.D(d),.G(clki));
   
endmodule


module ILatchH2En (input clk,en1,en2, input  d, output  q);

// 1 bit, Latch HI, no reset, 2-active HI enable, Q is inverted with respect to D.
wire clr, clki;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
TIEHI U1 (.Y(clr));
NAND3X1 U2 (.Y(clki), .A(en1), .B(en2), .C(clk)); // .C is faster
// LCNX1 U3 (.Q(q),.CLR(clr),.D(di),.G(clki));
LCNX1 U3 (.Q(q),.CLR(clr),.D(d),.G(clki));
   
endmodule





module ILatchLREn (input clk,rst,en, input  d, output  q);

// 1 bit, Latch LO, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.
wire rstb, clki, enb;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
INVX1 U1 (.Y(rstb), .A(rst));
INVX1 U2 (.Y(enb), .A(en));
NOR2X2 U3 (.Y(clki), .A(enb), .B(clk)); // .B is faster
// LCX1 U4 (.Q(q),.CLR(rstb),.D(di),.G(clki));
LCX1 U4 (.Q(q),.CLR(rstb),.D(d),.G(clki));
   
endmodule


module ILatchLR2En (input clk,rst,en1,en2, input  d, output  q);

// 1 bit, Latch LO, active HI asynchronous reset, 2-active HI enable, Q is inverted with respect to D.
wire rstb, clki, enb;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
INVX1 U1 (.Y(rstb), .A(rst));
NAND2X1 U2 (.Y(enb), .A(en1), .B(en2));
NOR2X2 U3 (.Y(clki), .A(enb), .B(clk)); // .B is faster
// LCX1 U4 (.Q(q),.CLR(rstb),.D(di),.G(clki));
LCX1 U4 (.Q(q),.CLR(rstb),.D(d),.G(clki));
   
endmodule


module ILatchLEn (input clk,en, input  d, output  q);

// 1 bit, Latch LO, no reset, active HI enable, Q is inverted with respect to D.
wire  clki, enb,clr;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
TIEHI U1 (.Y(clr));
INVX1 U2 (.Y(enb), .A(en));
NOR2X2 U3 (.Y(clki), .A(enb), .B(clk)); // .B is faster
// LCX1 U4 (.Q(q),.CLR(clr),.D(di),.G(clki));
LCX1 U4 (.Q(q),.CLR(clr),.D(d),.G(clki));
   
endmodule

module ILatchL2En (input clk,en1,en2, input  d, output  q);

// 1 bit, Latch LO, no reset, 2-active HI enable, Q is inverted with respect to D.
wire  clki, enb,clr;

// DELAY2 U0 (.Y(di), .A(d)); // Delay D signal so that G is always ahead of D. May require more or less delay, though.
TIEHI U1 (.Y(clr));
NAND2X1 U2 (.Y(enb), .A(en1), .B(en2));
NOR2X2 U3 (.Y(clki), .A(enb), .B(clk)); // .B is faster
// LCX1 U4 (.Q(q),.CLR(clr),.D(di),.G(clki));
LCX1 U4 (.Q(q),.CLR(clr),.D(d),.G(clki));
   
endmodule


module ILatchHREn_8 
(input clk,rst,en, input [7:0] d, output  [7:0] q);
// 8 bit, Latch HI, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.

ILatchHREn U0 (.clk(clk),.rst(rst),.en(en),.d(d[0]),.q(q[0]));
ILatchHREn U1 (.clk(clk),.rst(rst),.en(en),.d(d[1]),.q(q[1]));
ILatchHREn U2 (.clk(clk),.rst(rst),.en(en),.d(d[2]),.q(q[2]));
ILatchHREn U3 (.clk(clk),.rst(rst),.en(en),.d(d[3]),.q(q[3]));
ILatchHREn U4 (.clk(clk),.rst(rst),.en(en),.d(d[4]),.q(q[4]));
ILatchHREn U5 (.clk(clk),.rst(rst),.en(en),.d(d[5]),.q(q[5]));
ILatchHREn U6 (.clk(clk),.rst(rst),.en(en),.d(d[6]),.q(q[6]));
ILatchHREn U7 (.clk(clk),.rst(rst),.en(en),.d(d[7]),.q(q[7]));

endmodule


module ILatchHREn_4 
(input clk,rst,en, input [3:0] d, output  [3:0] q);
// 4-bit, Latch HI, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.

ILatchHREn U0 (.clk(clk),.rst(rst),.en(en),.d(d[0]),.q(q[0]));
ILatchHREn U1 (.clk(clk),.rst(rst),.en(en),.d(d[1]),.q(q[1]));
ILatchHREn U2 (.clk(clk),.rst(rst),.en(en),.d(d[2]),.q(q[2]));
ILatchHREn U3 (.clk(clk),.rst(rst),.en(en),.d(d[3]),.q(q[3]));

endmodule


module ILatchHR2En_8 
(input clk,rst,en1,en2, input [7:0] d, output  [7:0] q);
// 8 bit, Latch HI, active HI asynchronous reset, 2 active HI enable, Q is inverted with respect to D.

ILatchHR2En U0 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[0]),.q(q[0]));
ILatchHR2En U1 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[1]),.q(q[1]));
ILatchHR2En U2 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[2]),.q(q[2]));
ILatchHR2En U3 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[3]),.q(q[3]));
ILatchHR2En U4 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[4]),.q(q[4]));
ILatchHR2En U5 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[5]),.q(q[5]));
ILatchHR2En U6 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[6]),.q(q[6]));
ILatchHR2En U7 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[7]),.q(q[7]));


endmodule


module ILatchHEn_8 
(input clk,en, input [7:0] d, output  [7:0] q);
// 8 bit, Latch HI, no reset, active HI enable, Q is inverted with respect to D.

ILatchHEn U0 (.clk(clk),.en(en),.d(d[0]),.q(q[0]));
ILatchHEn U1 (.clk(clk),.en(en),.d(d[1]),.q(q[1]));
ILatchHEn U2 (.clk(clk),.en(en),.d(d[2]),.q(q[2]));
ILatchHEn U3 (.clk(clk),.en(en),.d(d[3]),.q(q[3]));
ILatchHEn U4 (.clk(clk),.en(en),.d(d[4]),.q(q[4]));
ILatchHEn U5 (.clk(clk),.en(en),.d(d[5]),.q(q[5]));
ILatchHEn U6 (.clk(clk),.en(en),.d(d[6]),.q(q[6]));
ILatchHEn U7 (.clk(clk),.en(en),.d(d[7]),.q(q[7]));

endmodule

module ILatchH2En_8 
(input clk,en1,en2, input [7:0] d, output  [7:0] q);
// 8 bit, Latch HI, no reset, 2 active HI enable, Q is inverted with respect to D.

ILatchH2En U0 (.clk(clk),.en1(en1),.en2(en2),.d(d[0]),.q(q[0]));
ILatchH2En U1 (.clk(clk),.en1(en1),.en2(en2),.d(d[1]),.q(q[1]));
ILatchH2En U2 (.clk(clk),.en1(en1),.en2(en2),.d(d[2]),.q(q[2]));
ILatchH2En U3 (.clk(clk),.en1(en1),.en2(en2),.d(d[3]),.q(q[3]));
ILatchH2En U4 (.clk(clk),.en1(en1),.en2(en2),.d(d[4]),.q(q[4]));
ILatchH2En U5 (.clk(clk),.en1(en1),.en2(en2),.d(d[5]),.q(q[5]));
ILatchH2En U6 (.clk(clk),.en1(en1),.en2(en2),.d(d[6]),.q(q[6]));
ILatchH2En U7 (.clk(clk),.en1(en1),.en2(en2),.d(d[7]),.q(q[7]));


endmodule


module ILatchLREn_8 
(input clk,rst,en, input [7:0] d, output  [7:0] q);
// 8 bit, Latch LO, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.

ILatchLREn U0 (.clk(clk),.rst(rst),.en(en),.d(d[0]),.q(q[0]));
ILatchLREn U1 (.clk(clk),.rst(rst),.en(en),.d(d[1]),.q(q[1]));
ILatchLREn U2 (.clk(clk),.rst(rst),.en(en),.d(d[2]),.q(q[2]));
ILatchLREn U3 (.clk(clk),.rst(rst),.en(en),.d(d[3]),.q(q[3]));
ILatchLREn U4 (.clk(clk),.rst(rst),.en(en),.d(d[4]),.q(q[4]));
ILatchLREn U5 (.clk(clk),.rst(rst),.en(en),.d(d[5]),.q(q[5]));
ILatchLREn U6 (.clk(clk),.rst(rst),.en(en),.d(d[6]),.q(q[6]));
ILatchLREn U7 (.clk(clk),.rst(rst),.en(en),.d(d[7]),.q(q[7]));

endmodule

module ILatchLREn_4 
(input clk,rst,en, input [3:0] d, output  [3:0] q);
// 4 bit, Latch LO, active HI asynchronous reset, active HI enable, Q is inverted with respect to D.

ILatchLREn U0 (.clk(clk),.rst(rst),.en(en),.d(d[0]),.q(q[0]));
ILatchLREn U1 (.clk(clk),.rst(rst),.en(en),.d(d[1]),.q(q[1]));
ILatchLREn U2 (.clk(clk),.rst(rst),.en(en),.d(d[2]),.q(q[2]));
ILatchLREn U3 (.clk(clk),.rst(rst),.en(en),.d(d[3]),.q(q[3]));


endmodule





module ILatchLR2En_8 
(input clk,rst,en1,en2, input [7:0] d, output  [7:0] q);
// 8 bit, Latch LO, active HI asynchronous reset, 2 active HI enable, Q is inverted with respect to D.

ILatchLR2En U0 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[0]),.q(q[0]));
ILatchLR2En U1 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[1]),.q(q[1]));
ILatchLR2En U2 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[2]),.q(q[2]));
ILatchLR2En U3 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[3]),.q(q[3]));
ILatchLR2En U4 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[4]),.q(q[4]));
ILatchLR2En U5 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[5]),.q(q[5]));
ILatchLR2En U6 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[6]),.q(q[6]));
ILatchLR2En U7 (.clk(clk),.rst(rst),.en1(en1),.en2(en2),.d(d[7]),.q(q[7]));


endmodule


module ILatchLEn_8 
(input clk,en, input [7:0] d, output  [7:0] q);
// 8 bit, Latch LO, no reset, active HI enable, Q is inverted with respect to D.

ILatchLEn U0 (.clk(clk),.en(en),.d(d[0]),.q(q[0]));
ILatchLEn U1 (.clk(clk),.en(en),.d(d[1]),.q(q[1]));
ILatchLEn U2 (.clk(clk),.en(en),.d(d[2]),.q(q[2]));
ILatchLEn U3 (.clk(clk),.en(en),.d(d[3]),.q(q[3]));
ILatchLEn U4 (.clk(clk),.en(en),.d(d[4]),.q(q[4]));
ILatchLEn U5 (.clk(clk),.en(en),.d(d[5]),.q(q[5]));
ILatchLEn U6 (.clk(clk),.en(en),.d(d[6]),.q(q[6]));
ILatchLEn U7 (.clk(clk),.en(en),.d(d[7]),.q(q[7]));

endmodule


module ILatchL2En_8 
(input clk,en1,en2, input [7:0] d, output  [7:0] q);
// 8 bit, Latch LO, no reset, 2 active HI enable, Q is inverted with respect to D.

ILatchL2En U0 (.clk(clk),.en1(en1),.en2(en2),.d(d[0]),.q(q[0]));
ILatchL2En U1 (.clk(clk),.en1(en1),.en2(en2),.d(d[1]),.q(q[1]));
ILatchL2En U2 (.clk(clk),.en1(en1),.en2(en2),.d(d[2]),.q(q[2]));
ILatchL2En U3 (.clk(clk),.en1(en1),.en2(en2),.d(d[3]),.q(q[3]));
ILatchL2En U4 (.clk(clk),.en1(en1),.en2(en2),.d(d[4]),.q(q[4]));
ILatchL2En U5 (.clk(clk),.en1(en1),.en2(en2),.d(d[5]),.q(q[5]));
ILatchL2En U6 (.clk(clk),.en1(en1),.en2(en2),.d(d[6]),.q(q[6]));
ILatchL2En U7 (.clk(clk),.en1(en1),.en2(en2),.d(d[7]),.q(q[7]));


endmodule






module EBControl (input clk,rst,Vl,Sr, output Vr,Sl,Em,Es);

wire a,b,c,d,e,f,db,Vlb;

ILatchHS iLHS1 (clk,rst,c,Vr);
ILatchHR iLHR1 (clk,rst,f,Sl);
ILatchLS iLLS2 (clk,rst,a,b);
ILatchLR iLLR2 (clk,rst,e,d);

INVX1 U0 (.Y(Vlb), .A(Vl));
INVX1 U1 (.Y(db), .A(d));
NOR2X1 U2 (.Y(Em), .A(Vlb), .B(Sl));
NOR2X1 U3 (.Y(Es), .A(db), .B(b));
NOR2X1 U4 (.Y(e), .A(Vl), .B(Sl));
NOR2X1 U5 (.Y(c), .A(b), .B(d));
NAND2X1 U6 (.Y(f), .A(b), .B(d));
NAND2X1 U7 (.Y(a), .A(Vr), .B(Sr));

endmodule

module EBBubbleControl (input clk,rst,Vl,Sr, output Vr,Sl,Em,Es);

wire a,b,c,d,e,f,db,Vlb;
ILatchHR iLHR1 (clk,rst,c,Vr);
ILatchHR iLHR2 (clk,rst,f,Sl);
ILatchLR iLLR1 (clk,rst,a,b);
ILatchLR iLLR2 (clk,rst,e,d);

INVX1 U0 (.Y(Vlb), .A(Vl));
INVX1 U1 (.Y(db), .A(d));
NOR2X1 U2 (.Y(Em), .A(Vlb), .B(Sl));
NOR2X1 U3 (.Y(Es), .A(db), .B(b));
NOR2X1 U4 (.Y(e), .A(Vl), .B(Sl));
NOR2X1 U5 (.Y(c), .A(b), .B(d));
NAND2X1 U6 (.Y(f), .A(b), .B(d));
NAND2X1 U7 (.Y(a), .A(Vr), .B(Sr));

endmodule


module EB_8
(input clk,rst,
input [7:0] Dl,
input Vl,Sr, 
output [7:0] Dr,
output Vr,Sl);
// 8-bit Elastic Buffer without data reset neither data enable. Control channels, though, must have a reset.

wire [7:0] m;
ILatchLEn_8 U0 (.clk(clk),.en(Em),.d(Dl),.q(m));
ILatchHEn_8 U1 (.clk(clk),.en(Es),.d(m),.q(Dr));
EBControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule


module EBR_8 
(input clk,rst,
input [7:0] Dl,
input Vl,Sr, 
output [7:0] Dr,
output Vr,Sl);
// 8-bit Elastic Buffer with data reset but without data enable.
wire [7:0] m;
ILatchLREn_8  lLRE1(clk,rst,Em,Dl,m);
ILatchHREn_8  lHRE1(clk,rst,Es,m,Dr);
EBControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule


module EBR_4 
(input clk,rst,
input [3:0] Dl,
input Vl,Sr, 
output [3:0] Dr,
output Vr,Sl);
// 4-bit Elastic Buffer with data reset but without data enable.
wire [3:0] m;
ILatchLREn_4  lLRE1(clk,rst,Em,Dl,m);
ILatchHREn_4  lHRE1(clk,rst,Es,m,Dr);
EBControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule


module EBBubbleR_8
(input clk,rst,
input [7:0] Dl,
input Vl,Sr, 
output [7:0] Dr,
output Vr,Sl);
// Elastic Buffer with data reset
wire [7:0] m;
ILatchLREn_8  lLRE1(clk,rst,Em,Dl,m);
ILatchHREn_8  lHRE1(clk,rst,Es,m,Dr);
EBBubbleControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule


module EBREn_8
(input clk,rst,en,
input [7:0] Dl,
input Vl,Sr, 
output [7:0] Dr,
output Vr,Sl);
// Elastic Buffer with data reset and date enable.

wire [7:0] m;
wire Es,Em;

ILatchLR2En_8 U0 (.clk(clk),.rst(rst),.en1(en),.en2(Em),.d(Dl),.q(m));
ILatchHR2En_8 U1 (.clk(clk),.rst(rst),.en1(en),.en2(Es),.d(m),.q(Dr));
EBControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule


module EBEn_8
(input clk,rst,en,
input [7:0] Dl,
input Vl,Sr, 
output [7:0] Dr,
output Vr,Sl);
// Elastic Buffer with date enable, but without data reset. Control channels, though, must have a reset. 

wire [7:0] m;

wire Es,Em;


ILatchL2En_8 U0 (.clk(clk),.en1(en),.en2(Em),.d(Dl),.q(m));
ILatchH2En_8 U1 (.clk(clk),.en1(en),.en2(Es),.d(m),.q(Dr));
EBControl eBCtl1(clk,rst,Vl,Sr,Vr,Sl,Em,Es);
endmodule






module Join2(input Vl1,Vl2,Sr, output Vr,Sl1,Sl2);

wire w,Vl1b,Vl2b,Vrb;

INVX1 U0 (.Y(Vl1b),.A(Vl1));
INVX1 U1 (.Y(Vl2b),.A(Vl2));
INVX1 U2 (.Y(Vrb),.A(Vr));
NOR2X1 U3 (.Y(Sl1),.A(Vl1b),.B(w));
NOR2X1 U4 (.Y(Sl2),.A(Vl2b),.B(w));
NOR2X1 U5 (.Y(Vr),.A(Vl1b),.B(Vl2b));
NOR2X1 U6 (.Y(w),.A(Vrb),.B(Sr));

endmodule


module Join3(input Vl1,Vl2,Vl3,Sr, output Vr,Sl1,Sl2,Sl3);

wire Vi;
wire Si;

Join2 Join21(Vl1,Vl2,Si,Vi,Sl1,Sl2);
Join2 Join22(Vi,Vl3,Sr,Vr,Si,Sl3);

endmodule


module Join4(input Vl1,Vl2,Vl3,Vl4,Sr, output Vr,Sl1,Sl2,Sl3,Sl4);

wire Vi;
wire Si;

Join3 Join31(Vl1,Vl2,Vi,Sr,Vr,Sl1,Sl2,Si);
Join2 Join21(Vl3,Vl4,Si,Vi,Sl3,Sl4);
endmodule


module Join5(input Vl1,Vl2,Vl3,Vl4,Vl5,Sr, output Vr,Sl1,Sl2,Sl3,Sl4,Sl5);

wire Vi;
wire Si;

Join3 Join31(Vl1,Vl2,Vi,Sr,Vr,Sl1,Sl2,Si);
Join3 Join32(Vl3,Vl4,Vl5,Si,Vi,Sl3,Sl4,Sl5);

endmodule

module Join6(input Vl1,Vl2,Vl3,Vl4,Vl5,Vl6,Sr, output Vr,Sl1,Sl2,Sl3,Sl4,Sl5,Sl6);

wire Vi;
wire Si;

Join5 Join51(Vl1,Vl2,Vl3,Vl4,Vi,Sr,Vr,Sl1,Sl2,Sl3,Sl4,Si);
Join2 Join21(Vl5,Vl6,Si,Vi,Sl5,Sl6);

endmodule


module EFork2(input clk,rst,Vl,Sr1,Sr2,output Vr1,Vr2,Sl);

wire a,b,c,d,e,f,g;
wire Vlb,Slb,cb,eb;
PDFFS pDFFS1(clk,rst,d,e);
PDFFS pDFFS0(clk,rst,b,c);

INVX1 U0 (.Y(Vlb),.A(Vl));
INVX1 U1 (.Y(Slb),.A(Sl));
INVX1 U2 (.Y(cb),.A(c));
INVX1 U3 (.Y(eb),.A(e));

NOR2X1 U4 (.Y(g),.A(Vlb),.B(Slb));
NOR2X1 U5 (.Y(Vr1),.A(cb),.B(Vlb));
NOR2X1 U6 (.Y(Vr2),.A(eb),.B(Vlb));

NAND2X1 U7 (.Y(f),.A(e),.B(Sr2));
NAND2X1 U8 (.Y(Sl),.A(a),.B(f));
NAND2X1 U9 (.Y(d),.A(g),.B(f));
NAND2X1 U10 (.Y(b),.A(a),.B(g));
NAND2X1 U11 (.Y(a),.A(Sr1),.B(c));

endmodule
   



module EFork3(input clk,rst,Vl,Sr1,Sr2,Sr3,output Vr1,Vr2,Vr3,Sl);

wire Vi;
wire Si;
EFork2 EFork21(clk,rst,Vl,Si,Sr3,Vi,Vr3,Sl);
EFork2 EFork22(clk,rst,Vi,Sr1,Sr2,Vr1,Vr2,Si);
endmodule


module EFork4(input clk,rst,Vl,Sr1,Sr2,Sr3,Sr4,output Vr1,Vr2,Vr3,Vr4,Sl);

wire Vi;
wire Si;
EFork3 EFork31(clk,rst,Vl,Sr1,Sr2,Si,Vr1,Vr2,Vi,Sl);
EFork2 EFork21(clk,rst,Vi,Sr3,Sr4,Vr3,Vr4,Si);
endmodule

module EFork5(input clk,rst,Vl,Sr1,Sr2,Sr3,Sr4,Sr5,output Vr1,Vr2,Vr3,Vr4,Vr5,Sl);

wire Vi;
wire Si;


EFork3 EFork31(clk,rst,Vl,Sr1,Sr2,Si,Vr1,Vr2,Vi,Sl);
EFork3 EFork32(clk,rst,Vi,Sr3,Sr4,Sr5,Vr3,Vr4,Vr5,Si);

endmodule

module EFork6(input clk,rst,Vl,Sr1,Sr2,Sr3,Sr4,Sr5,Sr6,output Vr1,Vr2,Vr3,Vr4,Vr5,Vr6,Sl);

wire Vi;
wire Si;


EFork5 EFork51(clk,rst,Vl,Sr1,Sr2,Sr3,Sr4,Si,Vr1,Vr2,Vr3,Vr4,Vi,Sl);
EFork2 EFork21(clk,rst,Vi,Sr5,Sr6,Vr5,Vr6,Si);

endmodule







//module mux2 #(parameter WIDTH = 8)
//             (input              s,
//              input  [WIDTH-1:0] d0, d1,                
//              output [WIDTH-1:0] y);
//
//   assign y = s ? d1 : d0; 
//endmodule





 





