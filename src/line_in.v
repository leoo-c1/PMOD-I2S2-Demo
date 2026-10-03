module line_in (
    input wire mclk,        // 22.579 MHz master clock
    input wire locked,      // Indicates the clocking wizard output is stable

    input wire sdin,        // Serial data input

    output wire sdin_out
    );

    assign sdin_out = sdin; // Straight pass-through
    


    always @ (posedge mclk) begin

    end

endmodule