module top (
);
  assign out = in;

	input sys_clk50,
	input resetn,
	
	output       tmds_clk_n_0,
	output       tmds_clk_p_0,
	output [2:0] tmds_d_n_0,
	output [2:0] tmds_d_p_0
endmodule
