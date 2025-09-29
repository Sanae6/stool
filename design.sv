module top(
  input wire a,
  input wire b,

  output wire o
);
  assign o = a ^ b;
endmodule;
