//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The controller module generates the controlling signals.
//
// ====================================================================

`include "xgriscv_defines.v"

module controller(
  input                     clk, reset,
  input [6:0]	              opcode,
  input [2:0]               funct3,
  input [6:0]               funct7,
  input [`RFIDX_WIDTH-1:0]  rd, rs1,
  input [11:0]              imm,
  input                     zero, lt,ge, // from cmp in the decode stage    控制信号也没加

  output [4:0]              immctrl,            // for the ID stage
  output                    itype, jal, jalr, bunsigned, pcsrc,
  output reg  [3:0]         aluctrl,            // for the EX stage 
  output [1:0]              alusrca,
  output                    alusrcb,
  output                    memwrite, lunsigned,  // for the MEM stage
  output [1:0]              lwhb, 
  output [3:0]              swhb,
  output                    memtoreg, regwrite,  // for the WB stage
  output [3:0]              btypesig
  );

  wire rv32_lui		= (opcode == `OP_LUI);
  wire rv32_auipc	= (opcode == `OP_AUIPC);
  wire rv32_jal		= (opcode == `OP_JAL);
  wire rv32_jalr	= (opcode == `OP_JALR);
  wire rv32_branch= (opcode == `OP_BRANCH);
  wire rv32_load	= (opcode == `OP_LOAD); 
  wire rv32_store	= (opcode == `OP_STORE);
  wire rv32_addri	= (opcode == `OP_ADDI);
  wire rv32_addrr = (opcode == `OP_ADD);

  wire rv32_beq		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BEQ));
  wire rv32_bne		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BNE));
  wire rv32_blt		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BLT));
  wire rv32_bge		= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BGE));
  wire rv32_bltu	= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BLTU));
  wire rv32_bgeu	= ((opcode == `OP_BRANCH) & (funct3 == `FUNCT3_BGEU));

  wire rv32_lb		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LB));
  wire rv32_lh		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LH));
  wire rv32_lw		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LW));
  wire rv32_lbu		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LBU));
  wire rv32_lhu		= ((opcode == `OP_LOAD) & (funct3 == `FUNCT3_LHU));

  wire rv32_sb		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SB));
  wire rv32_sh		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SH));
  wire rv32_sw		= ((opcode == `OP_STORE) & (funct3 == `FUNCT3_SW));

  wire rv32_addi	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_ADDI));
  wire rv32_slti	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_SLTI));
  wire rv32_sltiu	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_SLTIU));
  wire rv32_xori	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_XORI));
  wire rv32_ori	  = ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_ORI));
  wire rv32_andi	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_ANDI));
  wire rv32_slli	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_SL) & (funct7 == `FUNCT7_SLLI));
  wire rv32_srli	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRLI));
  wire rv32_srai	= ((opcode == `OP_ADDI) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRAI));

  wire rv32_add		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_ADD) & (funct7 == `FUNCT7_ADD));
  wire rv32_sub		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_ADD) & (funct7 == `FUNCT7_SUB));
  wire rv32_sll		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_SLL));
  wire rv32_slt		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_SLT));
  wire rv32_sltu	= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_SLTU));
  wire rv32_xor		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_XOR));
  wire rv32_srl		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRL));
  wire rv32_sra		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_SR) & (funct7 == `FUNCT7_SRA));
  wire rv32_or		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_OR));
  wire rv32_and		= ((opcode == `OP_ADD) & (funct3 == `FUNCT3_AND));

  wire rv32_rs1_x0= (rs1 == 5'b00000);
  wire rv32_rd_x0 = (rd  == 5'b00000);
  wire rv32_nop		= rv32_addi & rv32_rs1_x0 & rv32_rd_x0 & (imm == 12'b0); //addi x0, x0, 0 is nop

  assign itype = rv32_jalr|rv32_addi| rv32_slti |rv32_sltiu | rv32_xori | rv32_ori | rv32_andi | rv32_slli | rv32_srli | rv32_srai |rv32_lb |rv32_lbu |rv32_lw |rv32_lh |rv32_lhu;

  wire rtype = rv32_add |rv32_sub |rv32_sll |rv32_slt |rv32_sltu |rv32_xor|rv32_srl |rv32_sra |rv32_or |rv32_and;

  wire stype = rv32_sb | rv32_sh |rv32_sw;

  wire btype = rv32_beq | rv32_bge | rv32_bgeu | rv32_blt | rv32_bltu | rv32_bne ;

  wire utype = rv32_lui | rv32_auipc;

  wire jtype = rv32_jal;

  wire siimmtype =rv32_slli | rv32_srli | rv32_srai;

  assign immctrl = {itype|siimmtype, stype|siimmtype, btype, utype, jtype};

  assign jal = rv32_jal;
  
  assign jalr = rv32_jalr;

  assign bunsigned = rv32_bltu |rv32_bgeu;

  assign pcsrc =(rv32_beq&zero)|(rv32_bne&(!zero))|((rv32_bge|rv32_bgeu)&ge)|((rv32_blt|rv32_bltu)&lt)|jal|jalr;

  assign alusrca = rv32_lui ? 2'b01 : (rv32_auipc ? 2'b10 : 2'b00);

  assign alusrcb = rv32_lui || rv32_auipc || itype || stype ;

  assign memwrite =stype;

  assign swhb[0] = rv32_sb|rv32_sh|rv32_sw;
  assign swhb[1] =  rv32_sh|rv32_sw;
  assign swhb[2] =  rv32_sw;
  assign swhb[3] =  rv32_sw;

  assign lwhb[0] = rv32_lb | rv32_lbu;
  assign lwhb[1] = rv32_lh | rv32_lhu;

  assign lunsigned =  rv32_lbu |rv32_lhu;

  assign memtoreg =  rv32_lb |rv32_lbu |rv32_lw |rv32_lh |rv32_lhu;

  assign regwrite = rv32_lui | rv32_auipc | itype | jal |jalr |rtype;

  assign btypesig[0]=rv32_beq;
  assign btypesig[1]=rv32_bne;
  assign btypesig[2]=rv32_blt|rv32_bltu;
  assign btypesig[3]=rv32_bge|rv32_bgeu;


  always @(*)
    case(opcode) //b，r型指令一条也没有，需要大改
      `OP_LUI:    aluctrl <= `ALU_CTRL_ADD;
      `OP_AUIPC:  aluctrl <= `ALU_CTRL_ADD;
      `OP_ADDI:	  case(funct3)
                    `FUNCT3_ADDI:	aluctrl <= `ALU_CTRL_ADD;
                    `FUNCT3_SLTI: aluctrl <= `ALU_CTRL_SLT;
                    `FUNCT3_SLTIU: aluctrl <= `ALU_CTRL_SLTU;
                    `FUNCT3_XORI: aluctrl <= `ALU_CTRL_XOR;
                    `FUNCT3_ORI: aluctrl <= `ALU_CTRL_OR;
                    `FUNCT3_ANDI: aluctrl <= `ALU_CTRL_AND;
                    `FUNCT3_SL: aluctrl <= `ALU_CTRL_SLL;
                    `FUNCT3_SR: if(funct7==`FUNCT7_SRLI)
                    begin
                      aluctrl <= `ALU_CTRL_SRL;
                    end
                    else if(funct7==`FUNCT7_SRAI)
                    begin
                      aluctrl <= `ALU_CTRL_SRA;
                    end
                    else
                      aluctrl <= `ALU_CTRL_ZERO;
                    default:		aluctrl <= `ALU_CTRL_ZERO;	
                  endcase
      `OP_ADD: if(funct7==`FUNCT7_ADD)
        begin
          case(funct3)
          `FUNCT3_ADD: aluctrl<=`ALU_CTRL_ADD;
          `FUNCT3_SLL: aluctrl<=`ALU_CTRL_SLL;
          `FUNCT3_SLT: aluctrl<=`ALU_CTRL_SLT;
          `FUNCT3_SLTU: aluctrl<=`ALU_CTRL_SLTU;
          `FUNCT3_XOR: aluctrl<=`ALU_CTRL_XOR;
          `FUNCT3_SR: aluctrl<=`ALU_CTRL_SRL;
          `FUNCT3_OR: aluctrl<=`ALU_CTRL_OR;
          `FUNCT3_AND: aluctrl<=`ALU_CTRL_AND;
          default: aluctrl<=`ALU_CTRL_ZERO;
          endcase
        end
        else if(funct7==`FUNCT7_SUB)
        begin
          case(funct3)
          `FUNCT3_ADD: aluctrl<=`ALU_CTRL_SUB;
          `FUNCT3_SR: aluctrl<=`ALU_CTRL_SRA;
          default: aluctrl<=`ALU_CTRL_ZERO;
          endcase
        end
        else  
          aluctrl <= `ALU_CTRL_ZERO; 
      `OP_STORE: aluctrl <= `ALU_CTRL_ADD;
      `OP_LOAD: aluctrl <= `ALU_CTRL_ADD;
      `OP_BRANCH: if(bunsigned==0)
        begin
          case(funct3)
              `FUNCT3_BGE: aluctrl <= `ALU_CTRL_ADDU;
              `FUNCT3_BLT: aluctrl <= `ALU_CTRL_ADDU;
              `FUNCT3_BEQ: aluctrl <= `ALU_CTRL_ZERO;
              `FUNCT3_BNE: aluctrl <= `ALU_CTRL_ZERO;
              default: aluctrl <= `ALU_CTRL_ZERO;
          endcase
        end
        else
        begin
            aluctrl <= `ALU_CTRL_SUBU;
        end
      `OP_JALR: aluctrl <= `ALU_CTRL_ADD;
      default:  aluctrl <= `ALU_CTRL_ZERO;
	 endcase

endmodule