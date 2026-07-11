module RegFile_tb();

    logic clk;
    logic rst_n;

    logic [4:0]  read_regA;
    logic [4:0]  read_regB;
    logic [4:0]  write_reg;
    logic [31:0] write_data;
    logic        we;

    logic [31:0] read_dataA;
    logic [31:0] read_dataB;

    RegFile dut (
        .clk(clk),
        .rst_n(rst_n),
        .read_regA(read_regA),
        .read_regB(read_regB),
        .write_reg(write_reg),
        .write_data(write_data),
        .we(we),
        .read_dataA(read_dataA),
        .read_dataB(read_dataB)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task reset_dut();
        begin
            rst_n = 0;
            we = 0;
            read_regA = 0;
            read_regB = 0;
            write_reg = 0;
            write_data = 0;

            repeat(2) @(posedge clk);
            rst_n = 1;

            @(posedge clk);
        end
    endtask

    task write_rf(
        input [4:0] addr,
        input [31:0] data
    );
        begin
            @(negedge clk);

            write_reg  = addr;
            write_data = data;
            we         = 1'b1;

            @(posedge clk);

            #1;
            we = 1'b0;
        end
    endtask

    task read_rf(
        input [4:0] addrA,
        input [4:0] addrB
    );
        begin
            read_regA = addrA;
            read_regB = addrB;
            #1;
        end
    endtask

    initial begin

        $dumpfile("RegFile_tb.vcd");
        $dumpvars(0, RegFile_tb);

        reset_dut();

        $display("\n===== TEST 1 : RESET =====");

        read_rf(5'd1, 5'd2);

        if(read_dataA == 32'd0 && read_dataB == 32'd0)
            $display("PASS : Reset");
        else begin
            $display("FAIL : Reset");
            $finish;
        end

        $display("\n===== TEST 2 : WRITE X1 =====");

        write_rf(5'd1, 32'hA5A5A5A5);

        read_rf(5'd1, 5'd0);

        $display("x1 = %h", read_dataA);

        if(read_dataA == 32'hA5A5A5A5)
            $display("PASS : Write/Read x1");
        else begin
            $display("FAIL : Write/Read x1");
            $finish;
        end

        $display("\n===== TEST 3 : X0 PROTECTION =====");

        write_rf(5'd0, 32'hFFFFFFFF);

        read_rf(5'd0, 5'd1);

        $display("x0 = %h", read_dataA);

        if(read_dataA == 32'd0)
            $display("PASS : x0 Protection");
        else begin
            $display("FAIL : x0 Protection");
            $finish;
        end

        $display("\n===== TEST 4 : WRITE X2 =====");

        write_rf(5'd2, 32'h12345678);

        read_rf(5'd2, 5'd0);

        $display("x2 = %h", read_dataA);

        if(read_dataA == 32'h12345678)
            $display("PASS : Write/Read x2");
        else begin
            $display("FAIL : Write/Read x2");
            $finish;
        end

        $display("\n================================");
        $display("ALL TESTS PASSED");
        $display("================================");

        #20;
        $finish;

    end

endmodule