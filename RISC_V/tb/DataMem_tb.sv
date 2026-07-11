module DataMem_tb;

    logic        clk;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    DataMem dut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        $dumpfile("DataMem_tb.vcd");
        $dumpvars(0, DataMem_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        mem_read   = 0;
        mem_write  = 0;
        address    = 0;
        write_data = 0;

        //=========================================
        // TEST 1 : Write then Read
        //=========================================

        address    = 32'h00000004;
        write_data = 32'hDEADBEEF;
        mem_write  = 1;

        @(posedge clk);

        #1;
        mem_write = 0;

        mem_read = 1;
        #1;

        assert(read_data == 32'hDEADBEEF)
        else $fatal("TEST1 FAILED");

        mem_read = 0;

        //=========================================
        // TEST 2 : Overwrite Same Address
        //=========================================

        address    = 32'h00000004;
        write_data = 32'h12345678;
        mem_write  = 1;

        @(posedge clk);

        #1;
        mem_write = 0;

        mem_read = 1;
        #1;

        assert(read_data == 32'h12345678)
        else $fatal("TEST2 FAILED");

        mem_read = 0;

        //=========================================
        // TEST 3 : Different Address
        //=========================================

        address    = 32'h00000010;
        write_data = 32'hCAFEBABE;
        mem_write  = 1;

        @(posedge clk);

        #1;
        mem_write = 0;

        mem_read = 1;
        #1;

        assert(read_data == 32'hCAFEBABE)
        else $fatal("TEST3 FAILED");

        mem_read = 0;

        //=========================================
        // TEST 4 : Word Addressing
        // Address 4 and 5 access same word
        //=========================================

        address  = 32'h00000005;
        mem_read = 1;

        #1;

        assert(read_data == 32'h12345678)
        else $fatal("TEST4 FAILED");

        mem_read = 0;

        //=========================================
        // TEST 5 : mem_read = 0
        //=========================================

        address = 32'h00000004;

        #1;

        assert(read_data == 32'd0)
        else $fatal("TEST5 FAILED");

        $display("==================================");
        $display(" ALL DATA MEMORY TESTS PASSED ");
        $display("==================================");

        $finish;

    end

endmodule : DataMem_tb