module concatInstr
(	input logic [15:0] dezesseisBits, 
	input logic[4:0] rt, 
	input logic[4:0] rs, 
	output logic[25:0] concat_out
	);

 always_comb
	begin
		concat_out = {rs[4:0], rt[4:0], dezesseisBits[15:0]};
	end
endmodule: concatInstr