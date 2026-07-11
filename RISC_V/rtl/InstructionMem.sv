(* blackbox *)
module InstructionMem(
    input  logic [31:0] PC,
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
