//=====================================================================
//
// Designer   : Yili Gong
//
// Description:
// As part of the project of Computer Organization Experiments, Wuhan University
// In spring 2021
// The datapath of the pipeline.
// ====================================================================

`include "xgriscv_defines.v"

module datapath(
	input                    clk, reset,

	input [`INSTR_SIZE-1:0]  instrF, 	 // from instructon memory
	output[`ADDR_SIZE-1:0] 	 pcF, 		   // to instruction memory

	input [`XLEN-1:0]	       readdataM, // from data memory: read data
  output[`XLEN-1:0]        aluoutM, 	 // to data memory: address
 	output[`XLEN-1:0]	       writedataM,// to data memory: write data
  output			                memwriteM,	// to data memory: write enable
 	output [`ADDR_SIZE-1:0]  pcM,       // to data memory: pc of the write instruction
 	output [1:0]			lwhbM,
	output [3:0] 			swhbM,
 	output [`ADDR_SIZE-1:0]  pcW,       // to testbench
  
	
	// from controller
	input [4:0]		            immctrlD,
	input			                 itype, jal0D, jalr0D, bunsignedD, pcsrcD,
	input [3:0]		            aluctrlD,
	input [1:0]		            alusrcaD,
	input			                 alusrcbD,
	input			                 memwrite0D, lunsignedD,
	input [1:0]		          	 lwhbD, 
	input [3:0]					 swhbD,  
	input          		        memtoreg0D, regwrite0D,
	input [3:0]						btypesig0D,
	
  	// to controller
	output [6:0]		           opD,
	output [2:0]		           funct3D,
	output [6:0]		           funct7D,
	output [4:0] 		          rdD, rs1D,
	output [11:0]  		        immD,
	output 	       		        zeroD, ltD,geD,lunsignedM
	);

	// next PC logic (operates in fetch and decode)	
	wire pcsrcM;
	wire flush;
	wire [1:0] forwardinga,forwardingb;
	wire hasard;
	wire memwriteD,regwriteD;
	// assign forwardinga=0;
	// assign forwardingb=0;
	// assign hasard=0;
	wire [`ADDR_SIZE-1:0]	 pcplus4F, nextpcF, pcbranchD, pcadder2aD, pcadder2bD, pcbranch0D;
	mux2 #(`ADDR_SIZE)	    pcsrcmux(pcplus4F, pcbranchD, pcsrcM, nextpcF);
	
	// Fetch stage logic
	pcenr      	 pcreg(clk, reset, ~hasard, nextpcF, pcF);
	addr_adder  	pcadder1(pcF, `ADDR_SIZE'b100,5'b00000 ,pcplus4F);



	///////////////////////////////////////////////////////////////////////////////////
	// IF/ID pipeline registers
	// reg [`INSTR_SIZE+`ADDR_SIZE-1:0]  IFID_reg;
	// always@(clk)
	// begin
	// 	IFID_reg={pcF,instrF};
	// end
	// {pcF,instrF}=IFID_reg;
	wire regwriteW,memtoregD,jalD,jalrD;
	wire [`INSTR_SIZE-1:0]	instrD;
	wire [`ADDR_SIZE-1:0]	pcD, pcplus4D;
	wire flushD;
	assign flushD=flush;
	wire [3:0] btypesigD;

	flopenrc #(`INSTR_SIZE) 	pr1D(clk, reset,~hasard, flushD, instrF, instrD);     // instruction
	flopenrc #(`ADDR_SIZE)	  pr2D(clk, reset,~hasard, flushD, pcF, pcD);           // pc
	flopenrc #(`ADDR_SIZE)	  pr3D(clk, reset,~hasard, flushD, pcplus4F, pcplus4D); // pc+4



	// Decode stage logic
	wire [`RFIDX_WIDTH-1:0] rs2D;
	assign  opD 	= instrD[6:0];
	assign  rdD     = instrD[11:7];
	assign  funct3D = instrD[14:12];
	assign  rs1D    = instrD[19:15];
	assign  rs2D   	= instrD[24:20];
	assign  funct7D = instrD[31:25];
	assign  immD    = instrD[31:20];

	// immediate generate
	wire [11:0]  iimmD = instrD[31:20];
	wire [11:0]		simmD	= {instrD[31:25],instrD[11:7]};
	wire [11:0]  bimmD	= {instrD[31],instrD[7],instrD[30:25],instrD[11:8]};
	wire [19:0]		uimmD	= instrD[31:12];
	wire [19:0]  jimmD	= {instrD[31],instrD[19:12],instrD[20],instrD[30:21]};
	wire [4:0]  siimmD =instrD[24:20];
	wire [`XLEN-1:0]	immoutD, shftimmD;
	wire [`XLEN-1:0]	rdata1D, rdata2D, wdataW;
	wire [`RFIDX_WIDTH-1:0]	waddrW;

	imm 	im(iimmD, simmD,siimmD, bimmD, uimmD, jimmD, immctrlD, immoutD);

	// register file (operates in decode and writeback)
	regfile rf(clk, reset,rs1D, rs2D, rdata1D, rdata2D, regwriteW, waddrW, wdataW, pcW);

	
	mux2  #(9) ctrlmux1({memwrite0D,regwrite0D,memtoreg0D,btypesig0D,jal0D,jalr0D},9'b0,hasard,{memwriteD,regwriteD,memtoregD,btypesigD,jalD,jalrD});

	///////////////////////////////////////////////////////////////////////////////////
	// ID/EX pipeline registers

	// for control signals

	// reg IDEX_reg[];
	// always@(clk)
	// begin
	// 	IDEX_reg={alusrcaD,alusrcbD,regwriteD,regwriteD,aluctrlD,}
	// end

	wire       regwriteE, memwriteE,alusrcbE,lunsignedE,jalE,jalrE,memtoregE;
	wire [1:0] alusrcaE;
	wire [3:0] aluctrlE;
	wire 	     flushE;
	assign flushE=flush;
	wire [1:0]	lwhbE;
	wire [3:0]  swhbE;
	wire [4:0]	immctrlE;
	wire [3:0]	btypesigE;
	wire [4:0] rs1E,rs2E;
	floprc #(10) regE(clk, reset, flushE,
                  {regwriteD, memwriteD, alusrcaD, alusrcbD, aluctrlD,memtoregD}, 
                  {regwriteE, memwriteE, alusrcaE, alusrcbE, aluctrlE,memtoregE});
	floprc #(9) pr0E(clk,reset,flushE,{lwhbD,swhbD,lunsignedD,jalD,jalrD},{lwhbE,swhbE,lunsignedE,jalE,jalrE});
	floprc #(4) pr00E(clk,reset,flushE,btypesigD,btypesigE);
  
	// for data
	wire overflowE,zeroE,ltE,geE;
	wire [`XLEN-1:0]	srca1E, srcb1E, immoutE, srcaE, srcbE, aluoutE,pcbranchE,srca2E,srcb2E;
	wire [`RFIDX_WIDTH-1:0] rdE;
	wire [`ADDR_SIZE-1:0] 	pcE, pcplus4E;
	floprc #(`XLEN) 	pr1E(clk, reset, flushE, rdata1D, srca1E);        	// data from rs1
	floprc #(`XLEN) 	pr2E(clk, reset, flushE, rdata2D, srcb1E);         // data from rs2
	floprc #(`XLEN) 	pr3E(clk, reset, flushE, immoutD, immoutE);        // imm output
 	floprc #(`RFIDX_WIDTH)  pr6E(clk, reset, flushE, rdD, rdE);         // rd
 	floprc #(`ADDR_SIZE)	pr8E(clk, reset, flushE, pcD, pcE);            // pc
 	floprc #(`ADDR_SIZE)	pr9E(clk, reset, flushE, pcplus4D, pcplus4E);  // pc+4
	floprc #(5)				pr10E(clk,reset,flushE,immctrlD,immctrlE);
	floprc #(5)			pr11E(clk,reset,flushE,rs1D,rs1E);
	floprc #(5)			pr12E(clk,reset,flushE,rs2D,rs2E);

	// execute stage logic

	mux3 #(`XLEN)  srcafmux(srca1E,wdataW,aluoutM,forwardinga,srca2E);
	mux3 #(`XLEN)  srcbfmux(srcb1E,wdataW,aluoutM,forwardingb,srcb2E);


	mux3 #(`XLEN)  srcamux(srca2E, 0, pcE, alusrcaE, srcaE);     // alu src a mux
	mux2 #(`XLEN)  srcbmux(srcb2E, immoutE, alusrcbE, srcbE);			 // alu src b mux

	

	alu alu(srcaE, srcbE, 5'b0, aluctrlE, aluoutE, overflowE, zeroE, ltE, geE);  //这里也需要大改
	sl1 sller1(immoutE,shftimmD);
	addr_adder pcadder2(pcE,shftimmD,immctrlE,pcbranchE);

	//停顿单元
	Hasarddec hasdec(memtoregE,rdE,rs1D,rs2D,hasard);
	//Branchsys flushsys(btypesigE,jalE,jalrE,geE,ltE,zeroE,flush);
	//Branchsys branchsys(btypesigE,jalE,jalrE,geE,ltE,zeroE,pcsrcM);
	


	///////////////////////////////////////////////////////////////////////////////////
	// EX/MEM pipeline registers
	// for control signals
	wire 		regwriteM,overflowD,jalM,jalrM,memtoregM;
	wire 		flushM =flush;
	wire [`ADDR_SIZE-1:0] 	 pcplus4M;
	//wire [`XLEN-1:0]		tpcbranchD;
	wire [3:0]				btypesigM;
	floprc #(2) 	regM(clk, reset, flushM,
                  	{regwriteE, memwriteE},
                  	{regwriteM, memwriteM});
	floprc #(4) alusigoutM(clk,reset,flushM,{overflowE, zeroE, ltE, geE},{overflowD, zeroD, ltD, geD});
	floprc #(10) pr0M(clk,reset,flushM,{lwhbE,swhbE,lunsignedE,jalE,jalrE,memtoregE},{lwhbM,swhbM,lunsignedM,jalM,jalrM,memtoregM});
	floprc #(4) pr00M(clk,reset,flushM,btypesigE,btypesigM);

	// for data
 	wire [`RFIDX_WIDTH-1:0]	 rdM;
	floprc #(`XLEN) 	        pr1M(clk, reset, flushM, aluoutE, aluoutM);
	floprc #(`RFIDX_WIDTH) 	 pr2M(clk, reset, flushM, rdE, rdM);
	floprc #(`ADDR_SIZE)	    pr3M(clk, reset, flushM, pcE, pcM);            // pc
	floprc #(`XLEN) 		pr4M(clk,reset,flushM,pcbranchE,pcbranch0D);
	floprc #(`XLEN)			pr5M(clk,reset,flushM,srcb2E,writedataM);
	floprc #(`ADDR_SIZE)		pr6M(clk,reset,flushM,pcplus4E,pcplus4M);
	
	// mem stage logic
	Branchsys branchsys(btypesigM,jalM,jalrM,geD,ltD,zeroD,pcsrcM);
	assign flush=pcsrcM;
	mux2 #(`XLEN) pcmux(pcbranch0D,aluoutM,jalrM,pcbranchD);
	//assign readdataM = lunsignedM? readdataM : $unsigned(readdataM);

  ///////////////////////////////////////////////////////////////////////////////////
  // MEM/WB pipeline registers
  // for control signals
  wire flushW = 0;
  wire jalW,jalrW,memtoregW;
  wire [`ADDR_SIZE-1:0]  pcplus4W;
	floprc #(2) regW(clk, reset, flushW, {regwriteM,memtoregM}, {regwriteW,memtoregW});
	floprc #(2) pcwb(clk,reset,flushW,{jalM,jalrM},{jalW,jalrW});

  // for data
  wire[`XLEN-1:0]		       aluoutW,readdataW;
  wire[`RFIDX_WIDTH-1:0]	 rdW;

  floprc #(`XLEN) 	       pr1W(clk, reset, flushW, aluoutM, aluoutW);
  floprc #(`RFIDX_WIDTH)  pr2W(clk, reset, flushW, rdM, rdW);
  floprc #(`ADDR_SIZE)	   pr3W(clk, reset, flushW, pcM, pcW);            // pc
  floprc #(`ADDR_SIZE)		pr6W(clk,reset,flushW,pcplus4M,pcplus4W);
  floprc #(`XLEN)			pr7W(clk,reset,flushW,readdataM,readdataW);
	
	// write-back stage logic
	//assign wdataW = aluoutW;
	mux3 #(`XLEN) MemtoReg(readdataW,aluoutW,pcplus4W,{jalW|jalrW,~memtoregW},wdataW);

	assign waddrW = rdW;

	//控制检测单元
	Forwarding forwarding(regwriteM,regwriteW,rs1E,rs2E,rdM,rdW,forwardinga,forwardingb);

endmodule