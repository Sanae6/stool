module top (
  input wire in,
  output wire out
);
  assign out = in;

  top t(.in(in), .out(out))
endmodule
