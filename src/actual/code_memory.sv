`timescale 1 ns / 1 ns

module code_memory (
  input reg[11:0] address,
  output reg[31:0] value
);
  reg [7:0] mem [4095:0];

	integer i;
  initial begin
    `include "code_memory.gen.sv"
  end

  var logic [11:0] address_word = address;
  always_comb begin
    value = {mem[address + 3], mem[address + 2], mem[address + 1], mem[address + 0]};
  end
endmodule
