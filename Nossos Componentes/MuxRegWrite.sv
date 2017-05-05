module MuxRegWrite
(	input logic [4:0] register_t, register_d,
	input logic RegDest,
	output logic [4:0] WriteRegister
);

	always_comb
	begin
		case(RegDest)
		1'b0: WriteRegister <= register_t;
		1'b1: WriteRegister <= register_d;
		endcase
	end

endmodule: MuxRegWrite