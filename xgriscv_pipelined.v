//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The overall of the pipelined xg-riscv implementation.
//
// ====================================================================

`include "xgriscv_defines.v"
// module xgriscv_pipeline(
//   input                   clk, reset);
  
//   wire [31:0]    instr;
//   wire [31:0]    PC_out, pcM;
//   wire           mem_w,lunsigned,a,b,c;
//   wire [3:0]     amp;
//   wire [31:0]    addr, Data_out, Data_in;
//   wire [1:0]     lwhb;
//   wire  [3:0]    swhb;
   
  
//   imem U_imem(PC_out, instr);

//   dmem U_dmem(clk, mem_w, addr, Data_out,swhb,Data_in);
  
//   PCPU pcpu(clk, reset, PC_out, instr, mem_w, addr, Data_out, swhb, Data_in,a,b,c);
  
// endmodule

// xgriscv: a pipelined riscv processor
module PCPU(input         			        clk, reset,
               output [31:0] 			        PC_out,
               input  [`INSTR_SIZE-1:0] inst_in,
               output					              mem_w,
               //output [3:0]  			        amp,
               output [`ADDR_SIZE-1:0] 	Addr_out, 
               output [`XLEN-1:0] 		    Data_out,
               //output [`ADDR_SIZE-1:0] 	pcM,
               //output [`ADDR_SIZE-1:0] 	pcW,
               //output [1:0]              lwhbM,
               output [3:0]              swlength,
               //output                    lunsignedM,
               input  [`XLEN-1:0] 		    Data_in,
					output 							CPU_MIO,
					output							MIO_ready,
					input 							INT);
												
	
  wire [6:0]  opD;
 	wire [2:0]  funct3D;
	wire [6:0]  funct7D;
  wire [4:0]  rdD, rs1D;
  wire [11:0] immD;
  wire        zeroD, ltD,geD;
  wire [4:0]  immctrlD;
  wire        itypeD, jalD, jalrD, bunsignedD, pcsrcD;
  wire [3:0]  aluctrlD;
  wire [1:0]  alusrcaD;
  wire        alusrcbD;
  wire        memwriteD;
  wire [3:0]  swhbD;
  wire [1:0]  lwhbD;
  wire        memtoregD, regwriteD,lunsignedD;
  wire [3:0]  btypesigD;
  wire [1:0]  lwhbM;
  wire       lunsignedM;
  wire [`ADDR_SIZE-1:0]   pcM;
  wire [`ADDR_SIZE-1:0]   pcW;
  reg [31:0]        Data_in0;

  always@(*)
  begin
    case({lunsignedM,lwhbM})
    3'b000: Data_in0 <= Data_in;
    3'b001: Data_in0 <= {{24{Data_in[7]}},Data_in[7:0]};
    3'b010: Data_in0 <= {{16{Data_in[15]}},Data_in[15:0]};
    3'b101: Data_in0 <= {24'b0,Data_in[7:0]};
    3'b110: Data_in0 <= {16'b0,Data_in[15:0]};
    default: Data_in0 <= Data_in;
    endcase
  end




  controller  c(clk, reset, opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD,geD,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, lwhbD, swhbD, 
              memtoregD, regwriteD,btypesigD);


  datapath    dp(clk, reset,
              inst_in, PC_out,
              Data_in0, Addr_out, Data_out, mem_w, pcM,lwhbM,swlength, pcW,
              immctrlD, itypeD, jalD, jalrD, bunsignedD, pcsrcD, 
              aluctrlD, alusrcaD, alusrcbD, 
              memwriteD, lunsignedD, lwhbD, swhbD, 
              memtoregD, regwriteD, btypesigD,
              opD, funct3D, funct7D, rdD, rs1D, immD, zeroD, ltD,geD,lunsignedM);

endmodule
