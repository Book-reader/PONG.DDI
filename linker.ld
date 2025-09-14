OUTPUT_FORMAT( "elf32-littleriscv" )
OUTPUT_ARCH( "riscv" )

ENTRY( _start )

MEMORY
{
    program (wxa) : ORIGIN = 0x0, LENGTH = 20480
}

PHDRS
{
    prg PT_LOAD ;
}

SECTIONS {
    .text : {
        . = ALIGN(512);
        *(.text .text.*)
    } >program AT>program :prg

    .rodata : {
        *(.rodata .rodata.*)
    } >program AT>program :prg

    .data : {
        *(.sdata .sdata.*) *(.data .data.*)
    } >program AT>program :prg

    .bss : {
        *(.sbss .sbss.*)
        *(.bss .bss.*)
    } >program AT>program :prg
}