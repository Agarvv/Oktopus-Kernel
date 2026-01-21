CC31    := i386-elf-gcc
CC64    := x86_64-elf-gcc
LD32    := i386-elf-ld
LD64    := x86_64-elf-ld
NASM    := nasm
QEMU    := qemu-system-x86_64
DD      := dd

INC_DIR := include
BUILD   := build
OBJ_DIR := $(BUILD)/obj

STAGE1_SRC := src/bootloader/stage1/main.S
STAGE2_SRC := $(shell find src/bootloader/stage2 -name "*.c")
KERNEL_SRC := $(shell find src/kernel -name "*.c")
ASM_SRC    := $(shell find src/asm -name "*.asm")

IMG        := $(BUILD)/disk.img
STAGE1_BIN := $(BUILD)/stage1.bin
STAGE2_BIN := $(BUILD)/stage2.bin
KERNEL_BIN := $(BUILD)/kernel.bin

STAGE2_OBJS := $(patsubst src/bootloader/stage2/%.c,$(OBJ_DIR)/boot2_%.o,$(STAGE2_SRC))
KERNEL_OBJS := $(patsubst src/kernel/%.c,$(OBJ_DIR)/kernel_%.o,$(KERNEL_SRC))
ASM_OBJS    := $(patsubst src/asm/%.asm,$(OBJ_DIR)/%.o,$(ASM_SRC))



CFLAGS32 := -ffreestanding -m32 -fno-builtin -fno-stack-protector -O0 \
            -I$(INC_DIR) \
            -B/home/laptop/Downloads/i386-elf-binutils/bin \
            -Wa,--32 \
            -fno-asynchronous-unwind-tables -fno-unwind-tables


CFLAGS64 := -ffreestanding -fno-builtin -fno-stack-protector -O0 -I$(INC_DIR)

$(shell mkdir -p $(OBJ_DIR))
$(shell mkdir -p $(BUILD))

all: $(IMG) run

$(STAGE1_BIN): $(STAGE1_SRC)
	$(NASM) -f bin $< -o $@

$(OBJ_DIR)/boot2_%.o: src/bootloader/stage2/%.c
	mkdir -p $(dir $@)
	$(CC32) $(CFLAGS32) -c $< -o $@

$(OBJ_DIR)/kernel_%.o: src/kernel/%.c
	mkdir -p $(dir $@)
	$(CC64) $(CFLAGS64) -c $< -o $@

$(OBJ_DIR)/%.o: src/asm/%.asm
	mkdir -p $(dir $@)
	$(NASM) -f elf32 $< -o $@

$(STAGE2_BIN): $(STAGE2_OBJS) $(ASM_OBJS)
	$(LD32) -m elf_i386 -T stage2.ld -o $(BUILD)/stage2.elf $^
	objcopy -O binary $(BUILD)/stage2.elf $@

$(KERNEL_BIN): $(KERNEL_OBJS)
	$(LD64) -m elf_x86_64 -T kernel.ld -o $(BUILD)/kernel.elf $^
	objcopy -O binary $(BUILD)/kernel.elf $@

$(IMG): $(STAGE1_BIN) $(STAGE2_BIN) $(KERNEL_BIN)
	$(DD) if=/dev/zero of=$@ bs=512 count=32768
	$(DD) if=$(STAGE1_BIN) of=$@ bs=512 count=1 conv=notrunc
	$(DD) if=$(STAGE2_BIN) of=$@ bs=512 seek=1 conv=notrunc
	$(DD) if=$(KERNEL_BIN) of=$@ bs=512 seek=33 conv=notrunc


run: $(IMG)
	qemu-system-x86_64 \
		-drive file=$(IMG),format=raw \
		-serial stdio \
		-s \
		-no-reboot \
		-no-shutdown





clean:
	rm -rf $(BUILD)/*

.PHONY: all clean run

