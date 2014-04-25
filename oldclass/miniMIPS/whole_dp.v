module rtyepDatapath(rst, _shift_reg, _latch, selectLatch,
                  srcALatch, srcBLatch, aluOutLatch, regSelectLatch,
                  regWriteLatch, pcInSel, pcLatch, memwrite, memdata, addr, writedata);

   input rst, _shift_reg, selectLatch, srcALatch, srcBLach, aluOutLatch, regSelectLatch,
         regWriteLatch, pcInSel, pcLatch;
   input [7:0] memdata;
   input [3:0] _latch;
   output      memwrite;
   output [7:0] writedata, addr;
   

   // Provides the reset for flops.
   wire         rstb;

   wire [7:0]   pcMuxtoReg, pcRegtoExtMemMux, pcMuxtoReg, pcRegtoExtMemMux, 
                regSrcAtoAlu, regSrcBtoAlu, regWriteAddr, immx4;
   wire [2:0] aluSourceRegOut, aluCombToReg;

   wire [31:0]  instruction;
   

   // Dummy wire
   wire [7:0]   pcregBar, combRegBar;
   wire [31:0] fetchdpathBar;
   wire        zeroout;
   

              
   inv rstInv(.a(rst), .y(rstb));
   
   mux2 pcInputMux (.in0(aluout), .in1(immx4), .sel(pcInSel), .out(pcMuxtoReg));
   
   
   varreg #8 pcreg(.D(pcMuxtoReg), .CLRB(rstb), .CLK(pcLatch), .Q(pcRegtoExtMemMux), .QB(pcregBar));

   fetch_datapath fetchdpath(.DI(memdata), ._latch(_latch), .DO(instruction), .DO_B(fetchdpathBar), .CLR_B(rstb));

    mux2 regWriteMux(.in0(instruction[20:16]), .in1(instruction[15:11]), .sel(regSelectLatch), .out(regWriteAddr));
   
   regfile mipsRegister (.clk(regWriteLatch), .ra1(instruction[25:21]), .ra2(instruction[20:16]),  
                         .wd(regWriteAddr), .rd1(regSrcAtoAlu), .rd2(regSrcBtoAlu));


   
   
   aluComb calcAluSource(.opCode(instruction[31:26]), .funct(instruction[7:0]), .aluop(aluCombToReg));

   varreg #2 aluSourceReg(.D(aluCombToReg), .CLRB(rstb), .CLK(regSelectLatch), .Q(aluSourceRegOut), .QB(combRegBar));

   alu_datapath aludpath(.rst(rst), .pc(pcRegtoExtMemMux), .srcA(regSrcAtoAlu), .srcB(regSrcBtoalu), .instr(instruction[7:0]), 
                         .immx4(immx4), .mux2_cntrl(0), .mux4_cntrl(0),
                         .alu_cntrl(aluSourceRegOut), .srcA_cntrl(srcALatch), 
                         .srcB_cntrl(srcBLatch), .aluout_cntrl(aluOutLatch), .alu_out(aluout), .zero_out(zeroout));

   // Mux for controlling external memory. For R-type, this is always the value from the PC.
   mux2 externMemMux (.in0(pcRegtoExtMemMux), .in1(immx4), .sel(0), .out(addr));
   

   

endmodule // rtyepDatapath

// Module taken from the end of the text.
module regfile #(parameter WIDTH = 8, REGBITS = 3)
   (input clk,
 //input regwrite,
 input [REGBITS-1:0] ra1, ra2, wa,
 input [WIDTH-1:0] wd,
 output [WIDTH-1:0] rd1, rd2);

logic [WIDTH-1:0]     RAM [2**REGBITS-1:0];
// three ported register file
// read two ports combinationally
// write third port on rising edge of clock
// register 0 hardwired to 0
   always @(posedge clk)
     RAM[wa] <= wd;
 //    if (regwrite) RAM[wa] <= wd;
   assign rd1 = ra1 ? RAM[ra1] : 0;
   assign rd2 = ra2 ? RAM[ra2] : 0;
endmodule // regfile
          
// Variable size register
module varreg (D, CLRB, CLK, Q, QB);
   parameter width = 8;
   input CLRB, CLK;
   input [width-1:0] D;
   output [width-1:0] Q, QB;

   genvar             i;

   generate
      for(i=0; i<width; i=i+1)
        begin registerbit
          DFlipFlop stage(.D(D[i]), .CLRB(CLRB), .CLK(CLK), .Q(Q[i]), .QB(QB[i]));
        end
   endgenerate
   

endmodule // varreg


module counter(rst, clk, count);
   input rst, clk;
   output [1:0] count;

   always @(posedge clk)
     if(rst)
       count <= 2'b11;
     else
       count <= count + 1;
endmodule // counter
