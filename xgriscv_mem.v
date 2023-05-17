//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The instruction memory and data memory.
//
// ====================================================================

`include "xgriscv_defines.v"

module imem(input  [`ADDR_SIZE-1:0]   a,
            output [`INSTR_SIZE-1:0]  rd);

  reg  [`INSTR_SIZE-1:0] RAM[`IMEM_SIZE-1:0];

  assign rd = RAM[a[15:2]]; // instruction size aligned
endmodule


module dmem(input           	         clk, we,
            input  [`XLEN-1:0]        a, wd,
            
            
            input [3:0]               swhb,
            
            wire [`XLEN-1:0]        rd);

  reg  [31:0] RAM[1023:0];
  //reg [`XLEN-1:0]  rd;

  always @(posedge clk)
  begin
      if (we) begin
        RAM[a[11:2]] <= wd;
          // if(swhb==3'b00)
          // begin        
          //   RAM[a[8:2]] <= wd;
          //   //$display("RAM[0x%8X] = 0x%8X,", a << 2, wd); 
          // end
          // else if(swhb==3'b01)  //byte
          // begin
          //   case(a[1:0])
          //      2'b00:RAM[a[8:2]][7:0] <= wd[7:0];
          //      2'b01:RAM[a[8:2]][15:8] <= wd[7:0];
          //      2'b10:RAM[a[8:2]][23:16] <= wd[7:0];
          //      2'b11:RAM[a[8:2]][31:24] <= wd[7:0];
          //   endcase
          //   //$display("RAM[0x%8X] = 0x%8X,", a << 2, wd); 
          // end
          // else if(swhb==3'b10)  //half word
          // begin
          //   case(a[1:0])
          //      2'b00:RAM[a[8:2]][15:0] <= wd[15:0];
          //      2'b01:RAM[a[8:2]][23:8] <= wd[15:0];
          //      2'b10:RAM[a[8:2]][31:16] <= wd[15:0];
          //      2'b11:begin
          //         RAM[a[8:2]][31:24] <= wd[7:0];
          //         RAM[a[8:2]+1][7:0] <= wd[15:8];
          //      end
          //   endcase
            //$display("RAM[0x%8X] = 0x%8X,", a << 2, wd); 
          end
          

      end
    
    assign rd = RAM[a[11:2]]; 


        // DO NOT CHANGE THIS display LINE!!!
        // 不要修改下面这行display语句！！！
        // 对于所有的store指令，都输出位于写入目标地址四字节对齐处的32位数据，不需要修改下面的display语句
        /**********************************************************************/
        //$display("pc = %h: dataaddr = %h, memdata = %h", pc, {a[31:2],2'b00}, RAM[a[11:2]]);
        /**********************************************************************/
endmodule