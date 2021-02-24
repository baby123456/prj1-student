`timescale 10ns / 1ns

`define DATA_WIDTH 32

module alu_test
();

	parameter ALUOP_AND = 3'b000,
		ALUOP_OR = 3'b001,
		ALUOP_ADD = 3'b010,
		ALUOP_SUB = 3'b110,
		ALUOP_SLT = 3'b111;

	reg [`DATA_WIDTH - 1:0] A;
	reg [`DATA_WIDTH - 1:0] B;
	reg [2:0] ALUop;
	wire Overflow;
	wire CarryOut;
	wire Zero;
	wire [`DATA_WIDTH - 1:0] Result;

	reg [2:0] ALUop_reg;
	reg [79:0] operation;

	initial
	begin
		A = 0;
		B = 0;
		ALUop = 0;
		ALUop_reg = 0;
		forever begin
			#10
			A = {$random} % 128;
			B = {$random} % 128;
			ALUop_reg = {$random} % 5;
			ALUop = (ALUop_reg > 2) ? (ALUop_reg + 3) : ALUop_reg;
		end
	end

	alu u_alu(
		.A(A),
		.B(B),
		.ALUop(ALUop),
		.Overflow(Overflow),
		.CarryOut(CarryOut),
		.Zero(Zero),
		.Result(Result)
	);

	always @ (ALUop) begin
		case(ALUop)
			ALUOP_AND: operation = "ALUOP_AND";
			ALUOP_OR: operation = "ALUOP_OR";
			ALUOP_ADD: operation = "ALUOP_ADD";
			ALUOP_SUB: operation = "ALUOP_SUB";
			ALUOP_SLT: operation = "ALUOP_SLT";
		endcase
	end


endmodule
