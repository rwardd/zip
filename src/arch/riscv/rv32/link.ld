OUTPUT_ARCH("riscv")
ENTRY(_start)

BASE_ADDRESS = 0x80000000;

MEMORY
{
    ram (rwxa): ORIGIN = BASE_ADDRESS, LENGTH = 128M
}

SECTIONS
{
    . = BASE_ADDRESS;
    .text : ALIGN(4K) {
        *(.init);
        *(.text);
    }

    .rodata : ALIGN(4K) {
        *(.rodata);
    }

    .data : ALIGN(4K) {
        *(.data);
    }

    .bss : ALIGN(4K) {
        *(.bss);
    }

    PROVIDE(_bss_start = ADDR(.bss));
    PROVIDE(_bss_end = _bss_start + SIZEOF(.bss));
    PROVIDE(_stack_top = _bss_end + 0x1000);
}
