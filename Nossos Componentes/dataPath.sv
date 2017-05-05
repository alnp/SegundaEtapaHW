module dataPath 
(	input logic clock, res,
	output logic [5:0] StateOut,
	output logic IRWrite,
	output logic [31:0] Address,
	output logic [31:0] MemData,
	output logic [31:0] WriteDataMem,
	output logic [4:0] WriteRegister,
	output logic [31:0] WriteDataReg,
	output logic [31:0] MDR,
	output logic [31:0] Alu,
	output logic [31:0] AluOut,
	output logic [31:0] PC,
	output logic wr,
	output logic RegWrite
	);
	
	logic [31:0] winPC;
	logic [31:0] wPc;
	logic [1:0] wPCSource;
	logic [31:0] wALU;
	logic [31:0] wALUOut;
	logic [31:0] wAddress;
	logic [2:0] wALUControl;
	logic wWriteOrRead;
	logic wPCControl;
	logic [31:0] wMemDataOut;
	logic [5:0] wState;
	logic wIRWrite;
	logic [5:0] wInstrucao31_26;
	logic [4:0] wInstrucao25_21;
	logic [4:0] wInstrucao20_16;
	logic [16:0] wInstrucao15_0;
	logic [4:0] wInstrucao15_11;
	logic wIorD;
	logic [5:0] wfunct;
	logic [4:0] wWriteReg;
	logic wRegALUControl;
	logic wRegA;
	logic wRegB;
	logic [31:0] wA;
	logic [31:0] wB;
	logic [31:0] wAOut;
	logic [31:0] wBOut;
	logic [31:0] wRegAOut;
	logic [31:0] wRegBOut;	
	logic wAluSrcA;
	logic [1:0] wAluSrcB;
	logic [2:0] wMemToReg;
	logic [2:0] wShiftControl;
	logic [31:0] wWriteData;
	logic wRegDst;
	logic wRegWrite;
	logic wPCCond;
	logic wBneORBeq;
	logic [31:0] wSignExt;
	logic [31:0] wShiftLeft16;
	logic [31:0] wShiftLeft2;
	logic [31:0] wMDROut;
	logic [25:0] wConcat;
	logic [27:0] wShiftLeft2_26to28;
	logic [31:0] wJumAddress;
	logic [31:0] wRegDeslocOut;
	logic wAndPCControl;
	logic wOrPCControl;
	logic wZero;
	logic wResult;
	logic wMenor;
	logic [4:0] wShamt;
	logic wShamtOrRs;
	logic [31:0] wN;
	
	
	assign wAndPCControl = wPCCond & wResult;
	assign wOrPCControl = wPCControl | wAndPCControl; 
	assign wfunct = wInstrucao15_0[5:0];
	assign wInstrucao15_11 = wInstrucao15_0[15:11];
	assign wShamt = wInstrucao15_0[10:6];
	
	unidadeControle unidadeControle
	(	.clk(clock),
		.reset(res),
		.opcode(wInstrucao31_26),
		.funct(wfunct),
		.menor(wMenor),
		.memWriteOrRead(wWriteOrRead),
		.mdrControl(wMDRControl),
		.pcControl(wPCControl),
		.pcCond(wPCCond), 
		.origPC(wPCSource),
		.bneORbeq(wBneORBeq),
		.irWrite(wIRWrite),
		.writeA(wRegA),
		.writeB(wRegB),
		.regWrite(wRegWrite),
		.aluSrcA(wAluSrcA),
		.aluSrcB(wAluSrcB),
		.aluControl(wALUControl),
		.regAluControl(wRegALUControl),
		.regDst(wRegDst),
		.memToReg(wMemToReg),
		.shiftControl(wShiftControl),
		.IorD(wIorD),
		.shamtOrRs(wShamtOrRs),		
		.estado(wState)
		); 
		
		
		
	Ula32 Ula
	(	.A(wAOut),
		.B(wBOut),
		.Seletor(wALUControl),
		.S(wALU),
		.z(wZero),
		.Menor(wMenor)
		);
		
	Banco_reg BancoReg
	(
			.Clk(clock),
			.Reset(res),
			.RegWrite(wRegWrite),
			.ReadReg1(wInstrucao25_21),
			.ReadReg2(wInstrucao20_16),
			.WriteReg(wWriteReg),
			.WriteData(wWriteData),
			.ReadData1(wA),
			.ReadData2(wB)
	);
	
	Registrador pcReg
	(	.Clk(clock),
		.Reset(res),
		.Load(wOrPCControl),
		.Entrada(winPC),
		.Saida(wPc)
		);
		
	Registrador Mem
	(	.Clk(clock),
		.Reset(res),
		.Load(wMDRControl),
		.Entrada(wMemDataOut),
		.Saida(wMDROut)
		);
		
	Registrador A
	(	.Clk(clock),
		.Reset(res),
		.Load(wRegA),
		.Entrada(wA),
		.Saida(wRegAOut)
		);
			
	Registrador B
	(	.Clk(clock),
		.Reset(res),
		.Load(wRegB),
		.Entrada(wB),
		.Saida(wRegBOut)
		);	
		
	Registrador ALUOut
	(	.Clk(clock),
		.Reset(res),
		.Load(wRegALUControl),
		.Entrada(wALU),
		.Saida(wALUOut)
		);
		
	MuxPC MuxPc
	(	.PC(wPc),
		.AluOut(wALUOut),
		.IorD(wIorD),
		.Address(wAddress)
	);
	
	MuxBranch MuxBranch
	(	.Zero(wZero),
		.notZero(~wZero),
		.BEQorBNE(wBneORBeq),
		.Result(wResult)
	);
	
	MuxDataWrite MuxDataWrite
	(
		.ALUOutReg(wALUOut), 
		.MDR(wMDROut),
		.ShiftLeft16(wShiftLeft16),
		.MemtoReg(wMemToReg),
		.RegDeslocOut(wRegDeslocOut),
		.WriteDataMem(wWriteData)
);
	
	MuxA MuxA
	(
		.PC(wPc),
		.A(wRegAOut),
		.ALUSrcA(wAluSrcA),
		.AOut(wAOut)
	);
	
	MuxB MuxB
	(	.B(wRegBOut), 
		.signalExt(wSignExt), //I-TYPE WIRE
		.desloc_esq(wShiftLeft2), //I-TYPE WIRE
		.ALUSrcB(wAluSrcB),
		.BOut(wBOut)
	);
	
	MuxSaidaALU MuxSaidaAlu
	(	.ALU(wALU), 
		.ALUOut(wALUOut),
		.RegDesloc(wJumAddress), // nome fio desloc jump
		.PCSource(wPCSource),
		.JR(wRegAOut),
		.inPC(winPC)
	);
	
	MuxRegWrite MuxRegWrite
	(	.register_t(wInstrucao20_16),
		.register_d(wInstrucao15_11),
		.RegDest(wRegDst),
		.WriteRegister(wWriteReg)
		);
		
	signExtend signExtend
	(	.in(wInstrucao15_0),
		.out(wSignExt)
	);
	
	shiftLeft2_32 shiftLeft2_32
	(	.in(wSignExt),
		.out(wShiftLeft2)
	);
	
	shiftLeft16 shiftLeft16
	(	.in(wSignExt),
		.out(wShiftLeft16)
	);
	
	concatInstr concatInstr
	(	.dezesseisBits(wInstrucao15_0),
		.rt(wInstrucao20_16),
		.rs(wInstrucao25_21),
		.concat_out(wConcat)
	);
	
	shiftLeft2_26to28 shiftLeft2_26to28
	(	.in(wConcat),
		.out(wShiftLeft2_26to28)
	);
	
	concatAddress concatAddress
	(	.J(wShiftLeft2_26to28),
		.PC(wPc),
		.concatAddress_out(wJumAddress)
	);
	
	Instr_Reg IR
	(	.Clk(clock),
		.Reset(res),
		.Load_ir(wIRWrite),
		.Entrada(wMemDataOut),
		.Instr31_26(wInstrucao31_26),
		.Instr25_21(wInstrucao25_21),
		.Instr20_16(wInstrucao20_16),
		.Instr15_0(wInstrucao15_0)
	);
	
	Memoria Memoria
	(	.Address(wAddress),
		.Clock(clock),
		.Wr(wWriteOrRead),
		.Datain(wRegBOut),
		.Dataout(wMemDataOut)
		);
	
	RegDesloc RegDesloc
	(	.Clk(clock),
		.Reset(res),
		.Shift(wShiftControl),
		.N(wN),
		.Entrada(wRegBOut),
		.Saida(wRegDeslocOut)
	);
	
	MuxShift MuxShift
	(	.Shamt(wShamt),
		.RS(wRegAOut),
		.ShamtOrRs(wShamtOrRs),
		.N(wN)
	);
	
	assign StateOut = wState;
	assign MemData = wMemDataOut;
	assign Address = wAddress;
	assign WriteDataMem = wRegBOut;
	assign WriteRegister = wWriteReg;
	assign WriteDataReg = wWriteData;
	assign MDR = wMDROut;
	assign Alu = wALU;
	assign AluOut = wALUOut;
	assign PC = wPc;
	assign wr = wWriteOrRead;
	assign RegWrite = wRegWrite;
	assign IRWrite = wIRWrite;
	
		
endmodule: dataPath