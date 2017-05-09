module Concatenador
(	input logic[31:0] baseword,
	input logic[15:0] B,
	input logic controle,
	output logic[31:0] saida
	);
	
	always_comb 
	begin
		case(controle)//byte
		1'b0: saida <= {baseword[31:8],B[7:0]};   
		1'b1: saida <= {baseword[31:16],B[15:0]};
		endcase
	end
	      
endmodule: Concatenador