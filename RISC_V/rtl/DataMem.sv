(* blackbox *)
module DataMem (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [31:0] address,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [31:0] mem_array [0:1023];

    always_comb begin
        if (mem_read)
            read_data = mem_array[address[11:2]];
        else
            read_data = '0;
    end

    always_ff @(posedge clk) begin
        if (mem_write)
            mem_array[address[11:2]] <= write_data;
    end

endmodule : DataMem