`timescale 1ns / 1ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file_test
();

	reg clk;
	reg rst;
	reg [`ADDR_WIDTH - 1:0] waddr;
	wire [`ADDR_WIDTH - 1:0] raddr1;
	wire [`ADDR_WIDTH - 1:0] raddr2;
	reg wen;
	reg [`DATA_WIDTH - 1:0] wdata;

	reg [`ADDR_WIDTH - 1:0] raddr;
	wire [`DATA_WIDTH - 1:0] rdata1;
	wire [`DATA_WIDTH - 1:0] rdata2;

	reg [127:0] test_info;

	assign raddr1 = raddr;
	assign raddr2 = raddr;
	
	integer i;

	initial begin
		clk = 'b1;
		rst = 'b1;
		waddr = 'd0;
		raddr = 'd0;
		wen	= 'b0;
		wdata = 'd0;
		test_info = "Initializing";
		for(i=0;i<=31;i=i+1) begin
			u_reg_file.regfile[i] = {`DATA_WIDTH{1'b0}};
		end
		#38
		forever begin
			rst = 'b0;
			waddr = {$random} % 24;
			wen = 1'b1;
			test_info = "Write test";
			repeat(8) begin
				#10
				waddr = waddr + 1'b1;
				wdata = {$random} % 512;
			end
			wen = 1'b0;
			raddr = waddr - 8;
			test_info = "Read test";
			repeat(8) begin
				#10
				raddr = raddr + 1'b1;
			end
			wen = 1'b1;
			waddr = {$random} % 24;
			raddr = waddr;
			test_info = "R&W test";
			repeat(8) begin
				#10
				raddr = raddr + 1'b1;
				waddr = waddr + 1'b1;
				wdata = {$random} % 512;
			end
			waddr = {$random} % 24;
			test_info = "WEN test";
			repeat(8) begin
				#10
				wen = {$random} % 2;
				waddr = waddr + 1'b1;
				wdata = {$random} % 512;
			end
			wen = 1'b0;
			raddr = waddr - 8;
			repeat(8) begin
				#10
				raddr = raddr + 1'b1;
			end
		end
	end

	always begin
		#5 clk = ~clk;
	end

	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),
		.waddr(waddr),
		.raddr1(raddr1),
		.raddr2(raddr2),
		.wen(wen),
		.wdata(wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

endmodule
