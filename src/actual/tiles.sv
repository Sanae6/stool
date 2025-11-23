module numbers (
  output logic [0:47][0:47][3:0] tileset [0:8]
);
  `include "tiles.gen.sv"
  assign tileset = tiles;
endmodule
