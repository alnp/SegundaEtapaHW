module chooseHalfUnsign (in, out);

input [31:0] in;
output [31:0] out;

assign out [31:16] = 24'd0;
assign out [15:0] = in [15:0];

endmodule: chooseHalfUnsign