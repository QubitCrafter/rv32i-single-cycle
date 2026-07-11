module ImmediateGenerator_tb();

    logic [31:0] instruction;
    logic [2:0]  imm_select;
    logic [31:0] immediate;

    ImmediateGenerator uut (
        .instruction(instruction),
        .imm_select(imm_select),
        .immediate(immediate)
    );

    initial begin
        $dumpfile("ImmediateGenerator_tb.vcd");
        $dumpvars(0, ImmediateGenerator_tb);
    end

    initial begin

        //=========================
        // I-Type : ADDI x0,x0,1
        //=========================
        instruction = 32'b000000000001_00000_000_00000_0010011;
        imm_select  = 3'd0;
        #10;
        assert(immediate == 32'd1)
            else $fatal("IMM_I failed");

        //=========================
        // S-Type : SW x1,0(x0)
        //=========================
        instruction = 32'b0000000_00001_00000_010_00000_0100011;
        imm_select  = 3'd1;
        #10;
        assert(immediate == 32'd0)
            else $fatal("IMM_S failed");

        //=========================
        // B-Type : BEQ x1,x0,0
        //=========================
        instruction = 32'b0_000000_00001_00000_000_0000_0_1100011;
        imm_select  = 3'd2;
        #10;
        assert(immediate == 32'd0)
            else $fatal("IMM_B failed");

        //=========================
        // U-Type : LUI x0,1
        // Immediate = 0x00001000
        //=========================
        instruction = 32'b00000000000000000001_00000_0110111;
        imm_select  = 3'd3;
        #10;
        assert(immediate == 32'h00001000)
            else $fatal("IMM_U failed");

        //=========================
        // J-Type : JAL x0,+2
        //=========================
        instruction = 32'b0_0000000001_0_00000000_00000_1101111;
        imm_select  = 3'd4;
        #10;
        assert(immediate == 32'd2)
            else $fatal("IMM_J failed");

        $display("==============================");
        $display("ALL IMMEDIATE GENERATOR TESTS PASSED");
        $display("==============================");

        $finish;
    end

endmodule