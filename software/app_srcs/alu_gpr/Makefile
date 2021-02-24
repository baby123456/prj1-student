O ?= $(shell pwd)/out

ROOT := $(shell pwd)

OUT := $(O)/alu_gpr
OBJS := $(addprefix $(O)/, alu_gpr.o alu_ans.o gpio.o)

CC := $(CROSS_COMPILE)gcc

all: $(OUT)
	@echo "Compiled alu_gpr"

$(OUT): $(OBJS)
	$(CC) -o $(OUT) $(OBJS)

$(O)/%.o: $(ROOT)/%.c
	@mkdir -p $(O)
	$(CC) -c -o $@ $<

clean:
	@rm -f $(OUT) $(OBJS)

distclean:
	@rm -rf $(O)



