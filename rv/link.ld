MEMORY {
  ROM (rx)   : ORIGIN = 0x00000000, LENGTH = 0x02000
  RAM (rw)   : ORIGIN = 0x00010000, LENGTH = 0x02000
  PUZZLE (w) : ORIGIN = 0x00080000, LENGTH = 0x01000
}

SECTIONS {
  ram_start = ORIGIN(RAM);
  puzzle_output = ORIGIN(PUZZLE);
  solution_output = ORIGIN(PUZZLE) + 84;
  _start = 0;
  . = 16;
  _irq_start = .;
  .text : {
    *(.text .text.*)
  } :text

  .rodata : {
    *(.rodata .rodata.*)
  } :rodata
  stack_bottom = ram_start + LENGTH(RAM);

  . = ram_start;
  .bss : {
    *(.bss .bss.*)
  } :bss
}
