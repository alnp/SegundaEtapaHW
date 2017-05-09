module chooseByteUnsign (in, out);

input [31:0] in;
output [31:0] out;

assign out [31:8] = 24'd0;
assign out [7:0] = in [31:24];

endmodule: chooseByteUnsign