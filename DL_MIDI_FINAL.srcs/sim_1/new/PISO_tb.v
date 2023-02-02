`timescale 1ns / 1ps

module PISO_tb( );

reg clk;
reg [23:0] din;
wire dout;

PISO uut(.clk(clk), .din(din), .dout(dout));

initial begin
    clk=0;
    forever #5 clk = ~clk; 
end 

initial begin
    din = 24'h000000;
    #20 
    din = 24'h999999;
    #20
    din = 24'h000000;
    #300
    din = 24'ha5a5a5;
    #20
    din = 24'h000000;
    #300
    $finish;
end 

endmodule

