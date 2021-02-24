#include "gpio.h"

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

static long page_size = -1;

static int mem_fd = -1;


void *addr_map(addr_t addr)
{
  if (mem_fd == -1) {
    mem_fd = open("/dev/mem", O_RDWR);
  }
  if (page_size == -1) {
    page_size = sysconf(_SC_PAGESIZE);
  }

  addr_t addr_aligned = addr & (~(page_size - 1));
  addr_t offset = addr - addr_aligned;
  void *addr_alloc = mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, addr_aligned);
  return (void *)((addr_t)addr_alloc + offset);
}


void *addr_unmap(void *addr)
{
  addr_t addr_aligned = (addr_t)addr & (~(page_size - 1));
  munmap((void *)addr_aligned, page_size);
}
