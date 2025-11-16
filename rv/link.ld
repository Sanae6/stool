MEMORY {
  ROM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x01000
  RAM (rwx) : ORIGIN = 0x00002000, LENGTH = 0x01000
}

SECTIONS {
  ram_start = ORIGIN(RAM);
  _start = 0;
  . = 16;
  _irq_start = .;
}
