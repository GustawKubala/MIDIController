`timescale 1ns / 1ps

module event_handler(
    input clk,
    input [1:0] sel_in,
    input [6:0] velocity,
    output reg write_en,
    output reg [23:0] frame_out
    );

//parameters
parameter transposition = 60; //60 for middle C
parameter note_off      = 8'b10000001;
parameter note_on       = 8'b10010001;

reg [6:0] note_reg = 7'b0000000; // for converting a decimal note to 7bit binary

reg [1:0]sel_buf = 2'b00;
reg [6:0]vel_buf[3:0];

integer k;
initial begin
    for (k = 0; k < 4; k = k + 1)
    vel_buf[k] = 7'b0000000;
end

    //event detection
    function [1:0] cmpr;
        input [6:0] prev, next;
        begin
            if (prev == 7'b0000000 && next != 7'b0000000) cmpr = 2'b01;
            else if (prev != 7'b0000000 && next == 7'b0000000) cmpr = 2'b10;
            else cmpr = 2'b00;
        end   
    endfunction
    
    //frame construction
    function [23:0] frame;
        input [1:0] note; 
        input [6:0] velocity;
        input onoff;
        begin
            note_reg = transposition + note;
            if (onoff) frame = {note_on, 1'b0, note_reg, 1'b0, velocity}; 
            else if (!onoff) frame = {note_off, 1'b0, note_reg, 1'b0, velocity}; 
        end
    endfunction
    
    always@(posedge clk) begin
        if(sel_buf != sel_in) begin
            case(cmpr(vel_buf[sel_in], velocity))
            2'b01: 
            begin 
                frame_out = frame (sel_in, velocity, 1'b1);
                write_en = 1'b1;
                vel_buf[sel_in] = velocity;
            end
            2'b10: 
            begin 
                frame_out = frame (sel_in, vel_buf[sel_in], 1'b0);
                write_en = 1'b1;
                vel_buf[sel_in] = velocity;
            end
            2'b00:
                write_en = 1'b0;
            default:
                write_en = 1'b0;
            endcase
            sel_buf <= sel_in;   
        end
        else
            write_en = 1'b0;
    end
    
endmodule