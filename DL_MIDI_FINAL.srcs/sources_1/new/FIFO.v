`timescale 1ns / 1ps

module FIFO(
    input clk,
    input read,
    input write,
    input [23:0] din,
    output reg [23:0] dout
    );
    
reg [4:0] count = 4'b0000;

wire empty;
wire full;
assign empty = (count==0);
assign full = (count==15);

reg [4:0] read_pointer = 4'b0000;
reg [4:0] write_pointer = 4'b0000;

//ram init
parameter RAM_WIDTH = 24;
parameter RAM_ADDR_BITS = 4;

reg [RAM_WIDTH-1:0] ram [(2**RAM_ADDR_BITS)-1 : 0];  

    //initializing ram with zeros
    integer k;
    initial begin
        for (k = 0; k < 16; k = k + 1)
        ram[k] <= 24'b0;
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
        else
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
endmodule