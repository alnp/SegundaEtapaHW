module MuxB
(
	input logic [31:0] B, 
	input logic [31:0] signalExt,
	input logic [31:0] desloc_esq,
	//input logic [2:0] Four,
	input logic [1:0] ALUSrcB,
	output logic [31:0] BOut
);

always_comb
	begin
		case (ALUSrcB)
		2'b00: BOut <= B;
		2'b01: BOut <= 32'b00000000000000000000000000000100;
		2'b10: BOut <= signalExt;
		2'b11: BOut <= desloc_esq;
		endcase
	end

endmodule: MuxB