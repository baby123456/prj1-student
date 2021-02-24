`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output reg [`DATA_WIDTH - 1:0] Result
);

	// TODO: insert your code

	parameter ALUOP_AND = 3'b000,
		ALUOP_OR = 3'b001,
		ALUOP_ADD = 3'b010,
		ALUOP_SUB = 3'b110,
		ALUOP_SLT = 3'b111;

	wire is_sub = (ALUop == ALUOP_SUB) | (ALUop == ALUOP_SLT);
	wire [`DATA_WIDTH - 1:0] B_inv = (is_sub ? ~B : B);

	wire [`DATA_WIDTH - 1:0] sum;
	wire add_carry;

	assign {add_carry, sum} = A + B_inv + is_sub;
	assign CarryOut = add_carry ^ is_sub;

	assign cin_msb = sum[`DATA_WIDTH - 1] ^ A[`DATA_WIDTH - 1] ^ B_inv[`DATA_WIDTH - 1];
	assign Overflow = add_carry ^ cin_msb;

	assign Zero = ~(|Result);
   
	always@(*) begin
		case(ALUop)
			ALUOP_AND: Result = A & B;
			ALUOP_OR: Result = A | B;
			ALUOP_ADD: Result = sum;
			ALUOP_SUB: Result = sum;
			ALUOP_SLT: Result = {{(`DATA_WIDTH - 1){1'b0}}, (Overflow ^ sum[`DATA_WIDTH - 1])};
			default: Result = {`DATA_WIDTH{1'b0}};
		endcase
	end

endmodule
