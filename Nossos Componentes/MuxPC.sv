module MuxPC
(	input logic [31:0] PC,
	input logic [31:0] AluOut,
	input logic [1:0] IorD,
	output logic [31:0] Address
	);
	
	always_comb
	begin
		case(IorD)
		2'b00: Address <= PC;
		2'b01: Address <= AluOut;
		2'b10: Address <= 32'd254;
		2'b11: Address <= 32'd255;
		endcase
	end

endmodule: MuxPC