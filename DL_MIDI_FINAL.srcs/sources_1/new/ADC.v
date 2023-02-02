`timescale 1ns / 1ps



module ADC(
    input clk,
    input vp_in,
    input vn_in,
    input [3:0] xa_n,
    input [3:0] xa_p,  
    output reg [1:0]sel_out,
    output reg [6:0]velocity_out
    //ONLY FOR DEBUG
    //output [3:0] led,
    //output [7:0] data_out
    );
    //ONLY FOR DEBUG
    //reg [1:0]sel_out;
    //reg [6:0]velocity_out;

    //XADC signals
    wire enable;                     //enable into the xadc to continuosly get data out
    reg [6:0] Address_in = 7'h14;    //Adress of register in XADC drp corresponding to data
    wire ready;                      //XADC port that declares when data is ready to be taken
    wire [15:0] data;                //XADC data
    
    reg [6:0] velocity  = 7'b0000000;
    
    wire [4:0] channel_out;
    reg [1:0] sel;
    
    //XADC wizard
    xadc_wiz_0  XLXI_7 (
        .daddr_in    (Address_in), 
        .dclk_in     (clk), 
        .den_in      (enable), 
        .di_in       (0),
        .dwe_in      (0),
        .busy_out    (),
        .vauxp15     (xa_p[2]),
        .vauxn15     (xa_n[2]),
        .vauxp14     (xa_p[0]),
        .vauxn14     (xa_n[0]),               
        .vauxp7      (xa_p[1]),
        .vauxn7      (xa_n[1]), 
        .vauxp6      (xa_p[3]),
        .vauxn6      (xa_n[3]),               
        .do_out      (data),
        .vp_in       (vp_in),
        .vn_in       (vn_in),
        .eoc_out     (enable),
        .channel_out (channel_out),
        .drdy_out    (ready)
    );  
 
     //channel selection
    always @(sel)      
        case(sel)
        0: Address_in <= 8'h1e;
        1: Address_in <= 8'h17;  
        2: Address_in <= 8'h1f;  
        3: Address_in <= 8'h16;
        default: Address_in <= 8'h14;
        endcase

    always@(negedge ready)
        case (sel)
            0: sel <= 1;
            1: sel <= 2;
            2: sel <= 3;
            3: sel <= 4;
            default: sel <= 0;
        endcase
        
    always@(posedge ready) begin
        velocity = data[15:9]; //(data >> 9) & 7'b1111000;
        case (sel)
            0: velocity_out <= (channel_out == 8'h1E) ? velocity : velocity_out;
            1: velocity_out <= (channel_out == 8'h17) ? velocity : velocity_out;
            2: velocity_out <= (channel_out == 8'h1F) ? velocity : velocity_out;
            3: velocity_out <= (channel_out == 8'h16) ? velocity : velocity_out;
        endcase
        sel_out <= sel;
    end
           
    //ONLY FOR DEBUG
    /*
    assign led[0] = velocity_out[6];
    assign led[1] = velocity_out[5];
    assign led[2] = sel_out[1];
    assign led[3] = sel_out[0];
    */
 endmodule