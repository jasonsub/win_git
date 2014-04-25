module R_type(lr, la, rr, ra, rst, _shift_reg, _latch, selectLatch,
                  srcALatch, srcBLatch, aluOutLatch, regSelectLatch,
                  regWriteLatch, pcInSel, pcLatch);

   input lr, rr, rst;
   output la, ra, _shift_reg, selectLatch,
          srcALatch, srcBLatch, aluOutLatch, regSelectLatch,
          regWriteLatch, pcInSel, pcLatch;
   output [3:0] _latch;
   
   
   // wires from fetch to alu
   wire   rFetchToAlu, aFetchToAlu;


   // wires from alu to writeback
   wire   rAluToWriteback, aAluToWriteback;

   // wires from writeback to pcInc
   wire   rWritebackToPcInc, aWritebackToPcInc;

   asyn_fetch fetchStage (.lr(lr), .la(la), .rr(rFetchToAlu), .ra(aFetchToAlu),
               ._shift_reg(_shift_reg), ._latch(_latch), ._rst(rst));

   alu aluStage (.lr(rFetchToAlu), .la(aFetchToAlu),
                  .rr(rAluToWriteback), .ra(aAluToWriteback),
                  .rst(rst), .selectLatch(selectLatch),
                  .srcALatch(srcALatch), .srcBLatch(srcBLatch),
                 .aluOutLatch(aluOutLatch));

   writeback writebackStage (.lr(rAluToWriteback),
                             .la(aAluToWriteback),
                             .rr(rWritebackToPcInc),
                             .ra(aWritebackToPcInc), .rst(rst),
                             .regSelectLatch(regSelectLatch),
                             .regWriteLatch(regWriteLatch));

   pcInc pcIncStage (.lr(rWritebackToPcInc), .la(aWritebackToPcInc), .rr(rr),
                     .ra(ra), .rst(rst), .pcInSel(pcInSel),
                     .pcLatch(pcLatch));
   

endmodule // R_type

