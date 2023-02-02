`timescale 1ns / 1ps

module event_handler_tb( );

reg clk;
reg [1:0] sel_in;
reg [6:0] velocity;
wire write_en;
wire [23:0] frame_out;

event_handler uut ( .clk(clk), .sel_in(sel_in), .velocity(velocity), .write_en(write_en), .frame_out(frame_out));

initial begin
    clk=0;
    forever #5 clk = ~clk; 
end

initial begin
    sel_in = 2'b00;
    velocity = 7'b0000000;
    #20 
    sel_in = 2'b01;
    velocity = 7'b1101010;
    #20
    velocity = 7'b1111111;
    #20
    velocity = 7'b0001010;
    #40 
    sel_in = 2'b10;
    velocity = 7'b1000001; 
    #50
    sel_in = 2'b11;
    velocity = 7'b1111111; 
    #50
    sel_in = 2'b00;
    velocity = 7'b0111111;
    #50
    sel_in = 2'b01;
    velocity = 7'b0000000;
    #100 
    $finish;
end 

endmodule
