//----------------------------------------------------------------------
//This is datapath around alu.
//----------------------------------------------------------------------

module alu_datapath (rst, pc, srcA, srcB, instr, immx4, mux2_cntrl, mux4_cntrl
                     alu_cntrl, srcA_cntrl, srcB_cntrl, aluout_cntrl, alu_out, zero_out);
//asume we need zero output
//need control  of alu operation, AluControl[2:0]

input rst;
input [7:0] pc, srcA, srcB, instr, immx4;
input mux2_cntrl, srcA_cntrl, srcB_cntrl, aluout_cntrl;
input [1:0] mux4_cntrl;
input [2:0] alu_cntrl;

output [7:0] alu_out;
output zero_out;

//wire for mux to latch
wire mux2TolatchA, mux4TolatchB;
//wire for latch to alu
wire latchAToalu, latchBToalu;
//wire for alu to latch
wire aluoutTolatch, zeroTolatch;

//D flipflop
Dflipflop8 latchA(.clk(srcA_cntrl), .rst(rst), .a(mux2TolatchA), .b(latchAToalu));
Dflipflop8 latchB(.clk(srcB_cntrl), .rst(rst), .a(mux4TolatchB), .b(latchBToalu));
Dflipflop8 latchOut(.clk(aluout_cntrl), .rst(rst), .a(aluoutTolatch), .b(alu_out));
Dflipflop1 latchZero(.clk(aluout_cntrl), .rst(rst), .a(zeroTolatch), .b(zero_out));

//mux
mux2 srcAmux(.in0(pc), .in1(srcA), .sel(mux2_cntrl), .out(mux2TolatchA));
mux4 srcBmux(.in0(srcB), .in1('b1), .in2(instrc), .in3(immx4), .sel(mux4_cntrl), .out(mux4TolatchB));

//alu
alu alu1( .a(latchAToalu), .b(latchBToalu), .alu_cntrl(alu_cntrl), .alu_out(aluoutTolatch), .alu_zero(zeroTolatch));
		  		  
endmodule //alu_datapah

module Dflipflop8 (clk, rst, a, b)
input clk;
input [7:0] a ;
output [7:0] b ;
reg [7:0] b ;

always @(posedge clk, posedge rst)
if (rst) b <= 8¡®b0; else b <= a;

endmodule //Dflipflop8

module Dflipflop11 (clk, rst, a, b)
input clk;
input a ;
output b ;
reg b ;

always @(posedge clk, posedge rst)
if (rst) b <= 1¡®b0; else b <= a;

endmodule //Dflipflop1

module mux2 (in0, in1, sel, out)
input [7:0] in0, in1;
input sel;
output [7:0] out;

assign out = sel ? in1 : in2;
endmodule //mux2	

module mux4 (in0, in1, in2, in3, sel, out)
input [7:0] in0, in1, in2, in3;
input [1:0] sel;
output [7:0] out;
case (sel)
2'b00: out = in0;
2'b01: out = in1;
2'b10: out = in2;
2'b11: out = in3;
endcase
endmodule //mux4	

module alu ( a, b, alu_cntrl, alu_out, alu_zero);

input [7:0] a, b;
input [2:0] alu_cntrl;
output [7:0] alu_out;
output alu_zero;
 
wire [7:0] b2, andresult, orresult, sumresult, sltresult;
andN andblock(a, b, andresult);
orN orblock(a, b, orresult);
condinv binv(b, alucontrol[2], b2);
adder addblock(a, b2, alucontrol[2], sumresult);
// slt should be 1 if most significant bit of sum is 1
assign sltresult = sumresult[7];
mux4 resultmux(andresult, orresult, sumresult,
sltresult, alucontrol[1:0], result);
zerodetect zd(result, zero);
endmodule //alu

module zerodetect ( a, y);
input [7:0] a;
output [7:0] y;
assign y = (a==0);
endmodule //zerodetect

module andN ( a, b, y);
input [7:0] a, b;
output [7:0] y;
assign y = a & b;
endmodule //andN

module orN ( a, b, y);
input [7:0] a, b;
output [7:0] y;
assign y = a | b;
endmodule  //orN

module inv ( a, y);
input [7:0] a;
output [7:0] y;
assign y = ~a;
endmodule //inv

module condinv ( a,invert, y)
input [7:0] a;
input invert;
output [7:0] y;
wire [7:0] ab;
inv inverter(a, ab);
mux2 invmux(a, ab, invert, y);
endmodule //condinv	  
		  
module adder ( a, b, cin, y);
input [7:0] a, b;
output cin;
output [7:0] y;
assign y = a + b + cin;
endmodule //adder	
		  
		  
		  
		  
		  
