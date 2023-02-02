`timescale 1ns / 1ps

module MIDI_top(
    input clk,
    input vp_in,
    input vn_in,
    input [3:0] xa_n,
    input [3:0] xa_p,
    output led
 );

wire clk_net; 
wire [1:0]ADC_0_sel_out;
wire [6:0]ADC_0_velocity_out;
wire [23:0]FIFO_0_dout;
wire PISO_0_dout;
wire PISO_0_ready;
wire [23:0]event_handler_0_frame_out;
wire event_handler_0_write_en;

assign clk_net = clk;
assign led = PISO_0_dout;
   
ADC ADC
    (.clk(clk_net),
     .sel_out(ADC_0_sel_out),
     .velocity_out(ADC_0_velocity_out),
     .vn_in(vn_in),
     .vp_in(vp_in),
     .xa_n(xa_n),
     .xa_p(xa_p));
        
 FIFO FIFO
    (.clk(clk_net),
     .din(event_handler_0_frame_out),
     .dout(FIFO_0_dout),
     .read(PISO_0_ready),
     .write(event_handler_0_write_en));
        
 PISO PISO
    (.clk(clk_net),
     .din(FIFO_0_dout),
     .dout(PISO_0_dout),
     .ready(PISO_0_ready));
        
 event_handler event_handler
    (.clk(clk_net),
     .frame_out(event_handler_0_frame_out),
     .sel_in(ADC_0_sel_out),
     .velocity(ADC_0_velocity_out),
     .write_en(event_handler_0_write_en));
        
endmodule
