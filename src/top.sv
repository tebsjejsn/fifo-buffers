module top(
    input  logic        clk,
    input  logic        reset,
    input  logic        WR,
    input  logic        RD,
    input  logic [31:0] WD2,
    output logic [31:0] RD1Out,
    output logic        F,
    output logic        E
);
    datapath dp (
        .clk,
        .reset,
        .WR,
        .RD,
        .WD2,
        .RD1Out,
        .F,
        .E
    );
endmodule