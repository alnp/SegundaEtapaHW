module shiftLeft2_26to28
(	input [25:0] in,
	output [27:0] out
	);

assign out = {in[25:0],2'b00};

endmodule: shiftLeft2_26to28