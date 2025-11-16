#include "custom_ops.S"

_start:
  j reset
.balign 16
_irq_start:
  j irq_handler

reset:
  addi x1, x0, 0x8
  not x1, x1
  picorv32_maskirq_insn(x0, x1)

  addi x1, x0, 0
  addi x3, x0, 0
  addi x4, x0, 0
loop:
  picorv32_waitirq_insn(x0)
  j loop

irq_handler:
  addi x3, x3, 1
  bltu x3, x4, irq_end

  addi x3, x0, 0
  addi x1, x1, 1
  lui x2, 1
  sw x1, 0(x2)
irq_end:
  picorv32_retirq_insn()
