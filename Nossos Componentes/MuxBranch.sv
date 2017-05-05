module MuxBranch
(
	input logic Zero, 
	input logic notZero,
	input logic BEQorBNE,
	output logic Result
);

	always_comb
	begin
		case (BEQorBNE)
		1'b0: Result <= notZero;
		1'b1: Result <= Zero;
		endcase
	end

endmodule: MuxBranch