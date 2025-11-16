clang "-T" rv/link.ld "-x" assembler-with-cpp rv/main.S "-target" riscv32-unknown-none "-march=rv32em" "-nostdlib" "-o" rv/output.elf "-fuse-ld=lld"
llvm-objcopy rv/output.elf -O binary rv/output.bin

let size = (ls rv/output.bin | get 0.size)
const max_size = 2Kib;
if ($size > $max_size) {
  print "file is larger than 2kb"
  exit 1
}
let mems = open rv/output.bin -r | into binary | encode hex | into string | split chars | chunks 2 | each {str join}
| enumerate | each {$"mem[($in.index)] = 8'h($in.item);"}
print $"file size: ($size | into int), max: ($max_size | into int)"
$"($mems | str join "\n")\nfor \(i = ($size | into int); i < $size\(mem\); i = i + 1\) mem[i] = 0;"
  | save src/actual/code_memory.gen.sv -f
