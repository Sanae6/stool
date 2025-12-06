#include "custom_ops.S"

.macro start_frame size=0
  .set __frame_size, (4 +\size)
  .set __ra_offset, \size
  addi sp, sp, -__frame_size
  sw ra, __ra_offset(sp)
.endm
.macro end_frame
  lw ra, __ra_offset(sp)
  addi sp, sp, __frame_size
  ret
.endm

.section ".text"
_start:
  j reset
.balign 16
reset:
  lui sp, %hi(stack_bottom)

  la a0, layout
  li a1, 81
  jal incrementing_init

  la a0, sequence
  li a1, 10
  jal incrementing_init

  # la a0, sequence + 1
  # li a1, 9
  # jal shuffle_bytes

  # la a0, layout
  # jal shuffle_bands

  # jal rotate_cw_90
  # jal rotate_ccw_90

  la a0, solution
  la a1, solution_output
  jal substitute_and_output

  la a0, puzzle
  la a1, puzzle_output
  jal substitute_and_output

  li tp, 2
  ebreak

incrementing_init: # address, size
  add t0, a0, a1
  li t1, 0
1:
  beq t0, a0, 2f

  sb t1, 0(a0)
  addi a0, a0, 1
  addi t1, t1, 1

  j 1b
2:
  ret

memcpy:
  add t0, a0, a2
1:
  beq a0, t0, 2f
  lb t1, 0(a1)
  sb t1, 0(a0)
  add a0, a0, 1
  add a1, a1, 1
  j 1b
2:
  ret
memswp: # a, b, size (swap all bytes between a and b)
  add t0, a0, a2
1:
  beq a0, t0, 2f
  lb t1, 0(a1)
  lb t2, 0(a0)
  sb t1, 0(a0)
  sb t2, 0(a1)
  add a0, a0, 1
  add a1, a1, 1
  j 1b
2:
  ret

random_uint: # exclusive maximum -> value
  lui t0, 0x30 # page 3 yields random values
  lw t0, 0(t0)
  remu a0, t0, a0
  ret

shuffle_bytes: start_frame 4 # address, size>2 -> address
  sw a0, 0(sp)
  addi s0, a1, -1
  
1:
  beq s0, zero, 2f
  # j = random_uint(i + 1)
  addi a0, s0, 1
  jal random_uint

  # calculate addresses
  lw t0, 0(sp)
  add a2, t0, s0 # t0 + i
  add a3, t0, a0 # t0 + j

  # swap numbers
  lb s1, 0(a2)
  lb t1, 0(a3)
  sb s1, 0(a3)
  sb t1, 0(a2)

  addi s0, s0, -1 # i -= 1
  
  j 1b
    
2:
  end_frame

shuffle_bands: start_frame 4 # layout
  sw a0, 0(sp)
  addi s0, zero, 2

1:
  beqz s0, 2f

  addi a0, s0, 1
  jal random_uint

  lw t0, 0(sp)
  li a2, 27
  mul a3, a0, a2
  mul a4, s0, a2
  add a0, t0, a4 # t0 + i
  add a1, t0, a3 # t0 + j

  jal memswp

  addi s0, s0, -1
  j 1b

2:
  end_frame

#https://stackoverflow.com/a/8664879 <3
transpose_layout:
  la s0, layout
  addi t0, zero, 1 # x
  li a5, 9
1:
  beq t0, a5, 3f
  mv t1, zero # y
2:
  beq t1, a5, 1b
  mul a1, t1, a5
  mul a2, t0, a5
  add a1, a1, t0
  add a2, a2, t1
  add a1, s0, a1
  add a2, s0, a2

  lb a3, 0(a1)
  lb a4, 0(a2)
  sb a3, 0(a2)
  sb a4, 0(a1)
  
  addi t1, t1, 1
  bne t1, t0, 2b
  addi t0, t0, 1
  j 1b
3:
  ret

# tried out google antigravity for reverse_rows and reverse_columns
reverse_rows:
  la s0, layout
  li a5, 9          # row count
  li t0, 0          # row index

1:
  beq t0, a5, 3f    # if row index == 9, return

  # Inner loop: swap cols 0..3 with 8..5
  li a2, 0          # col index (0 to 3)
  li a3, 4          # limit

2:
  beq a2, a3, 4f
  
  # Calculate offsets
  add a4, s0, a2    # addr 1 = row_base + col
  li t1, 8
  sub t1, t1, a2    # 8 - col
  add t1, s0, t1    # addr 2 = row_base + (8 - col)

  # Swap
  lb t2, 0(a4)
  lb a1, 0(t1)
  sb a1, 0(a4)
  sb t2, 0(t1)

  addi a2, a2, 1
  j 2b

4:
  addi s0, s0, 9    # Move to next row
  addi t0, t0, 1    # Increment row counter
  j 1b

3:
  ret

reverse_columns: start_frame
  la s0, layout
  
  # Swap row 0 and 8
  mv a0, s0
  addi a1, s0, 72
  li a2, 9
  jal memswp

  # Swap row 1 and 7
  addi a0, s0, 9
  addi a1, s0, 63
  li a2, 9
  jal memswp

  # Swap row 2 and 6
  addi a0, s0, 18
  addi a1, s0, 54
  li a2, 9
  jal memswp

  # Swap row 3 and 5
  addi a0, s0, 27
  addi a1, s0, 45
  li a2, 9
  jal memswp

  end_frame

rotate_cw_90: start_frame
  jal transpose_layout
  jal reverse_rows
  end_frame
  # transpose, reverse rows
rotate_ccw_90: start_frame
  jal transpose_layout
  jal reverse_columns
  end_frame
  # transpose, reverse columns
rotate_180:
flip_horizontal:
flip_vertical:

substitute_and_output: # puzzle string, puzzle output
  la s0, layout
  la s1, sequence
  addi a5, s0, 81
  
1:
  bge s0, a5, 2f

  lb t0, 0(s0) # load next layout elem
  addi s0, s0, 1 # inc layout ptr
  add t0, a0, t0 # puzzle + elem
  lb t0, 0(t0) # deref puzzle

  add t1, s1, t0 # sequence[puzzle[layout[i]]]
  lb t0, 0(t1) # load seq value
  sb t0, 0(a1) # store in puzzle output
  addi a1, a1, 1
  j 1b

2:
  ret

.rodata
.section ".rodata.puzzle"
puzzle: .byte 7,0,0,4,0,0,3,1,6,0,0,0,7,0,0,0,0,9,9,0,6,0,0,8,7,0,2,2,0,9,1,5,4,8,7,3,0,0,1,6,3,7,0,0,4,0,7,0,2,0,0,0,0,0,6,0,4,0,0,1,2,3,0,0,0,2,0,0,0,0,0,0,3,0,0,8,0,2,6,9,1
solution: .byte 7,2,8,4,9,5,3,1,6,1,3,5,7,2,6,4,8,9,9,4,6,3,1,8,7,5,2,2,6,9,1,5,4,8,7,3,5,8,1,6,3,7,9,2,4,4,7,3,2,8,9,1,6,5,6,9,4,5,7,1,2,3,8,8,1,2,9,6,3,5,4,7,3,5,7,8,4,2,6,9,1

.bss
sequence:
  .space 10
layout:
  .space 9 * 9
