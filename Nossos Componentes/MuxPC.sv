module MuxPC
(	input logic [31:0] PC,
	input logic [31:0] AluOut,
	input logic IorD,
	output logic [31:0] Address
	);
	
	always_comb
	begin
		case(IorD)
		1'b0: Address <= PC;
		1'b1: Address <= AluOut;
		endcase
	end

endmodule: MuxPC