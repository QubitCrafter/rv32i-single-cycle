module RISCTop(
    input logic clk,
    input logic rst_n,
    // Outputs to prevent logic from being optimized away during synthesis
    output logic [31:0] pc_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] mem_data_out
);
    //==========================================================
    // Program Counter Signals
    //==========================================================
    logic [31:0] pc;             // Current Program Counter
    logic [31:0] next_pc;        // Next Program Counter

    //==========================================================
    // Instruction Memory Signals
    //==========================================================
    logic [31:0] instruction;    // Instruction fetched from Instruction Memory

    //==========================================================
    // Instruction Decode Signals
    //==========================================================
    logic [4:0] rs1;             // Source Register 1
    logic [4:0] rs2;             // Source Register 2
    logic [4:0] rd;              // Destination Register

    logic [6:0] opcode;          // Opcode field
    logic [2:0] funct3;          // funct3 field
    logic [6:0] funct7;          // funct7 field

    //==========================================================
    // Control Unit Signals
    //==========================================================
    logic        reg_write;      // Register File Write Enable
    logic        mem_read;       // Data Memory Read Enable
    logic        mem_write;      // Data Memory Write Enable
    logic        mem_to_reg;     // Select Data Memory or ALU result for writeback
    logic        alu_src;        // ALU Operand B Select
    logic        branch;         // Branch Instruction
    logic        jump;           // Jump Instruction
    logic        jalr;           // JALR Instruction Flag
    logic        auipc;          // AUIPC Instruction Flag
    logic [2:0]  imm_select;     // Immediate Generator Select
    logic [4:0]  alu_control;    // ALU Operation Select

    //==========================================================
    // Register File Signals
    //==========================================================
    logic [31:0] read_data1;     // Data from rs1
    logic [31:0] read_data2;     // Data from rs2
    logic [31:0] write_back;     // Data written back to rd

    //==========================================================
    // Immediate Generator Signals
    //==========================================================
    logic [31:0] immediate;      // Sign-Extended Immediate

    //==========================================================
    // ALU Signals
    //==========================================================
    logic [31:0] alu_in1;        // ALU Operand A
    logic [31:0] alu_in2;        // ALU Operand B after MUX
    logic [31:0] alu_result;     // ALU Output
    logic        zero;           // Zero Flag

    //==========================================================
    // Data Memory Signals
    //==========================================================
    logic [31:0] memory_data;    // Data Read from Data Memory

    //==========================================================
    // PC Update Signals
    //==========================================================
    logic [31:0] pc_plus4;       // PC + 4
    logic [31:0] pc_branch;      // Branch/Jump Target Address
    logic        pc_select;      // Select Branch or Sequential PC

    localparam OPCODE_LUI   = 7'b0110111;
    localparam OPCODE_AUIPC = 7'b0010111;
    localparam OPCODE_JALR  = 7'b1100111;

    ProgramCounter pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );
    ControlUnit control_unit_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_control),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .imm_select(imm_select)
    );
    InstructionMem instruction_memory_inst (
        .PC(pc),
        .instruction(instruction)
    );
    ALU alu_inst (
        .A(alu_in1),
        .B(alu_in2),
        .ALU_Sel(alu_control),
        .Y(alu_result),
        .zero(zero)
    );
    DataMem data_memory_inst (
        .clk(clk),
        .address(alu_result),
        .write_data(read_data2),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(memory_data)
    );
    RegFile register_file_inst (
        .clk(clk),
        .rst_n(rst_n),
        .read_regA(rs1),
        .read_regB(rs2),
        .write_reg(rd),
        .write_data(write_back),
        .we(reg_write),
        .read_dataA(read_data1),
        .read_dataB(read_data2)
    );
    ImmediateGenerator imm_gen_inst(
    .instruction(instruction),
    .imm_select(imm_select),
    .immediate(immediate)
    );
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];
    assign jalr       = (opcode == OPCODE_JALR);
    assign auipc      = (opcode == OPCODE_AUIPC);
    assign pc_plus4   = pc + 32'd4;
    assign pc_branch  = jalr ? alu_result : pc + immediate;
    assign pc_select  = jump | (branch & zero);
    assign alu_in1    = auipc ? pc :
                         (opcode == OPCODE_LUI) ? 32'd0 :
                         read_data1;
    assign next_pc    = pc_select ? pc_branch : pc_plus4;
    assign alu_in2    = alu_src ? immediate : read_data2;
    assign write_back = jump ? pc_plus4 :
                        mem_to_reg ? memory_data :
                        alu_result;

    assign pc_out         = pc;
    assign alu_result_out = alu_result;
    assign mem_data_out   = memory_data;

endmodule
