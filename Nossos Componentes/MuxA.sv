module MuxA
(
	input logic [31:0] PC, 
	input logic [31:0] A,
	input logic ALUSrcA,
	output logic [31:0] AOut
);

	always_comb
	begin
		case (ALUSrcA)
		1'b0: AOut <= PC;
		1'b1: AOut <= A;
		endcase
	end

endmodule: MuxA