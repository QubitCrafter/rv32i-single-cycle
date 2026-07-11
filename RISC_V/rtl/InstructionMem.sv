(* blackbox *)
module InstructionMem(
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [31:0] PC,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [31:0] instruction
);

    logic [31:0] mem_array [0:255];

    initial begin
        $readmemh("program.hex", mem_array);
    end

    always_comb begin
        instruction = mem_array[PC[9:2]];
    end

endmodule : InstructionMem
