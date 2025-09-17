OUTPUT_FORMAT( "elf32-littleriscv" )
OUTPUT_ARCH( "riscv" )

ENTRY( _start )
# ENTRY( main )

MEMORY
{
	program (wxa) : ORIGIN = 0x0, LENGTH = 20480
}

PHDRS
{
	prg PT_LOAD;
	tls PT_TLS;
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
		*(.sdata .sdata.*)
		*(.data .data.*)
	} >program AT>program :prg

	.bss : {
		# *(.sbss .sbss.*)
		*(.bss .bss.*)
	} >program AT>program :prg

	.tdata : {
		*(.tdata .tdata.*)
	} >program AT>program :prg :tls

	.tbss : {
		*(.tbss .tbss.*)
		*(.tsbss .tsbss.*)
	} >program AT>program :prg :tls

	# .debug : {
	# 	*(.debug_abbrev .debug_abbrev.*)
	# 	*(.debug_info .debug_info.*)
	# 	*(.debug_line .debug_line.*)
	# 	*(.debug_pubnames .debug_pubnames.*)
	# 	*(.debug_pubtypes .debug_pubtypes.*)
	# 	*(.debug_str .debug_str.*)
	# } >program AT>program :prg
}
