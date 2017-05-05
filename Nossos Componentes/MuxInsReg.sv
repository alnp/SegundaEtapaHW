module MuxInsReg
(
	input logic [31:0] Inst20_16, 
	input logic [31:0] Funct,
	input logic RegDst,
	output logic [31:0] WriteReg
);

always_comb
	begin
		case (RegDst)
		1'b0: WriteReg <= Inst20_16;
		1'b1: WriteReg <= Funct;
		endcase
	end
 
endmodule: MuxInsReg