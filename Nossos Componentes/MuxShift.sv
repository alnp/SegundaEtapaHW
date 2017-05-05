module MuxShift
(
	input logic [4:0] Shamt, 
	input logic [31:0] RS,
	input logic ShamtOrRs,
	output logic [31:0] N
);

always_comb
	begin
		case (ShamtOrRs)
		1'b0: N <= Shamt;
		1'b1: N <= RS[4:0];
		endcase
	end
 
endmodule: MuxShift