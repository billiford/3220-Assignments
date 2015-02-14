module LightTest(CLOCK_50, LEDR, LEDG, HEX3, HEX2, HEX1, HEX0, KEY);
output [9:0] LEDG;
output [9:0] LEDR;
output [6:0] HEX3;
output [6:0] HEX2;
output [6:0] HEX1;
output [6:0] HEX0;
input [3:0] KEY;
input CLOCK_50;
 
        wire reset = !KEY[2];  
        reg [3:0] hex_up, hex_down;
        wire [3:0] hex_count;
		  wire [3:0] count_test;
        reg state1, state2, blink_count;
        reg [31:0] count;
        reg [31:0] blink_timer = 12500000;
        reg [31:0] blink_slower, blink_faster, blink_reset;
        reg [1:0] state, red_lights, green_lights;
        reg [3:0] on_off_count;
       
        parameter zero = 0, one = 1, two = 2;
 
        always @(posedge CLOCK_50) begin
					 if (reset) begin
								count <= 0;
								on_off_count <= 0;
					 end
                count <= count + 1;
                if (count == (blink_timer + blink_slower - blink_faster)) begin
                        count <= 0;
                        on_off_count <= on_off_count + 1;
                        if (on_off_count == 6) on_off_count <= 1;
                        if (state == zero) begin
                                green_lights <= !green_lights;
                                red_lights <= 0;
                        end
                        else if(state == one) begin
                                red_lights <= !red_lights;
                                green_lights <= 0;
                        end
                        else begin
                                red_lights <= 0;
                                green_lights <= 0;
                                green_lights <= !green_lights;
                                red_lights <= !red_lights;
                        end
                end
        end
       
        always @(negedge on_off_count or posedge reset) begin
					 if (reset)
							state <= 0;
                else if(on_off_count == 6) begin
                        case(state)
                                zero: state <= 1;
                                one: state <= 2;
                                two: state <= 0;
                        endcase
                end
        end
       
// THIS DECREASES BLINK SPEED ON KEY0 PRESS.
        always @(posedge !KEY[0] or !KEY[1] or posedge reset) begin
					 if (reset) begin
								blink_slower <= 0;
								hex_up <= 0;
					 end else if (hex_count == 8) begin
                        blink_slower <= 0;
                        hex_up <= 0;
                end
                else begin
                        blink_slower <= blink_slower + 2500000;
                        hex_up <= hex_up + 1;
                end
        end
// THIS INCREASES BLINK SPEED ON KEY1 PRESS.
        always @(posedge !KEY[1] or posedge reset) begin
					 if (reset) begin
								blink_faster <= 0;
								hex_down <= 0;
					 end else if (hex_count == 1) begin
                        blink_faster <= 0;      
                        hex_down <= 0;
                end
                else begin
                        blink_faster <= blink_faster + 2500000;
                        hex_down <= hex_down + 1;
                end
        end
// THIS RESETS BLINK SPEED TO 0.5s ON KEY2 PRESS.
		  //always @(posedge reset) begin
					 //assign hex_count = hex_count & 2;
		  //end
        assign hex_count = 2 + hex_up - hex_down;
        SevenSeg sseg3(.IN(hex_count), .OUT(HEX3));

        assign count_test = on_off_count;
        SevenSeg sseg2(.IN(count_test), .OUT(HEX0));
       
        //Blank out unused hex values
        assign HEX2 = ~0;
        assign HEX1 = ~0;
        //assign HEX0 = ~0;
       
        assign LEDG[0]= green_lights;
        assign LEDG[1]= green_lights;
        assign LEDG[2]= green_lights;
        assign LEDG[3]= green_lights;
        assign LEDG[4]= green_lights;
        assign LEDG[5]= green_lights;
        assign LEDG[6]= green_lights;
        assign LEDG[7]= green_lights;
               
        assign LEDR[0]= red_lights;
        assign LEDR[1]= red_lights;
        assign LEDR[2]= red_lights;
        assign LEDR[3]= red_lights;
        assign LEDR[4]= red_lights;
        assign LEDR[5]= red_lights;
        assign LEDR[6]= red_lights;
        assign LEDR[7]= red_lights;
        assign LEDR[8]= red_lights;
        assign LEDR[9]= red_lights;
 
endmodule