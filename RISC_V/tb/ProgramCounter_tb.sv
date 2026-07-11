module ProgramCounter_tb;

    logic clk;
    logic rst_n;
    logic [31:0] next_pc;
    logic [31:0] pc;

    ProgramCounter dut(
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .pc(pc)
    );

    initial begin
        $dumpfile("ProgramCounter_tb.vcd");
        $dumpvars(0, ProgramCounter_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        rst_n = 0;
        next_pc = 0;

        repeat(2) @(posedge clk);

        assert(pc == 32'd0)
        else $fatal("Reset Failed");

        rst_n = 1;

        for(int i=4;i<=20;i+=4) begin

            next_pc = i;

            @(posedge clk);

            assert(pc == i)
            else $fatal("Expected PC=%0d Got=%0d",i,pc);

        end

        rst_n = 0;

        @(posedge clk);

        assert(pc == 32'd0)
        else $fatal("Reset after write failed");

        $display("===========================");
        $display("ALL PC TESTS PASSED");
        $display("===========================");

        $finish;

    end

endmodule