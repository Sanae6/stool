module top(
	input sys_clk50,
	input resetn,
	
	output       tmds_clk_n_0,
	output       tmds_clk_p_0,
	output [2:0] tmds_d_n_0,
	output [2:0] tmds_d_p_0
	
	// output       tmds_clk_n_1,
	// output       tmds_clk_p_1,
	// output [2:0] tmds_d_n_1,
	// output [2:0] tmds_d_p_1
);
	wire 	[23 : 0]	dvi_data;
	wire				dvi_den;
	wire				dvi_hsync;
	wire				dvi_vsync;
	
	wire				pll_lock;
	wire				clk_p5;
	wire				clk_p;
	wire				sys_resetn;
	
	Gowin_PLL Gowin_PLL_inst(
		.lock(pll_lock), //output lock
		.clkout0(clk_p), //output clkout0
		.clkout1(clk_p5), //output clkout0
		.clkin(sys_clk50) //input clkin
	);

	Reset_Sync u_Reset_Sync (
		.resetn(sys_resetn),
		.ext_reset(resetn & pll_lock),
		.clk(clk_p)
	);
	
	DVI_TX_Top dvi_tx_top_inst0(
		.I_rst_n(~sys_resetn), //input I_rst_n
		.I_serial_clk(clk_p5), //input I_serial_clk
		.I_rgb_clk(clk_p), //input I_rgb_clk
		.I_rgb_vs(dvi_vsync), //input I_rgb_vs
		.I_rgb_hs(dvi_hsync), //input I_rgb_hs
		.I_rgb_de(dvi_den), //input I_rgb_de
		.I_rgb_r('d255), //input [7:0] I_rgb_r
		.I_rgb_g('d0), //input [7:0] I_rgb_g
		.I_rgb_b('d0), //input [7:0] I_rgb_b
		.O_tmds_clk_p(tmds_clk_p_0), //output O_tmds_clk_p
		.O_tmds_clk_n(tmds_clk_n_0), //output O_tmds_clk_n
		.O_tmds_data_p(tmds_d_p_0), //output [2:0] O_tmds_data_p
		.O_tmds_data_n(tmds_d_n_0) //output [2:0] O_tmds_data_n
	);
	
//	dvi_tx_top dvi_tx_top_inst0(
//		
//		.pixel_clock		(clk_p),
//		.ddr_bit_clock		(clk_p5),
//		.reset				(~sys_resetn),
//		
//		.den				(dvi_den),
//		.hsync				(dvi_hsync),
//		.vsync				(dvi_vsync),
//		.pixel_data			(dvi_data),
//		
//		.tmds_clk			({tmds_clk_p_0, tmds_clk_n_0}),
//		.tmds_d0			({tmds_d_p_0[0], tmds_d_n_0[0]}),
//		.tmds_d1			({tmds_d_p_0[1], tmds_d_n_0[1]}),
//		.tmds_d2			({tmds_d_p_0[2], tmds_d_n_0[2]})
//	);

	test_pattern_gen test_gen0(
		
		.pixel_clock		(clk_p),
		.reset				(~sys_resetn),
		
		.video_vsync		(dvi_vsync),
		.video_hsync		(dvi_hsync),
		.video_den			(dvi_den),
		.video_pixel_even	(dvi_data)
	);

endmodule

module Reset_Sync (
 input clk,
 input ext_reset,
 output resetn
);

 reg [3:0] reset_cnt = 0;
 
 always @(posedge clk or negedge ext_reset) begin
     if (~ext_reset)
         reset_cnt <= 4'b0;
     else
         reset_cnt <= reset_cnt + !resetn;
 end
 
 assign resetn = &reset_cnt;

endmodule
