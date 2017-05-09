module MuxDataWrite
(
	input logic [31:0] ALUOutReg, 
	input logic [31:0] MDR,
	input logic [31:0] ShiftLeft16,
	input logic [31:0] RegDeslocOut,
	input logic [2:0] MemtoReg,
	input logic [31:0] PCJal,
	input logic [31:0] Byte,
	input logic [31:0] Half,
	output logic [31:0] WriteDataMem
);

always_comb
	begin
		case (MemtoReg)
		4'b0000: WriteDataMem <= ALUOutReg;
		4'b0001: WriteDataMem <= MDR;
		4'b0010: WriteDataMem <= ShiftLeft16;
		4'b0011: WriteDataMem <= 32'b00000000000000000000000000000000;
		4'b0100: WriteDataMem <= 32'b00000000000000000000000000000001;
		4'b0101: WriteDataMem <= RegDeslocOut;
		4'b0110: WriteDataMem <= PCJal;
		4'b0111: WriteDataMem <= Byte;
		4'b1000: WriteDataMem <= Half;
		default: WriteDataMem <= ALUOutReg;
		endcase
	end
 
endmodule: MuxDataWrite