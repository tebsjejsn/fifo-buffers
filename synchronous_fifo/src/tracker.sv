module tracker(
    input  logic clk,
    input  logic reset,
    input  logic WE2,
    input  logic RE1,
    output logic WriteLast
);
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            WriteLastOut <= '0;
        else if (WE2 && !RE1)
            WriteLastOut <= '1;
        else if (RE1 && !WE2)
            WriteLastOut <= '0;
    end
endmodule