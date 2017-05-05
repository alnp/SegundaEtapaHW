module shiftLeft2_32
(	input signed[31:0]in,
	output signed[31:0]out
	);

assign out = in << 2;

endmodule: shiftLeft2_32