module MuxSaidaALU
(
	input logic [31:0] ALU, 
	input logic [31:0] ALUOut,
	input logic [31:0] RegDesloc,
	input logic [1:0]  PCSource,
	output logic [31:0] inPC
);

always_comb
	begin
		case (PCSource)
		2'b00: inPC <= ALU;
		2'b01: inPC <= ALUOut;
		2'b10: inPC <= RegDesloc;
		default: inPC <= ALU;
		endcase
	end

endmodule: MuxSaidaALU

