//-------------------------------------------------------
// mips.v
// Max Yi (byyi@hmc.edu) and David_Harris@hmc.edu 12/9/03
// Model of subset of MIPS processor described in Ch 1
// Elasticization is done by Eliyah Kilada
//-------------------------------------------------------









// simplified MIPS processor
module mipsE #(parameter WIDTH = 8, REGBITS = 3)
             (input              clk, reset, 
              input  [WIDTH-1:0] memdata, 
              output             memread, memwrite, 
              output [WIDTH-1:0] adr, writedata,
	           input VMemr,SMeml,
	           output VMeml,SMemr
);

   wire [31:0] instr;
   wire        zero, alusrca, memtoreg, iord, pcen, regwrite, regdst;
   wire [1:0]  aluop,pcsource,alusrcb;
   wire [3:0]  irwrite;
   wire [2:0]  alucont;
   

   controllerE  cont(clk, reset, instr[31:26], zero, memread, memwrite, 
                    alusrca, memtoreg, iord, pcen, regwrite, regdst,
                    pcsource, alusrcb, aluop, irwrite, VI1,SC, VC,SI1);
   alucontrol  ac(aluop, instr[5:0], alucont);
   datapathE    #(WIDTH, REGBITS) 
               dp(clk, reset, memdata, alusrca, memtoreg, iord, pcen,
                  regwrite, regdst, pcsource, alusrcb, irwrite, alucont,
                  zero, instr, adr, writedata,VC, SI1,VI1, SC,VMemr,SMeml,
                  VMeml,SMemr);  
		 	

endmodule










module controllerE(input clk, reset, 
                  input      [5:0] op, 
                  input            zero, 
                  output reg       memread, memwrite, alusrca, memtoreg, iord, 
                  output           pcen, 
                  output reg       regwrite, regdst, 
                  output reg [1:0] pcsource, alusrcb, aluop, 
                  output reg [3:0] irwrite,
		            input VI1,SC, output VC,SI1);


   // parameter   FETCH1  =  4'b0001;
   parameter   FETCH1  =  4'b0000; //EK: I made this change, since EBRC is normally reset to all Zero's! 
   parameter   FETCH2  =  4'b0010;
   parameter   FETCH3  =  4'b0011;
   parameter   FETCH4  =  4'b0100;
   parameter   DECODE  =  4'b0101;
   parameter   MEMADR  =  4'b0110;
   parameter   LBRD    =  4'b0111;
   parameter   LBWR    =  4'b1000;
   parameter   SBWR    =  4'b1001;
   parameter   RTYPEEX =  4'b1010;
   parameter   RTYPEWR =  4'b1011;
   parameter   BEQEX   =  4'b1100;
   parameter   JEX     =  4'b1101;

   parameter   LB      =  6'b100000;
   parameter   SB      =  6'b101000;
   parameter   RTYPE   =  6'b0;
   parameter   BEQ     =  6'b000100;
   parameter   J       =  6'b000010;


   reg [3:0] nextstate;
   wire [3:0] state;
   reg       pcwrite, pcwritecond;

   // state register
//   always @(posedge clk)
//      if(reset) state <= FETCH1;
//      else state <= nextstate;
EBR_4  EBRC (clk,reset,nextstate,VCI1,SCint,state ,VCint,SCI1);

