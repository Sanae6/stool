clang -T rv/link.ld -x assembler-with-cpp rv/main.S -target riscv32-unknown-none -march=rv32e -nostdlib -o rv/output.elf
llvm-objcopy rv/output.elf -O binary rv/output.bin 
let mems = open rv/output.bin -r | into binary | encode hex | into string | split chars | chunks 2 | each {str join}
| enumerate | each {$"mem[($in.index)] = 8'h($in.item);"}
let remaining = 4096 - ($mems | length);
$"($mems | str join "\n")\nfor \(i = ($remaining); i < 4096; i = i + 1\) mem[i] = 0;"
  | save src/actual/code_memory.gen.sv -f
