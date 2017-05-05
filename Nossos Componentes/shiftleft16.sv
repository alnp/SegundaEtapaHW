module shiftLeft16
(	input signed [31:0] in,
	output signed [31:0] out
	);
	
	assign out = in << 16;
	
endmodule: shiftLeft16