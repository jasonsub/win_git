//----------------------------------------------------------------------
// This is the datapath to go along with an R-type instruction.
//----------------------------------------------------------------------

module rtypeDatapath(rst, _shift_reg, _latch, selectLatch,
		  srcALatch, srcBLatch, aluOutLatch, regSelectLatch,
		  regWriteLatch, pcInSel, pcLatch, memwrite, memdata, addr, writedata, /*add 1 by XS*/PCInLatch);

   input rst, _shift_reg, selectLatch, srcALatch, srcBLatch, aluOutLatch, regSelectLatch,
	 regWriteLatch, pcInSel, pcLatch, /*add 1 by XS*/PCInLatch;
   input [7:0] memdata;
   input [3:0] _latch;
   output      memwrite;
   output [7:0] writedata, addr;
   

   // Provides the reset for flops.
   wire 	rstb;

   wire [7:0] 	pcMuxtoReg, pcRegtoExtMemMux, aluout, 
		regSrcAtoAlu, regSrcBtoAlu,  immx4, regDataMuxToRegFile;
   
   wire [2:0] 	regWriteAddr;
   
   wire [2:0] aluSourceRegOut, aluCombToReg;

   wire [31:0] 	instruction;
   

   // Dummy wire
   wire [7:0] 	pcregBar;
   wire [2:0] 	combRegBar;
   wire [31:0] fetchdpathBar;
   wire        zeroout;
   
   wire [1:0]  count;
	//added by XS
	wire mux2_ctrl, srcALatch_wPC, srcBLatch_wPC;
	wire [1:0] mux4_ctrl;
   
	      
   INV rstInv(.a(rst), .b(rstb));
   
   mux2 pcInputMux (.in0(aluout), .in1(immx4), .sel(pcInSel), .out(pcMuxtoReg));
   
   
   varreg #8 pcreg(.D(pcMuxtoReg), .CLRB(rstb), .CLK(pcLatch), .Q(pcRegtoExtMemMux), .QB(pcregBar));

   fetch_datapath fetchdpath(.DI(memdata), ._latch(_latch), .DO(instruction), .DO_B(fetchdpathBar), .CLR_B(rstb));

   // This is the mux controlling the inputs on the address line for the write register.
   // The inputs to the mux should be instruction[20:16] and instruction[15:11]
   // but we only use last three bits in each case to address the reg file
   // since it only has 3 entries.
   VARMUX #(3) regWriteAddrMux(.in0(instruction[18:16] ), .in1(instruction[13:11]), .sel(regSelectLatch), .out(regWriteAddr));

   // This is the mux controlling the date to be written to the alu.
   VARMUX #(8) regWriteDataMux(.in0(aluout), .in1(memdata), .sel(1'b0), .out(regDataMuxToRegFile));
   
   
   // The inputs to the register file are 3 bits since the size of the
   // register file is only 8 entries.
   regfile mipsRegister (.clk(regWriteLatch), .ra1(instruction[23:21]), .ra2(instruction[18:16]),  
			 .wa(regWriteAddr), .wd(regDataMuxToRegFile), .rd1(regSrcAtoAlu), .rd2(regSrcBtoAlu));


   
   // This is the circuit that determines the alu operation.
   aluComb calcAluSource(.opCode(instruction[31:26]), .funct(instruction[5:0]), .aluop(aluCombToReg));

   // This register stores the results of the alumComb circuit. Thus it stores the alu control lines.
   varreg #3 aluSourceReg(.D(aluCombToReg), .CLRB(rstb), .CLK(selectLatch), .Q(aluSourceRegOut), .QB(combRegBar));
   
/**********************************modified by XS****************************************/
//   alu_datapath aludpath(.rst(rst), .pc(pcRegtoExtMemMux), .srcA(regSrcAtoAlu), .srcB(regSrcBtoAlu), 
//			 .instr(instruction[7:0]), .immx4(immx4), .mux2_cntrl(1'b1), .mux4_cntrl(2'b00),
//			 .alu_cntrl(aluSourceRegOut), .srcA_cntrl(srcALatch), 
//			 .srcB_cntrl(srcBLatch), .aluout_cntrl(aluOutLatch), .alu_out(aluout), .zero_out(zeroout));

   alu_datapath aludpath(.rst(rst), .pc(pcRegtoExtMemMux), .srcA(regSrcAtoAlu), .srcB(regSrcBtoAlu), 
			 .instr(instruction[7:0]), .immx4(immx4), .mux2_cntrl(mux2_ctrl), .mux4_cntrl(mux4_ctrl),
			 .alu_cntrl(aluSourceRegOut), .srcA_cntrl(srcALatch_wPC), 
			 .srcB_cntrl(srcBLatch_wPC), .aluout_cntrl(aluOutLatch), .alu_out(aluout), .zero_out(zeroout));

/***********************************END******************************************/

   // Mux for controlling external memory. For R-type, this is always the value from the PC.
   mux2 externMemMux (.in0({pcRegtoExtMemMux[7:2], count}), .in1(immx4), .sel(1'b0), .out(addr));

   // This counter provides the last two digits of the external memory bits.
   counter lastAddrBits(.rst(rst), .clk(_shift_reg), .count(count));

/**********************************Edit by XS***************************************/
	mux2 srcA_mux_ctrl (.in0(regtoMux2), .in1(1'b0), .sel(pcInSel), .out(mux2_ctrl));
	mux2 srcB_mux_ctrl (.in0(regtoMUX4), .in1(2'b01), .sel(pcInSel), .out(mux4_ctrl));
	mux2 srcA_latch_ctrl (.in0(srcALatch), .in1(PCInLatch), .sel(pcInSel), .out(srcALatch_wPC));
	mux2 srcB_latch_ctrl (.in0(srcBLatch), .in1(PCInLatch), .sel(pcInSel), .out(srcBLatch_wPC));
/***********************************END**********************************************/
   

endmodule // rtyepDatapath

// Module taken from the end of the text.
module regfile #(parameter WIDTH = 8, REGBITS = 3)
   (input clk,
 //input regwrite,
 input [REGBITS-1:0] ra1, ra2, wa,
 input [WIDTH-1:0] wd,
 output [WIDTH-1:0] rd1, rd2);
   
   reg [WIDTH-1:0] RAM [2**REGBITS-1:0];
// three ported register file
// read two ports combinationally
// write third port on rising edge of clock
// register 0 hardwired to 0
   always @(posedge clk)
     RAM[wa] <= wd;
 //    if (regwrite) RAM[wa] <= wd;
//   assign rd1 = ra1 ? RAM[ra1] : 0;
//   assign rd2 = ra2 ? RAM[ra2] : 0;

   // Temporarily, for debug purpose set ra1 and ra2 to
   // specific values
   assign rd1 = 8'b00000001;
   assign rd2 = 8'b00000011;
   
endmodule // regfile
	  
// Variable size register
module varreg (D, CLRB, CLK, Q, QB);
   parameter width = 8;
   input CLRB, CLK;
   input [width-1:0] D;
   output [width-1:0] Q, QB;

   genvar 	      i;

   generate
      for(i=0; i<width; i=i+1)
	begin: registerbit
	  DFlipFlop stage (.D(D[i]), .CLRB(CLRB), .CLK(CLK), .Q(Q[i]), .QB(QB[i]));
	end
   endgenerate
   

endmodule // varreg


module counter(rst, clk, count);
   input rst, clk;
   output reg [1:0] count;

   always @(posedge clk)
     if(rst)
       count <= 2'b11;
     else
       count <= count + 1;
endmodule // counter
