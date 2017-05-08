module MuxSaidaALU
(
	input logic [31:0] ALU, 
	input logic [31:0] ALUOut,
	input logic [31:0] RegDesloc,
	input logic [2:0]  PCSource,
	input logic [31:0] JR,
	input logic [31:0] EPC,
	input logic [31:0] RotinaDeTratamentoAddress,
	output logic [31:0] inPC
);

always_comb
	begin
		case (PCSource)
		3'b000: inPC <= ALU;
		3'b001: inPC <= ALUOut;
		3'b010: inPC <= RegDesloc;
		3'b011: inPC <= JR;
		3'b100: inPC <= EPC;
		3'b101: inPC <= RotinaDeTratamentoAddress;
		default: inPC <= ALU;
		endcase
	end

endmodule: MuxSaidaALU

