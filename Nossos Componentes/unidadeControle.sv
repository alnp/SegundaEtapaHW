
	module unidadeControle
(	input logic clk, reset,
	input logic [5:0] opcode, 
	input logic [5:0] funct, 
	input logic menor,
	input logic [4:0] shamt,
	input logic overflow,
	output logic memWriteOrRead,
	output logic mdrControl,
	output logic pcControl,
	output logic pcCond,
	output logic [2:0] origPC,
	output logic bneORbeq,
	output logic irWrite,
	output logic writeA,
	output logic writeB,
	output logic regWrite,
	output logic aluSrcA,
	output logic [1:0] aluSrcB,
	output logic [2:0] aluControl,
	output logic regAluControl,
	output logic [1:0] regDst,
	output logic [2:0] memToReg,
	output logic [2:0] shiftControl,
	output logic [1:0] IorD,
	output logic shamtOrRs,
	output logic epcWrite,
	output logic [5:0] estado);

	enum logic [5:0] {
	Reset, //0
	MemoryRead, //1
	WaitMemoryRead, //2
	IRWrite, //3
	Decode, //4
	Add, //5
	And, //6
	Sub, //7
	Xor, //8
	Break, //9
	Nop, //10
	WriteRegAlu, //11
	Beq,	//12
	Bne,	//13
	LW,		//14
	LW_step2,	//15
	LW_step3_wait,	//16
	LW_step4,	//17
	LW_step5,	//18
	SW,		//19
	SW_step2,	//20
	SW_step3_wait,	//21
	Lui,	//22
	J,		//23
	JR,		//24
	//Modificacao - Alessandra
	WriteRegAluImm, 	//25
	Addu, /*	//26
	Addi,	//27
	Addiu	//28
	Andi,	//29
	Lbu,	//30
	Lhu,	//31
	Sb,		//32
	Sh,		//33
	Slti,	//34
	Sxori	//35*/
	ShiftCarrega,	//36
	ShiftExeSll,	//37
	ShiftExeSllv,	//38
	ShiftExeSra,	//39
	ShiftExeSrav,	//40
	ShiftExeSrl,	//41
	Slt,	//42
	SltWrite,	//43
	JalEscreveR31,	//44
	Jal,	//45
	Rte		//46
	MemReadEscreveEpcOp, //47
	WaitMemReadOp,	//48
	Wait2MemReadOp, //49
	EscrevePcOp,	//50
	MemReadEscreveEpcOv,	//51
	WaitMemReadOv,	//52
	Wait2MemReadOv,	//53
	EscrevePcOv		//54
	} state;
	
	initial state <= Reset;
	
	always_ff@(posedge clk or posedge reset)
	begin
		if(reset) state <= Reset;
		else
		begin
			case(state)
			Reset: state <= MemoryRead;
			MemoryRead: state <= WaitMemoryRead;
			WaitMemoryRead: state <= IRWrite;
			IRWrite: state <= Decode;
			Decode:
			begin
				case(opcode)
					6'h0:
					begin
						case(funct)
						6'h20: state <=	Add;		//add
						6'h24: state <= And;		//and
						6'h22: state <= Sub;		//sub
						6'h26: state <=	Xor;		//xor
						6'hd: state <= Break;		//break
						6'h0:
						begin
							case(shamt)
							5'h0: state <= Nop;
							default: state <= ShiftCarrega;
							endcase
						end
						6'h8: state <= JR;
						6'h4: state <= ShiftCarrega;
						6'h3: state <= ShiftCarrega;
						6'h7: state <= ShiftCarrega;
						6'h2: state <= ShiftCarrega;
						6'h2a: state <= Slt;
						6'h21: state <= Addu;
						6'h23: state <= Subu;
						endcase
					end
					6'h4: state <= Beq;			//beq
					6'h5: state <= Bne;			//bne
					6'h23: state <=	LW;			//lw
					6'h2b: state <=	SW;			//sw
					6'hf: state <= Lui;			//lui
					6'h2: state <=	J;			//jump
					
					//6'h8: state <= Addi;		//addi
					6'h9: state <=	;			//addiu
					/*6'hc: state <= Andi;		//andi
					6'h24: state <=	Lbu;		//lbu
					6'h25: state <=	Lhu;		//lhu
					6'h28: state <=	Sb;			//sb
					6'h29: state <=	Sh;			//sh
					6'ha: state <=	Slti;		//slti
					6'he: state <=	Sxori;		//sxori*/
					6'h3: state <= JalEscreveR31;
					6'h10: state <= Rte;
					default: state <= MemReadEscreveEpcOp;

					
				endcase
			end
			Add:
			begin
				if(overflow) state <= excessao;
				else state <= WriteRegAlu;
			end
			And: state <= WriteRegAlu;
			Sub: 
			begin
				if(overflow) state <= excecao;
				else state <= WriteRegAlu;
			end	
			Xor: state <= WriteRegAlu;
			Break: state <= Break;
			Nop: state <= MemoryRead;
			WriteRegAlu: state <= MemoryRead;
			Beq: state <= MemoryRead;
			Bne: state <= MemoryRead;
			LW: state <= LW_step2;
			LW_step2: state <= LW_step3_wait;
			LW_step3_wait: state <= LW_step4;
			LW_step4: state <= LW_step5;
			LW_step5: state <= MemoryRead;
			SW: state <= SW_step2;
			SW_step2: state <= SW_step3_wait;
			SW_step3_wait: state <= MemoryRead;
			Lui: state <= MemoryRead;
			J: state <= MemoryRead;
			JR: state <= MemoryRead;
			Addiu: state <= WriteRegAluImm;
			ShiftCarrega:
			begin
				case(funct)
					6'h0: state <= ShiftExeSll;
					6'h4: state <= ShiftExeSllv;
					6'h3: state <= ShiftExeSra;
					6'h7: state <= ShiftExeSrav;
					6'h2: state <= ShiftExeSrl;
				endcase
			end
			ShiftExeSllv: state <= MemoryRead;
			ShiftExeSra: state <= MemoryRead;
			ShiftExeSrav: state <= MemoryRead;
			ShiftExeSrl: state <= MemoryRead;
			Slt: state <= SltWrite;
			SltWrite: state <= MemoryRead;
			JalEscreveR31: state <= Jal;
			Jal: state <= MemoryRead;
			Addu: state <= WriteRegAlu;
			Subu: state <= WriteRegAlu;
			MemReadEscreveEpcOp: state <= WaitMemReadOp;
			WaitMemReadOp: state <= Wait2MemReadOp;
			Wait2MemReadOp: state <= EscrevePcOp;
			EscrevePcOp: state <= MemoryRead;
			endcase
		end
	end
	
	always_comb
	begin
		case(state)
			Reset:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b1;
				aluControl = 3'b000;
				estado <= state;
			end
			MemoryRead:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b00;
				
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b1;
				aluControl = 3'b001;
				estado <= state;
			end
			WaitMemoryRead:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b00;
				
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b1;
				aluControl = 3'b001;
				estado <= state;
			end
			IRWrite:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b00;
			
				origPC = 3'b000;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				memWriteOrRead = 1'b0;
				pcControl = 1'b1;
				irWrite = 1'b1;
				aluControl = 3'b001;
				estado <= state;
			end
			Decode:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b11;
				regAluControl = 1'b1;
				writeA = 1'b1;
				writeB = 1'b1;
				estado <= state;
			end
			Add:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			And:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b011;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			Sub:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b010;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			Xor:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b110;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			Break: 
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b000;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b00;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b000;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b0;	
				estado <= state;
			end
			Nop:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;	
				mdrControl = 1'b0;
				memToReg = 3'b000;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b00;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b000;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b0;	
				estado <= state;
			end
			WriteRegAlu:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b1;
				aluControl = 3'b000;
			
				regDst = 2'b01;
				regWrite = 1'b1;
				memToReg = 3'b000;
				estado <= state;
			end
			Beq:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b1;
				origPC = 3'b001;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				bneORbeq = 1'b1;
				estado <= state;
			end
			Bne:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b1;
				origPC = 3'b001;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				estado <= state;
			end
			LW:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b1;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				estado <= state;
			end
			LW_step2:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
				
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			LW_step3_wait:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
			
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			LW_step4:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 3'b001;
				regDst = 2'b00;
				regWrite = 1'b0;
			
				memWriteOrRead = 1'b0;
				mdrControl = 1'b1;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
				/*memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;*/
			end
			LW_step5:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SW:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b1;
				writeA = 1'b1;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SW_step2:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b1;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SW_step3_wait:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b1;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lui:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			J:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				origPC = 3'b010;
				pcControl = 1'b1;
				estado <= state;
			end
			JR:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				origPC = 3'b011;
				pcControl = 1'b1;
				estado <= state;
			end
			WriteRegAluImm:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 2'b01;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			Addiu:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 2'b01;
				pcCond = 1'b0;
				origPC = 3'b000;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end		
			ShiftCarrega:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b001;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			ShiftExeSra:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b100;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			ShiftExeSrav:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b1;
				shiftControl = 3'b100;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			ShiftExeSrl:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b011;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			ShiftExeSllv:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b1;
				shiftControl = 3'b010;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			ShiftExeSll:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b010;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Slt:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b101;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b111;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SltWrite:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b111;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b1;
				writeB = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				estado <= state;
				case(menor)
				1'b0:
				begin
					memToReg = 3'b011;
					regDst = 2'b01;
					regWrite = 1'b1;
				end
				1'b1:
				begin
					memToReg = 3'b100;
					regDst = 2'b01;
					regWrite = 1'b1;
				end
				endcase
			end
			JalEscreveR31:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b110;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b000;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b10;
				regWrite = 1'b1;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			Jal:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b0;
				aluSrcB = 2'b00;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
				
				origPC = 3'b010;
				pcControl = 1'b1;
				estado <= state;
			end
			MemReadEscreveEpcOp:
			begin
				epcWrite = 1'b1;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b10;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			WaitMemReadOp:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b10;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			Wait2MemReadOp:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b1;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b10;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			EscrevePcOp:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b10;
				
				origPC = 3'b101;
				pcControl = 1'b1;
				estado <= state;
			end
			MemReadEscreveEpcOv:
			begin
				epcWrite = 1'b1;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b11;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			WaitMemReadOv:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b11;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			Wait2MemReadOv:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b1;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b11;
				
				origPC = 3'b010;
				pcControl = 1'b0;
				estado <= state;
			end
			EscrevePcOv:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 3'b010;
				pcCond = 1'b0;
				irWrite = 1'b0;
				aluControl = 3'b010;
				aluSrcA = 1'b0;
				aluSrcB = 2'b01;
				regAluControl = 1'b0;
				writeA = 1'b0;
				writeB = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b10;
				
				origPC = 3'b101;
				pcControl = 1'b1;
				estado <= state;
			end
			
			Addu:
			begin
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 2'b00;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 1'b1;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			
			Subu:
			begin
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 3'b001;
				pcCond = 1'b0;
				origPC = 2'b00;
				regDst = 2'b00;
				regWrite = 1'b0;
				bneORbeq = 1'b0;
				IorD = 1'b1;
				
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b0;
				
				aluControl = 3'b010;
				aluSrcA = 1'b1;
				aluSrcB = 2'b00;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end
			
			
			/*			
			Addi:
			begin
			end	
			
			Andi:
			begin
			end	
			
			Lbu:
			begin
			end	
			
			Lhu:
			begin
			end
			
			Sb 
			begin
			end	
			
			Sh:
			begin
			end		
			
			Slti:
			begin
			end	
			
			Sxori:
			begin
			end	
*/	
		endcase
	end
		
	
endmodule: unidadeControle