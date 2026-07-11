module ImmediateGenerator (
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [31:0] instruction,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic [2:0]  imm_select,
    output logic [31:0] immediate
);
    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;
    always_comb begin
        case (imm_select)
            IMM_I: immediate = {{20{instruction[31]}}, instruction[31:20]};
            IMM_S: immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            IMM_B: immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            IMM_U: immediate = {instruction[31:12], 12'b0};
            IMM_J: immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default: immediate = 32'b0;
        endcase
    end
endmodule