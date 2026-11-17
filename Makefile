ifndef TARGET_COMPILE
    $(error TARGET_COMPILE not set)
endif

ifndef KP_DIR
    KP_DIR = ../KernelPatch
endif

CC = $(TARGET_COMPILE)gcc
LD = $(TARGET_COMPILE)ld

INCLUDE_DIRS := . include patch/include linux/include linux/arch/arm64/include linux/tools/arch/arm64/include

INCLUDE_FLAGS := $(foreach dir,$(INCLUDE_DIRS),-I$(KP_DIR)/kernel/$(dir))

objs := hide_env.o

# 关键: 老内核(KernelPatch d09)不支持 __stack_chk_* / TLS 重定位 / 编译器生成的 memset 调用
CFLAGS := -fno-stack-protector -fno-builtin -fno-tree-loop-distribute-patterns \
          -fno-asynchronous-unwind-tables -fno-unwind-tables -fno-jump-tables \
          -fno-stack-check -mno-outline-atomics

all: hide_env.kpm

hide_env.kpm: $(objs)
	$(CC) -r -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDE_FLAGS) -c -O2 -o $@ $<

.PHONY: clean
clean:
	rm -rf *.kpm *.o
