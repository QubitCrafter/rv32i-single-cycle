module InstructionMem_tb();

    logic [31:0] PC;
    logic [31:0] instruction;

    InstructionMem dut (
        .PC(PC),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("InstructionMem_tb.vcd");
        $dumpvars(0, InstructionMem_tb);
    end

    initial begin

        // Test Address 0
        PC = 32'd0;
        #1;
        assert(instruction == 32'h11111111)
        else $fatal("TEST1 FAILED");

        // Test Address 4
        PC = 32'd4;
        #1;
        assert(instruction == 32'h22222222)
        else $fatal("TEST2 FAILED");

        // Test Address 8
        PC = 32'd8;
        #1;
        assert(instruction == 32'h33333333)
        else $fatal("TEST3 FAILED");

        // Test Address 12
        PC = 32'd12;
        #1;
        assert(instruction == 32'h44444444)
        else $fatal("TEST4 FAILED");

        // Test Address 16
        PC = 32'd16;
        #1;
        assert(instruction == 32'h55555555)
        else $fatal("TEST5 FAILED");

        // Verify word addressing
        PC = 32'd5;
        #1;
        assert(instruction == 32'h22222222)
        else $fatal("TEST6 FAILED (Word Addressing)");

        $display("======================================");
        $display(" ALL INSTRUCTION MEMORY TESTS PASSED ");
        $display("======================================");

        $finish;

    end

endmodule : InstructionMem_tb