module MuxDataWrite
(
	input logic [31:0] ALUOutReg, 
	input logic [31:0] MDR,
	input logic [31:0] ShiftLeft16,
	input logic [1:0] MemtoReg,
	output logic [31:0] WriteDataMem
);

always_comb
	begin
		case (MemtoReg)
		2'b00: WriteDataMem <= ALUOutReg;
		2'b01: WriteDataMem <= MDR;
		2'b10: WriteDataMem <= ShiftLeft16;
		default: WriteDataMem <= ALUOutReg;
		endcase
	end
 
endmodule: MuxDataWrite