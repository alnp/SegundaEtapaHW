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
	output logic [3:0] memToReg,
	output logic [2:0] shiftControl,
	output logic [1:0] IorD,
	output logic shamtOrRs,
	output logic epcWrite,
	output logic [1:0] sMemDataIn,
	output logic wStore,
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
	WriteRegAluImm, 	//25
	Addiu,	//26
	Addi,	//27
	Andi,	//28
	Lbu,	//29
	Lhu,	//30
	SB,		//31
	SH,	/*	//32
	Slti,	//33
	Sxori	//34*/
	ShiftCarrega,	//35
	ShiftExeSll,	//36
	ShiftExeSllv,	//37
	ShiftExeSra,	//38
	ShiftExeSrav,	//39
	ShiftExeSrl,		//40
	Slt,	//41
	SltWrite,	//42
	JalEscreveR31,	//43
	Jal,	//44
	Lbu_step2, //45
	Lbu_step3, //46
	Lbu_step4, //47
	Lbu_step5, //48
	Lhu_step2, //49
	Lhu_step3, //50
	Lhu_step4, //51
	Lhu_step5, //52
	SB_step2, //45
	SB_step3, //46
	SB_step4, //47
	SB_step5, //48
	SH_step2, //49
	SH_step3, //50
	SH_step4, //51
	SH_step5 //52
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
						endcase
					end
					6'h4: state <= Beq;			//beq
					6'h5: state <= Bne;			//bne
					6'h23: state <=	LW;			//lw
					6'h2b: state <=	SW;			//sw
					6'hf: state <= Lui;			//lui
					6'h2: state <=	J;			//jump
					
					6'h8: state <=	Addi;			//addi
					6'h9: state <=	Addiu;			//addiu
					6'hc: state <=	Andi;			//andi
					6'h24: state <=	Lbu;			//lbu
					6'h25: state <=	Lhu;			//lhu
					6'h28: state <=	SB;				//sb
					6'h29: state <=	SH;				//sh
					/*6'ha: state <=	Slti;			//slti
					6'he: state <=	Sxori;			//sxori*/
					6'h3: state <= JalEscreveR31;
					
				endcase
			end
			Add: state <= WriteRegAlu;
			And: state <= WriteRegAlu;
			Sub: state <= WriteRegAlu;
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
			WriteRegAluImm: state <= MemoryRead;
			Addi: 
				begin
					if (overflow == 1) //Ocorre um overflow
						state <= WriteRegAluImm; //EXCEPTION TROCAR AQUI CARAI
					else 			   //Volta para a busca
						state <= WriteRegAluImm;
				end
			Andi:
				begin
					if (overflow == 1) //Ocorre um overflow
						state <= WriteRegAluImm; //EXCEPTION
					else 			   //Volta para a busca
						state <= WriteRegAluImm;
				end
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
			Lbu: state <= Lbu_step2;
			Lbu_step2: state <= Lbu_step3;
			Lbu_step3: state <= Lbu_step4;
			Lbu_step4: state <= Lbu_step5;
			Lbu_step5: state <= MemoryRead;
			Lhu: state <= Lhu_step2;
			Lhu_step2: state <= Lhu_step3;
			Lhu_step3: state <= Lhu_step4;
			Lhu_step4: state <= Lhu_step5;
			Lhu_step5: state <= MemoryRead;
			SB: state <= SB_step2;
			SB_step2: state <= SB_step3;
			SB_step3: state <= SB_step4;
			SB_step4: state <= SB_step5;
			SB_step5: state <= MemoryRead;
			SH: state <= SH_step2;
			SH_step2: state <= SH_step3;
			SH_step3: state <= SH_step4;
			SH_step4: state <= SH_step5;
			SH_step5: state <= MemoryRead;
			
			endcase
		end
	end
	
	always_comb
	begin
		case(state)
			Reset:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0000;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;	
				mdrControl = 1'b0;
				memToReg = 4'b0000;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
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
				memToReg = 4'b0000;
				estado <= state;
			end
			Beq:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
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
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b1;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b1;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0010;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0010;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0010;
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
			ShiftCarrega:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b001;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0010;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b100;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b1;
				shiftControl = 3'b100;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b011;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b1;
				shiftControl = 3'b010;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b010;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0101;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
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
					memToReg = 4'b0011;
					regDst = 2'b01;
					regWrite = 1'b1;
				end
				1'b1:
				begin
					memToReg = 4'b0100;
					regDst = 2'b01;
					regWrite = 1'b1;
				end
				endcase
			end
			JalEscreveR31:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0110;
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
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memWriteOrRead = 1'b0;
				mdrControl = 1'b0;
				memToReg = 4'b0010;
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
			WriteRegAluImm:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				IorD = 2'b01;
			
				memWriteOrRead = 1'b0;
				pcControl = 1'b0;
				irWrite = 1'b1;
				aluControl = 3'b000;
			
				regAluControl = 1'b0;
				regDst = 2'b00;
				regWrite = 1'b1;
				memToReg = 4'b0000;
				estado <= state;
			end
			Addi:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end			
			Addiu:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			Andi:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			
			Lbu:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			Lbu_step2:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lbu_step3:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lbu_step4:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				mdrControl = 1'b1;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lbu_step5:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				regWrite = 1'b1;
				regDst = 2'b00;
				memToReg = 4'b0111;
				mdrControl = 1'b0;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			
			Lhu:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			Lhu_step2:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lhu_step3:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lhu_step4:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				mdrControl = 1'b1;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			Lhu_step5:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				regWrite = 1'b1;
				regDst = 2'b00;
				memToReg = 4'b1000;
				mdrControl = 1'b0;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SB:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			SB_step2:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SB_step3:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SB_step4:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				mdrControl = 1'b1;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SB_step5:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				wStore = 1'b0;
				sMemDataIn = 2'b01;
				regWrite = 1'b1;
				regDst = 2'b00;
				memToReg = 4'b0111;
				mdrControl = 1'b0;
				memWriteOrRead = 1'b1;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SH:
			begin
				wStore = 1'b0;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				mdrControl = 1'b0;
				memToReg = 4'b0001;
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
				aluSrcB = 2'b10;
				writeA = 1'b0;
				writeB = 1'b0;
				regAluControl = 1'b1;
				estado <= state;
			end	
			SH_step2:
			begin
				wStore = 1'b1;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SH_step3:
			begin
				wStore = 1'b1;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				mdrControl = 1'b0;
				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SH_step4:
			begin
				wStore = 1'b1;
				sMemDataIn = 2'b00;
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;
				memToReg = 4'b0001;
				regDst = 2'b00;
				regWrite = 1'b0;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				mdrControl = 1'b1;
				memWriteOrRead = 1'b0;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
			SH_step5:
			begin
				epcWrite = 1'b0;
				shamtOrRs = 1'b0;
				shiftControl = 3'b000;

				pcControl = 1'b0;
				pcCond = 1'b0;
				origPC = 3'b000;
				irWrite = 1'b0;
				aluControl = 3'b001;
				aluSrcA = 1'b1;
				aluSrcB = 2'b10;
				writeA = 1'b1;
				writeB = 1'b0;
				bneORbeq = 1'b0;
				
				wStore = 1'b1;
				sMemDataIn = 2'b01;
				regWrite = 1'b1;
				regDst = 2'b00;
				memToReg = 4'b0111;
				mdrControl = 1'b0;
				memWriteOrRead = 1'b1;
				regAluControl = 1'b0;
				IorD = 2'b01;
				estado <= state;
			end
				
/*	
			
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