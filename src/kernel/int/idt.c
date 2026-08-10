#include <kernel/int/idt.h>

extern void isr_0(void);

struct interrupt_descriptor_table idt;
struct idt_descriptor idtd;

void idt_set(
    unsigned char index,
    unsigned long long addr,
    unsigned short selector,
    unsigned char ist,
    unsigned char type_attr
) {
    idt.entries[index] = (struct idt_entry){
        .offset_low  = (unsigned short)(addr & 0xFFFF),
        .selector    = selector,
        .ist         = ist,
        .type_attr   = type_attr,
        .offset_mid  = (unsigned short)((addr >> 16) & 0xFFFF),
        .offset_high = (unsigned int)((addr >> 32) & 0xFFFFFFFF),
        .zero        = 0
    };
}

void idt_start(void) {
    idtd.base = (unsigned long long)&idt;
    idtd.limit = sizeof(idt) - 1;

    idt_set(
        0,
        (unsigned long long)&isr_0,
        0x08,
        0,
        0x8E
    );
}