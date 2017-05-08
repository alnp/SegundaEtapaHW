module MuxRegWrite
(	input logic [4:0] register_t, register_d,
	input logic [1:0] RegDest,
	output logic [4:0] WriteRegister
);

	always_comb
	begin
		case(RegDest)
		2'b00: WriteRegister <= register_t;
		2'b01: WriteRegister <= register_d;
		2'b10: WriteRegister <= 5'b11111; //r31
		default: WriteRegister <= register_t;
		endcase
	end

endmodule: MuxRegWrite