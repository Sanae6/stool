// ai generated synchronizer (cdc)

module variable_sync #(
  parameter WIDTH = 1, // Width of the input signal
  parameter STAGES = 2  // Number of stages (flip-flops)
) (
  input wire clk,                // Clock signal
  input wire rstn,               // Asynchronous reset (active low)
  input wire [WIDTH-1:0] async_sig_i, // Asynchronous input signal
  output reg [WIDTH-1:0] sync_sig_o // Synchronized output signal
);

  // Internal signals for synchronizing
  reg [WIDTH-1:0] temp_reg [0:STAGES-1]; // Registers for intermediate stages
  integer i;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // Reset all output registers
      for (i = 0; i < STAGES; i = i + 1) begin
        temp_reg[i] <= {WIDTH{1'b0}};
      end
      sync_sig_o <= {WIDTH{1'b0}};
    end else begin
      // Shift input through the synchronizer stages
      temp_reg[0] <= async_sig_i;
      for (i = 1; i < STAGES; i = i + 1) begin
        temp_reg[i] <= temp_reg[i-1];
      end
      sync_sig_o <= temp_reg[STAGES-1];
    end
  end

endmodule
