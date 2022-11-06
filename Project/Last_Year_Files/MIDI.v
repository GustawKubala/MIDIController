`timescale 1ns / 1ps

module MIDI(clk, note, out, dout);

input clk;
input [11:0] note = 12'b000000000000;

output reg out = 1'b0;
output reg [23:0] dout = 24'b0;

//parameters
parameter transposition = 60; //60 for middle C
parameter note_off      = 8'b10000001;
parameter note_on       = 8'b10010001;
parameter velocity_off  = 8'b01000000; //64 standard for note off
parameter velocity_on   = 8'b01100100; //100 standard for note on

//buffers
reg [11:0] buffer = 12'b000000000000; //stores the previous state of the bus for edge detection
reg [6:0] note_reg = 7'b0000000; // for converting a decimal note to 7bit binary

//ram init
parameter RAM_WIDTH = 24;
parameter RAM_ADDR_BITS = 4;

reg [23:0] din = 24'b0;
reg read = 1'b0;
reg write = 1'b0;

reg [4:0] count = 4'b0000;

assign empty = (count==0);
assign full = (count==15);
reg [4:0] read_pointer = 4'b0000;
reg [4:0] write_pointer = 4'b0000;

reg [RAM_WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1 : 0];

//initializing ram with zeros
integer k;
initial begin
    for (k = 0; k < 16; k = k + 1)
    ram[k] <= 24'b0;
end

//edge detection
reg [3:0] i = 4'b0;
always @(posedge clk)
begin
    if (buffer[i] == 0 && note[i] ==1)
    begin
        note_reg = transposition + i;
        din = {note_on,1'b0,note_reg,velocity_on};
        write = 1'b1;
        buffer[i] <= note [i];
    end
    else if (buffer[i] == 1 && note[i] ==0)
    begin
        note_reg = transposition + i;
        din = {note_off,1'b0,note_reg,velocity_off};
        write = 1'b1;
        buffer[i] <= note [i];
    end
    else
    begin
        write = 1'b0;
        note_reg <= 0;
    end
    if (i < 11)
        i = i + 1;
    else if (i == 11)
        i = 0;
end

//FIFO

always @(posedge clk) //read
begin
    if (read && !empty) 
    begin
        dout<= ram[read_pointer];
        read_pointer = read_pointer +1'b1;
    end
    else if(read && write && empty)
    begin
        dout<= ram[read_pointer];
        read_pointer = read_pointer +1'b1;
    end
    else if (read && !write && empty)
        dout <= 24'b0;
end

always @(posedge clk) //write
begin
    if (write && !full)
    begin
        ram[write_pointer] <= din; 
        write_pointer = write_pointer +1'b1;
    end
end

always @(posedge clk) //count
begin
    case ({write,read})
        2'b01 : count <= (count==0) ? 0 : count-1; 
        2'b10 : count <= (count==8) ? 8 : count+1; 
        default: count <= count;
    endcase
end

//PISO shift reg
reg [23:0] shift = 23'b0;

reg [4:0] j = 5'b0;
always @(posedge clk)
begin
    if (j == 0) 
    begin
        read  = 1'b1;
        shift = dout;
    end
    else 
    begin
        read  = 1'b0;
        out   = shift[23];
        shift = {shift[22:0],1'b0};
    end
    if (j < 24)
        j = j + 1;
    else if (j == 24)
        j = 0;
end
endmodule