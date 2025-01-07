OUTPUT_ARCH("riscv")
ENTRY(_start)

BASE_ADDRESS = 0x80000000;

SECTIONS
{
    . = BASE_ADDRESS;
    .text : {
        . = ALIGN(4);
        *(.text .text.*);
    }

    .rodata : {
        . = ALIGN(4);
        *(.srodata .srodata.*);
        . = ALIGN(4);
        *(.rodata .rodata.*);
    }

    .data : {
        . = ALIGN(4);
        *(.sdata .sdata.*);
        . = ALIGN(4);
        *(.data .data.*);
    }

    .bss : {
        . = ALIGN(4);
        *(.sbss .sbss.*);
        . = ALIGN(4);
        *(.bss .bss.*);
    }

    PROVIDE(_bss_start = ADDR(.bss));
    PROVIDE(_bss_end = _bss_start + SIZEOF(.bss));
    PROVIDE(_stack_top = _bss_end + 0x1000);
}