EFork2 FCint(clk,reset,VCint,SCint1,SC, VCint1,VC,SCint);
Join2 JCI1(VCint1,VI1,SCI1, VCI1,SCint1,SI1);








   // next state logic
   always @(*)
      begin
         case(state)
            FETCH1:  nextstate <= FETCH2;
            FETCH2:  nextstate <= FETCH3;
            FETCH3:  nextstate <= FETCH4;
            FETCH4:  nextstate <= DECODE;
            DECODE:  case(op)
                        LB:      nextstate <= MEMADR;
                        SB:      nextstate <= MEMADR;
                        RTYPE:   nextstate <= RTYPEEX;
                        BEQ:     nextstate <= BEQEX;
                        J:       nextstate <= JEX;
                        default: nextstate <= FETCH1; // should never happen
                     endcase
            MEMADR:  case(op)
                        LB:      nextstate <= LBRD;
                        SB:      nextstate <= SBWR;
                        default: nextstate <= FETCH1; // should never happen
                     endcase
            LBRD:    nextstate <= LBWR;
            LBWR:    nextstate <= FETCH1;
            SBWR:    nextstate <= FETCH1;
            RTYPEEX: nextstate <= RTYPEWR;
            RTYPEWR: nextstate <= FETCH1;
            BEQEX:   nextstate <= FETCH1;
            JEX:     nextstate <= FETCH1;
            default: nextstate <= FETCH1; // should never happen
         endcase
      end

   always @(*)
      begin
            // set all outputs to zero, then conditionally assert just the appropriate ones
            irwrite <= 4'b0000;
            pcwrite <= 0; pcwritecond <= 0;
            regwrite <= 0; regdst <= 0;
            memread <= 0; memwrite <= 0;
            alusrca <= 0; alusrcb <= 2'b00; aluop <= 2'b00;
            pcsource <= 2'b00;
            iord <= 0; memtoreg <= 0;
            case(state)
               FETCH1: 
                  begin
                     memread <= 1; 
                     irwrite <= 4'b1000; 
                     alusrcb <= 2'b01; 
                     pcwrite <= 1;
                  end
               FETCH2: 
                  begin
                     memread <= 1;
                     irwrite <= 4'b0100;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               FETCH3:
                  begin
                     memread <= 1;
                     irwrite <= 4'b0010;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               FETCH4:
                  begin
                     memread <= 1;
                     irwrite <= 4'b0001;
                     alusrcb <= 2'b01;
                     pcwrite <= 1;
                  end
               DECODE: alusrcb <= 2'b11;
               MEMADR:
                  begin
                     alusrca <= 1;
                     alusrcb <= 2'b10;
                  end
               LBRD:
                  begin
                     memread <= 1;
                     iord    <= 1;
                  end
               LBWR:
                  begin
                     regwrite <= 1;
                     memtoreg <= 1;
                  end
               SBWR:
                  begin
                     memwrite <= 1;
                     iord     <= 1;
                  end
               RTYPEEX: 
                  begin
                     alusrca <= 1;
                     aluop   <= 2'b10;
                  end
               RTYPEWR:
                  begin
                     regdst   <= 1;
                     regwrite <= 1;
                  end
               BEQEX:
                  begin
                     alusrca     <= 1;
                     aluop       <= 2'b01;
                     pcwritecond <= 1;
                     pcsource    <= 2'b01;
                  end
               JEX:
                  begin
                     pcwrite  <= 1;
                     pcsource <= 2'b10;
                  end
         endcase
      end
   assign pcen = pcwrite | (pcwritecond & zero); // program counter enable
endmodule

module alucontrol(input      [1:0] aluop, 
                  input      [5:0] funct, 
                  output reg [2:0] alucont);

   always @(*)
      case(aluop)
         2'b00: alucont <= 3'b010;  // add for lb/sb/addi
         2'b01: alucont <= 3'b110;  // sub (for beq)
         default: case(funct)       // R-Type instructions
                     6'b100000: alucont <= 3'b010; // add (for add)
                     6'b100010: alucont <= 3'b110; // subtract (for sub)
                     6'b100100: alucont <= 3'b000; // logical and (for and)
                     6'b100101: alucont <= 3'b001; // logical or (for or)
                     6'b101010: alucont <= 3'b111; // set on less (for slt)
                     default:   alucont <= 3'b101; // should never happen
                  endcase
      endcase
endmodule



