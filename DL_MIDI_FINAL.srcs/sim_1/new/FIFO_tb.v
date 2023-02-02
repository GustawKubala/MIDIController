`timescale 1ns / 1ps

module FIFO_tb( );

reg clk;
reg read;
reg write;
reg [23:0] din;
wire [23:0] dout;

FIFO uut ( .clk(clk), .read(read), .write(write), .din(din), .dout(dout));

initial begin
    clk=0;
    forever #5 clk = ~clk; 
end

initial begin
    read = 1'b0;
    write = 1'b0;
    din = 24'h000000;
    #20 
    write = 1'b1;
    din = 24'haaaaaa;
    #20
    din = 24'hb5b5b5;
    #20
    din = 24'h5a5a5a;
    #20
    write = 1'b0;
    #30
    #15 read = 1'b1;
    #15 read = 1'b0;
    #15 read = 1'b1;
    #15 read = 1'b0;
    #15 read = 1'b1;
    #15 read = 1'b0;
    #100
    $finish;
end 

endmodule
