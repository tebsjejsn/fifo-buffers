module reg_file(
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  wr_addr,
    input  logic [31:0] wr_data,
    input  logic        wr_en,
    input  logic [4:0]  rd_addr,
    input  logic        rd_en,
    output logic [31:0] rd_data
);
    logic [31:0] reg_type [31:0];

    always_ff @(posedge clk, posedge reset) 
    begin
        if (reset)
            rd_data <= 32'b0;
        else 
        begin
            if (rd_en)
                rd_data <= reg_type[rd_addr];

            if (wr_en)
                reg_type[wr_addr] <= wr_data;
        end
    end
endmodule