module datapathE #(parameter WIDTH = 8, REGBITS = 3)
                 (input              clk, reset, 
                  input  [WIDTH-1:0] memdata, 
                  input              alusrca, memtoreg, iord, pcen, regwrite, regdst,
                  input  [1:0]       pcsource, alusrcb, 
                  input  [3:0]       irwrite, 
                  input  [2:0]       alucont, 
                  output             zero, 
                  output [31:0]      instr, 
                  output [WIDTH-1:0] adr, writedata,
                  input VC, SI1,
                  output VI1, SC,
                  input VX,SY,
                  output VY,SX);
                  


   


   // the size of the parameters must be changed to match the WIDTH parameter
   parameter CONST_ZERO = 8'b0;
   parameter CONST_ONE =  8'b1;

   wire [REGBITS-1:0] ra1, ra2, wa;
   wire [WIDTH-1:0]   pc, nextpc, md, rd1, rd2, wd, a, src1, src2, aluresult,
                          aluout, constx4;

   // shift left constant field by 2
   assign constx4 = {instr[WIDTH-3:0],2'b00};

   // register file address fields
   assign ra1 = instr[REGBITS+20:21];
   assign ra2 = instr[REGBITS+15:16];
   mux2       #(REGBITS) regmux(instr[REGBITS+15:16], instr[REGBITS+10:11], regdst, wa);

wire VRFWrite; //To write in a register file, both VRFWrite as well as RegWrite must be enabled.
   // independent of bit width, load instruction into four 8-bit registers over four cycles
//   flopen     #(8)      ir0(clk, irwrite[0], memdata[7:0], instr[7:0]);
EBREn_8 EBREnI4 (clk,reset,irwrite[0],memdata[7:0],VCX4,SI4,instr[7:0],VI4,SCX4);

// Insert 2 Bubbles before I4 - in the MemData path to I4
// wire [WIDTH-1:0] Bb9,Bb10;
// EBBubbleR_8 EBBubbleRBb9 (clk,reset,memdata[7:0],VX4,SBb9,Bb9,VBb9,SX4);
// EBBubbleR_8 EBBubbleRBb10 (clk,reset,Bb9,VBb9,SBb10,Bb10,VBb10,SBb9);
// EBEn_8 EBEnI4 (clk,reset,irwrite[0],Bb10[7:0],VC34X4,SI4,instr[7:0],VI4,SC34X4);

//   flopen     #(8)      ir1(clk, irwrite[1], memdata[7:0], instr[15:8]);
EBREn_8 EBREnI3 (clk,reset,irwrite[1],memdata[7:0],VCX3,SI3,instr[15:8],VI3,SCX3);

//   flopen     #(8)      ir2(clk, irwrite[2], memdata[7:0], instr[23:16]);
EBREn_8 EBREnI2 (clk,reset,irwrite[2],memdata[7:0],VCX2,SI2,instr[23:16],VI2,SCX2);

//   flopen     #(8)      ir3(clk, irwrite[3], memdata[7:0], instr[31:24]);
EBREn_8 EBREnI1 (clk,reset,irwrite[3],memdata[7:0],VCX1,SI1,instr[31:24],VI1,SCX1);

   // datapath
//   flopenr    #(WIDTH)  pcreg(clk, reset, pcen, nextpc, pc);
EBREn_8 EBREnP(clk,reset,pcen,nextpc,VABCI4LP,SP, pc, VP,SABCI4LP);




//   flop       #(WIDTH)  mdr(clk, memdata, md);
EB_8  EBM (clk,reset,memdata,VX2,SM, md,VM,SX2);

//   flop       #(WIDTH)  areg(clk, rd1, a);
EB_8  EBA (clk,reset,rd1,VCI2I3LM1,SA,a,VA,SCI2I3LM1);
// Insert 3 bubbles after Register A:
//wire [WIDTH-1:0] Bb3,Bb4,Bb5;	
//EB_8  EBA (clk,reset,rd1,VRFWrite1,SBb3,Bb3,VBb3,SRFWrite1);
//EBBubbleR_8 EBBubbleRBb3 (clk,reset,Bb3,VBb3,SBb4,Bb4,VBb4,SBb3);
//EBBubbleR_8 EBBubbleRBb4 (clk,reset,Bb4,VBb4,SBb5,Bb5,VBb5,SBb4);	
//EBBubbleR_8 EBBubbleRBb5 (clk,reset,Bb5,VBb5,SA,a,VA,SBb5);	

//   flop       #(WIDTH)  wrd(clk, rd2, writedata);
EB_8  EBB (clk,reset,rd2,VCI2I3LM2,SB,writedata,VB,SCI2I3LM2);


// Insert 2 bubbles after register L
//wire [WIDTH-1:0] Bb1,Bb2;
//EB_8 EBL (clk,reset,aluresult,VABCI4P2,SBb1,Bb1,VBb1,SABCI4P2);
//EBBubbleR_8 EBBubbleRBb1 (clk,reset,Bb1,VBb1,SBb2,Bb2,VBb2,SBb1);
//EBBubbleR_8 EBBubbleRBb2 (clk,reset,Bb2,VBb2,SL,aluout,VL,SBb2);

//   flop       #(WIDTH)  res(clk, aluresult, aluout);
EB_8  EBL (clk,reset,aluresult,VABCI4P2,SL,aluout,VL,SABCI4P2);





// ElasticControlNetwork 



EFork4 FC(clk,reset,VC,SC1,SC2,SC3,SC4,VC1,VC2,VC3,VC4,SC);


Join2 JCX(VC3,VX1,SCX, VCX,SC3,SX1);
EFork4 FCX(clk,reset,VCX,SCX1,SCX2,SCX3,SCX4,VCX1,VCX2,VCX3,VCX4,SCX);
EFork2 FX(clk,reset,VX,SX1,SX2, VX1,VX2,SX);
Join5 JABCI4P(VA,VB1,VC1,VI4,VP1, SABCI4P, VABCI4P,SA,SB1,SC1,SI4,SP1);
EFork2 FABCI4P(clk,reset,VABCI4P,SABCI4P1,SABCI4P2, VABCI4P1,VABCI4P2,SABCI4P);



Join2 JABCI4LP(VABCI4P1,VL1,SABCI4LP, VABCI4LP,SABCI4P1,SL1);
EFork3 FL(clk,reset,VL,SL1,SL2,SL3,VL1,VL2,VL3,SL);


Join5 JCI2I3LM(VC2,VI2,VI3,VL2,VM,SCI2I3LM,  VCI2I3LM,SC2,SI2,SI3,SL2,SM);

assign VRFWrite=VCI2I3LM;


EFork2 FCI2I3LM(clk,reset,VCI2I3LM,SCI2I3LM1,SCI2I3LM2,VCI2I3LM1, VCI2I3LM2,SCI2I3LM);







Join4 JBCLP(VB2,VC4,VL3,VP2,SY, VY,SB2,SC4,SL3,SP2);


EFork2 FP(clk,reset,VP,SP1,SP2,VP1,VP2,SP);


EFork2 FB(clk,reset,VB,SB1,SB2,VB1,VB2,SB);




   mux2       #(WIDTH)  adrmux(pc, aluout, iord, adr);
   mux2       #(WIDTH)  src1mux(pc, a, alusrca, src1);
   mux4       #(WIDTH)  src2mux(writedata, CONST_ONE, instr[WIDTH-1:0], 
                                constx4, alusrcb, src2);
   mux4       #(WIDTH)  pcmux(aluresult, aluout, constx4, CONST_ZERO, pcsource, nextpc);
   mux2       #(WIDTH)  wdmux(aluout, md, memtoreg, wd);
   regfileE    #(WIDTH,REGBITS) rfE(clk, regwrite, ra1, ra2, wa, wd, rd1, rd2, VRFWrite);
   alu        #(WIDTH) alunit(src1, src2, alucont, aluresult);
   zerodetect #(WIDTH) zd(aluresult, zero);
