module ControlUnit_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [3:0] alu_ctrl;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       reg_write;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;
    logic [2:0] imm_select;

    ControlUnit dut(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .imm_select(imm_select)
    );

    initial begin
        $dumpfile("ControlUnit_tb.vcd");
        $dumpvars(0, ControlUnit_tb);
    end

    task automatic apply_instruction(
        input logic [6:0] op,
        input logic [2:0] f3,
        input logic [6:0] f7
    );
    begin
        opcode = op;
        funct3 = f3;
        funct7 = f7;
        #1;
    end
    endtask

    initial begin

        //-------------------------------------------------------
        // R-Type ADD
        //-------------------------------------------------------
        apply_instruction(7'b0110011,3'b000,7'b0000000);

        assert(alu_ctrl   == 4'd0);
        assert(reg_write  == 1);
        assert(alu_src    == 0);
        assert(mem_read   == 0);
        assert(mem_write  == 0);
        assert(branch     == 0);
        assert(jump       == 0);

        $display("PASS : R-Type ADD");

        //-------------------------------------------------------
        // R-Type SUB
        //-------------------------------------------------------
        apply_instruction(7'b0110011,3'b000,7'b0100000);

        assert(alu_ctrl  == 4'd1);
        assert(reg_write == 1);

        $display("PASS : R-Type SUB");

        //-------------------------------------------------------
        // ADDI
        //-------------------------------------------------------
        apply_instruction(7'b0010011,3'b000,7'b0000000);

        assert(alu_ctrl   == 4'd0);
        assert(alu_src    == 1);
        assert(reg_write  == 1);
        assert(imm_select == 3'd0);

        $display("PASS : ADDI");

        //-------------------------------------------------------
        // LW
        //-------------------------------------------------------
        apply_instruction(7'b0000011,3'b010,7'b0000000);

        assert(mem_read   == 1);
        assert(mem_write  == 0);
        assert(reg_write  == 1);
        assert(mem_to_reg == 1);
        assert(alu_src    == 1);
        assert(imm_select == 3'd0);

        $display("PASS : LW");

        //-------------------------------------------------------
        // SW
        //-------------------------------------------------------
        apply_instruction(7'b0100011,3'b010,7'b0000000);

        assert(mem_write  == 1);
        assert(mem_read   == 0);
        assert(reg_write  == 0);
        assert(alu_src    == 1);
        assert(imm_select == 3'd1);

        $display("PASS : SW");

        //-------------------------------------------------------
        // BEQ
        //-------------------------------------------------------
        apply_instruction(7'b1100011,3'b000,7'b0000000);

        assert(branch     == 1);
        assert(reg_write  == 0);
        assert(mem_read   == 0);
        assert(mem_write  == 0);
        assert(alu_ctrl   == 4'd1);
        assert(imm_select == 3'd2);

        $display("PASS : BEQ");

        //-------------------------------------------------------
        // JAL
        //-------------------------------------------------------
        apply_instruction(7'b1101111,3'b000,7'b0000000);

        assert(jump       == 1);
        assert(reg_write  == 1);
        assert(imm_select == 3'd4);

        $display("PASS : JAL");

        //-------------------------------------------------------
        // JALR
        //-------------------------------------------------------
        apply_instruction(7'b1100111,3'b000,7'b0000000);

        assert(jump       == 1);
        assert(reg_write  == 1);
        assert(alu_src    == 1);
        assert(imm_select == 3'd0);

        $display("PASS : JALR");

        //-------------------------------------------------------
        // LUI
        //-------------------------------------------------------
        apply_instruction(7'b0110111,3'b000,7'b0000000);

        assert(reg_write  == 1);
        assert(alu_src    == 1);
        assert(imm_select == 3'd3);

        $display("PASS : LUI");

        //-------------------------------------------------------
        // AUIPC
        //-------------------------------------------------------
        apply_instruction(7'b0010111,3'b000,7'b0000000);

        assert(reg_write  == 1);
        assert(alu_src    == 1);
        assert(imm_select == 3'd3);

        $display("PASS : AUIPC");

        //-------------------------------------------------------
        // Invalid Opcode
        //-------------------------------------------------------
        apply_instruction(7'b1111111,3'b000,7'b0000000);

        assert(reg_write == 0);
        assert(mem_read  == 0);
        assert(mem_write == 0);
        assert(branch    == 0);
        assert(jump      == 0);

        $display("PASS : Invalid Opcode");

        $display("========================================");
        $display(" ALL CONTROL UNIT TESTS PASSED ");
        $display("========================================");

        #10;
        $finish;

    end

endmodule