`timescale 1ns / 1ps

module PISO(
   
    input clk,
    input [23:0] din,
    output reg dout = 0,
    output reg ready = 1'b1
    
    );

    reg count = 0;
    reg [23:0] shift = 23'b0;
    reg [4:0] j = 5'b0;
    
    always @(posedge clk)
    begin
        if (j == 0 && din[23] == 1) 
        begin
            ready = 0;
            shift = din;
        end
        
        if (ready == 0)
        begin
        dout   = shift[23];
        shift = {shift[22:0],1'b0};
            if (j < 24)
                j = j + 1;
            else if (j == 24)
            begin
                j = 0;
                ready = 1;
            end
        end
    end
endmodule