endmodule

module alu #(parameter WIDTH = 8)
            (input      [WIDTH-1:0] a, b, 
             input      [2:0]       alucont, 
             output reg [WIDTH-1:0] result);

   wire     [WIDTH-1:0] b2, sum, slt;

   assign b2 = alucont[2] ? ~b:b; 
   assign sum = a + b2 + alucont[2];
   // slt should be 1 if most significant bit of sum is 1
   assign slt = sum[WIDTH-1];

   always@(*)
      case(alucont[1:0])
         2'b00: result <= a & b;
         2'b01: result <= a | b;
         2'b10: result <= sum;
         2'b11: result <= slt;
      endcase
endmodule



module regfileE #(parameter WIDTH = 8, REGBITS = 3)
                (input                clk, 
                 input                regwrite, 
                 input  [REGBITS-1:0] ra1, ra2, wa, 
                 input  [WIDTH-1:0]   wd, 
                 output [WIDTH-1:0]   rd1, rd2,
                 input VRFWrite);

   reg  [WIDTH-1:0] RAM [(1<<REGBITS)-1:0];

   // three ported register file
   // read two ports combinationally
   // write third port on rising edge of clock
   // register 0 hardwired to 0
   always @(posedge clk)
      if (regwrite & VRFWrite) RAM[wa] <= wd;	
      // To write in a register file, both regwrite and VRFWrite must be enabled. VRFWrite is enabled iff regwrite, wa and wd are valid!


   assign rd1 = ra1 ? RAM[ra1] : 0;
   assign rd2 = ra2 ? RAM[ra2] : 0;
endmodule










module zerodetect #(parameter WIDTH = 8)
                   (input [WIDTH-1:0] a, 
                    output            y);

   assign y = (a==0);
endmodule	

module flop #(parameter WIDTH = 8)
             (input                  clk, 
              input      [WIDTH-1:0] d, 
              output reg [WIDTH-1:0] q);

   always @(posedge clk)
      q <= d;
endmodule

module flopen #(parameter WIDTH = 8)
               (input                  clk, en,
                input      [WIDTH-1:0] d, 
                output reg [WIDTH-1:0] q);

   always @(posedge clk)
      if (en) q <= d;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input                  clk, reset, en,
                 input      [WIDTH-1:0] d, 
                 output reg [WIDTH-1:0] q);
 
   always @(posedge clk)
      if      (reset) q <= 0;
      else if (en)    q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

   assign y = s ? d1 : d0; 
endmodule

module mux4 #(parameter WIDTH = 8)
             (input      [WIDTH-1:0] d0, d1, d2, d3,
              input      [1:0]       s, 
              output reg [WIDTH-1:0] y);

   always @(*)
      case(s)
         2'b00: y <= d0;
         2'b01: y <= d1;
         2'b10: y <= d2;
         2'b11: y <= d3;
      endcase
endmodule


