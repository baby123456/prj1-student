#include "ALU.h"
#include "gpio.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>


uint32_t *alu_a, *alu_b, *alu_op, *alu_rst, *alu_flag,
         *rf_waddr, *rf_wdata, *rf_wen,
         *rf_raddr1, *rf_raddr2, *rf_rdata1, *rf_rdata2;

int total_count, failed_count;


void init_mem_map(void)
{
  alu_a     = addr_map(0x80000000);
  // alu_b = alu_a + 2;
  alu_b     = addr_map(0x80000008);
  alu_op    = addr_map(0x80010000);
  alu_rst   = addr_map(0x80020000);
  alu_flag  = addr_map(0x80020008);

  rf_waddr  = addr_map(0x80030000);
  // rf_wdata = rf_waddr + 2;
  rf_wdata  = addr_map(0x80030008);
  rf_wen    = addr_map(0x80040000);
  rf_raddr1 = addr_map(0x80050000);
  // rf_raddr2 = rf_raddr1 + 2;
  rf_raddr2 = addr_map(0x80050008);
  rf_rdata1 = addr_map(0x80060000);
  // rf_rdata2 = rf_rdata2 + 2;
  rf_rdata2 = addr_map(0x80060008);
}


#define RD    0
#define RS1   1
#define RS2   2
#define W     1
#define N     0


void reg_write(uint32_t addr, uint32_t data, uint32_t wen)
{
  *rf_wen = wen;
  *rf_waddr = addr;  // Change addr first to avoid writing to wrong reg.
  *rf_wdata = data;
  *rf_wen = N;
}


uint32_t reg_read(uint32_t addr, uint32_t port)
{
  switch(port) {
  case RS1:
    *rf_raddr1 = addr;
    return *rf_rdata1;
  case RS2:
    *rf_raddr2 = addr;
    return *rf_rdata2;
  }

  return 0xffffffff;
}


void test_regfile(void)
{
  uint32_t data = (uint32_t)random(), prev_data = 0;
  uint32_t rs1_data, rs2_data;

  puts("Test r/w on r0");
  reg_write(0, data, W);
  if ((rs1_data = reg_read(0, RS1)) != 0 || (rs2_data = reg_read(0, RS2)) != 0) {
    printf("Error: r0 has non-zero data (rs1=%08x, rs2=%08x)\n", rs1_data, rs2_data);
    failed_count++;
  }

  total_count++;

  puts("Test r/w on r1~r31");
  for (int i = 1; i < 32; i++) {
    do { data = (uint32_t)random(); } while (data == prev_data);
    printf("writing %08x to r%d wen=1\n", data, i);
    reg_write(i, data, W);
    printf("checking data from r%d\n", i);
    if ((rs1_data = reg_read(i, RS1)) != data || (rs2_data = reg_read(i, RS2)) != data) {
      printf("Error: r%d does not have written data=%08x (rs1=%08x, rs2=%08x)\n", i, data, rs1_data, rs2_data);
      failed_count++;
    }
    if (reg_read(i - 1, RS1) != prev_data) {
      printf("Error: r%d's data has been overwritten\n", i - 1);
      failed_count++;
    }
    prev_data = data;
    total_count++;
  }


  puts("Test wen on r1~r31");
  for (int i = 1; i < 32; i++) {
    rs1_data = reg_read(i, RS1);
    do { data = (uint32_t)random(); } while (data == rs1_data);
    printf("writing %08x to r%d wen=0\n", data, i);
    reg_write(i, data, N);
    if ((rs1_data = reg_read(i, RS1)) == data || (rs2_data = reg_read(i, RS2)) == data) {
      printf("Error: r%d has written data under wen=0 (rs1=%08x, rs2=%08x)\n", i, rs1_data, rs2_data);
      failed_count++;
    }
    total_count++;
  }
}


void test_alu(void)
{
  extern int alu_ans_size;
  extern struct ALU_result alu_ans[];
  uint32_t result;
  union {
    struct {
      uint32_t overflow : 1;
      uint32_t carry    : 1;
      uint32_t zero     : 1;
      uint32_t : 29;
    };
    uint32_t bin;
  } flag;

	const char *op_name[] = {
		[0] = "AND",
		[1] = "OR",
		[2] = "ADD",
		[6] = "SUB",
		[7] = "SLT"
	};

  for (int i = 0; i < alu_ans_size; i++) {
    printf("%d/%d", i + 1, alu_ans_size);
    struct ALU_result alu = alu_ans[i];
    *alu_a = alu.a;
    *alu_b = alu.b;
    *alu_op = alu.type;
    result = *alu_rst;
    flag.bin = *alu_flag;

    int flag_en = alu.type == ADD || alu.type == SUB;
    int zero_en = alu.type != SLT;
    int of_err = alu.overflow != flag.overflow;
    int cr_err = alu.carry != flag.carry;
    int zero_err = alu.zero != flag.zero;
    int calc_err = alu.result != result;

    if (calc_err || (zero_err && zero_en) || (flag_en && (of_err || cr_err))) {
      puts(" failed");

      printf("Error, %s 0x%08x, 0x%08x\n", op_name[alu.type], alu.a, alu.b);
      if (calc_err)
        printf("expects result=0x%08x, but gets 0x%08x\n", alu.result, result);
      if (zero_err && zero_en)
        printf("expects zero=%d, but gets %d\n", alu.zero, flag.zero);
      if (of_err && flag_en)
        printf("expects overflow=%d, but gets %d\n", alu.overflow, flag.overflow);
      if (cr_err && flag_en)
        printf("expects carry=%d, but gets %d\n", alu.carry, flag.carry);

      failed_count++;
    }
    else {
      puts(" passed");
    }

    total_count++;
  }
}


int main(int argc, char *argv[])
{
  init_mem_map();

  total_count == 0;
  failed_count == 0;

  puts(argv[1]);
  int result = 0;
  if (!strcmp(argv[1], "reg_file_eval")) {
    test_regfile();
  }
  else if (!strcmp(argv[1], "alu_eval")) {
    test_alu();
  }

  if (failed_count > 0) {
    printf("%s: Test failed (%d/%d failed)\n", argv[1], failed_count, total_count);
  }
  else {
    printf("%s: Test passed (%d in total)\n", argv[1], total_count);
  }
}
