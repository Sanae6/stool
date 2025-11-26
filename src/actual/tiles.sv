`define SYNTHESIS

module numbers (
  input logic clk,
  input logic rst,

  input logic [3:0] number,
  input logic [13:0] x,
  input logic [13:0] y,

  output logic [3:0] value
);

//synthesis translate_off
  always_comb begin
    value = number == 0 ? 0 : tiles[number - 1][y][x];
  end
  `undef SYNTHESIS
//synthesis translate_on
  logic [13:0] address;
  always_comb address = {12'(y * 'd48 + x), 2'd0};
  logic [0:8][31:0] out;
  always_comb value = number == 0 ? 8 : out[number - 1][3:0];
  // always_comb value = 0;
  `ifdef SYNTHESIS
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_1 (
    .DO(out[0]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_2 (
    .DO(out[1]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_3 (
    .DO(out[2]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_4 (
    .DO(out[3]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_5 (
    .DO(out[4]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_6 (
    .DO(out[5]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_7 (
    .DO(out[6]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_8 (
    .DO(out[7]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  pROM #(
    .READ_MODE(1),
    .BIT_WIDTH(4)
  ) bram_prom_9 (
    .DO(out[8]),
    .CLK(clk),
    .OCE('1),
    .CE('1),
    .RESET('0),
    .AD(address)
  );
  `endif

  `include "tiles.gen.sv"
endmodule
// `endif
