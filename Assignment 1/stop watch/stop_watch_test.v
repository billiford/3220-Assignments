`timescale 1ns/1ps
module stop_watch_test();
reg start_t, stop_t, reset_t, clk_t;
wire [3:0] sec_out_lsb_t, sec_out_msb_t, min_out_lsb_t, min_out_msb_t, hr_out_lsb_t, hr_out_msb_t;


stop_watch test_stop_watch (start_t, stop_t, reset_t, clk_t, sec_out_lsb_t, sec_out_msb_t, min_out_lsb_t, min_out_msb_t, hr_out_lsb_t, hr_out_msb_t);

initial begin
	clk_t = 0;
	start_t = 0;
	stop_t = 0;
	reset_t = 0;

	
	#1
	start_t = 1;	
	#1
	start_t = 0;
	
	#5
	reset_t = 1;
	#1
	reset_t = 0;
	
	#1
	start_t=1;
	#1
	start_t=0;
	
	#5
	stop_t = 1;
	#1
	stop_t = 0;
	
	#3
	start_t = 1;
	reset_t = 1;
	#1
	start_t = 0;
	reset_t = 0;
	
	#7
	start_t = 1;
	#1
	start_t = 0;
	
	#117
	stop_t = 1;
	#1
	stop_t = 0;
	
	#5
	start_t = 1;
	#1
	start_t = 0;
end


/*
//Uncomment this for getting the final vcd output file.
initial begin
	$dumpfile("stopwatch_10000ns.vcd");
	$dumpvars(0, stop_watch_test);
	#10000;
	$finish;
end
*/

always
#1 clk_t = ~clk_t;

endmodule
