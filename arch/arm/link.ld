OUTPUT_ARCH("arm")
ENTRY(_start)

MEMORY
{
  rom (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00040000
  ram (rwx) : ORIGIN = 0x20000000, LENGTH = 0x00008000
}

_stack_top = ORIGIN(ram) + (LENGTH(ram));

SECTIONS
{
    .text : {
        . = ALIGN(4);
        *(.text .text.*);
    } > rom

    .rodata : {
        . = ALIGN(4);
        *(.srodata .srodata.*);
        . = ALIGN(4);
        *(.rodata .rodata.*);
    } > rom

    .data : {
        . = ALIGN(4);
        *(.sdata .sdata.*);
        . = ALIGN(4);
        *(.data .data.*);
    } > ram

    .bss : {
        . = ALIGN(4);
        *(.sbss .sbss.*);
        . = ALIGN(4);
        *(.bss .bss.*);
    } > ram

    PROVIDE(_bss_start = ADDR(.bss));
    PROVIDE(_bss_end = _bss_start + SIZEOF(.bss));
}
