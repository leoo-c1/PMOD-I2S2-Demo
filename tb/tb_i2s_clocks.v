`timescale 1ns/1ps

module tb_i2s_clocks;
    reg mclk;
    reg locked_in;

    reg resetn;

    wire sclk;
    wire lrclk;

    wire locked_out;

    clocking clock_test (
        .mclk(mclk),
        .locked_in(locked_in),
        .resetn(resetn),
        .sclk(sclk),
        .lrclk(lrclk),
        .locked_out(locked_out)
    );

    always begin
        #22.144 mclk = ~mclk;
    end

    initial begin
        $dumpfile("tb.vcd")
        $dumpvars(0, tb_i2s_clocks)
        
        resetn = 0;
        locked_in = 0;
        mclk = 0;

        #20;
        resetn = 1;

        #20; locked_in = 1;

        #100000
        $finish;
    end

endmodule