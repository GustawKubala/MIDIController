`timescale 1ns / 1ps

module MIDI_tb( );

reg clk;
reg [11:0] note;
wire out;
reg [23:0] dout;

MIDI uut ( .clk(clk), .note(note), .out(out), .dout(dout));

reg [23:0] chk [13:0];
reg [23:0] mchk [13:0];

initial begin
    clk=0;
    forever #5 clk = ~clk; 
end
integer i;
integer file;
integer log;
initial begin
    file = $fopen("midichk.txt","w");
    log = $fopen("log.txt","a");
    $fmonitor(file,"%h",dout);
    note = 12'b00000000000;
    #50
    //align   BA9876543210
    note = 12'b00010010001;
    #200
    note = 12'b00000000000;
    #800
    //align   BA9876543210
    note = 12'b10010000100;
    #200
    note = 12'b00000000000;
    #2750
    $fclose(file);
    $readmemh("rawmidi.txt", chk);
    $readmemh("midichk.txt", mchk);
    $fwrite(log,"New simulation output:\n          No   Check   Dout\n");
    for (i = 0; i < 14; i = i + 1)
    begin
        $display("%d %h %h",i,chk[i], mchk[i]);
        $fwrite(log,"%d, %h, %h\n",i,chk[i], mchk[i]);
    end
    $fclose(log);
    $finish;   

end

endmodule
