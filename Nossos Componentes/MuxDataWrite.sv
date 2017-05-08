module MuxDataWrite
(
	input logic [31:0] ALUOutReg, 
	input logic [31:0] MDR,
	input logic [31:0] ShiftLeft16,
	input logic [31:0] RegDeslocOut,
	input logic [2:0] MemtoReg,
	input logic [31:0] PCJal,
	output logic [31:0] WriteDataMem
);

always_comb
	begin
		case (MemtoReg)
		3'b000: WriteDataMem <= ALUOutReg;
		3'b001: WriteDataMem <= MDR;
		3'b010: WriteDataMem <= ShiftLeft16;
		3'b011: WriteDataMem <= 32'b00000000000000000000000000000000;
		3'b100: WriteDataMem <= 32'b00000000000000000000000000000001;
		3'b101: WriteDataMem <= RegDeslocOut;
		3'b110: WriteDataMem <= PCJal;
		default: WriteDataMem <= ALUOutReg;
		endcase
	end
 
endmodule: MuxDataWrite