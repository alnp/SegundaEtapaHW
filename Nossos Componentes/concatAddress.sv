module concatAddress
(	input logic[27:0] J, 
	input logic[31:0] PC, 
	output logic[31:0] concatAddress_out
	);

 always_comb
	begin
		concatAddress_out = {PC[31:28], J[27:0]};
	end
endmodule: concatAddress