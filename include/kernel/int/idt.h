
struct idt_entry {
    unsigned short offset_low;
    unsigned short selector;
    unsigned char ist;
    unsigned char type_attr;
    unsigned short offset_mid;
    unsigned int offset_high;
    unsigned int zero;
} __attribute__((packed));

struct interrupt_descriptor_table {
    struct idt_entry entries[256];
} __attribute__((packed));

struct idt_descriptor {
    unsigned short limit;
    unsigned long long base;
} __attribute__((packed));

void idt_set(
    unsigned char index,
    unsigned long long addr,
    unsigned short selector,
    unsigned char ist,
    unsigned char type_attr
);

void idt_start(void);
