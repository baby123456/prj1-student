#pragma once

#include <stdint.h>
typedef unsigned long long addr_t;

void *addr_map(addr_t addr);
void *addr_unmap(void *addr);
