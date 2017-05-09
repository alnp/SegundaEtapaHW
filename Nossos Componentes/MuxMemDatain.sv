module MuxMemDatain
(	input logic [31:0] WriteData,
	input logic [31:0] ByteHalfWriteData,
	input logic [1:0] sMemDataIn,
	output logic [31:0] MemWriteData
	);
	
	always_comb
	begin
		case(sMemDataIn)
		2'b00: MemWriteData <= WriteData;
		2'b01: MemWriteData <= ByteHalfWriteData;
		default: MemWriteData <= WriteData;
		endcase
	end

endmodule: MuxMemDatain