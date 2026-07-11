// ============================================================================
// RISCTop Task-Based Testbench
// ============================================================================
// The test program lives entirely in program.hex and is loaded into
// InstructionMem via $readmemh before simulation starts.
//
// The testbench simply:
//   1. Applies reset
//   2. Lets the processor run for enough cycles
//   3. Calls check-tasks that inspect final register / memory state
//
// Program layout (all instructions pre-encoded in program.hex):
// ---------------------------------------------------------------
//  PC     | Instruction               | Effect
// --------|---------------------------|---------------------------
//  0x00   | addi x1,  x0,  10        | x1  = 10
//  0x04   | addi x2,  x0,  20        | x2  = 20
//  0x08   | addi x3,  x0,  3         | x3  = 3
//  0x0C   | add  x4,  x1,  x2        | x4  = 30
//  0x10   | sub  x5,  x2,  x1        | x5  = 10
//  0x14   | and  x6,  x1,  x2        | x6  = 0
//  0x18   | or   x7,  x1,  x2        | x7  = 30
//  0x1C   | xor  x8,  x1,  x2        | x8  = 30
//  0x20   | sll  x9,  x1,  x3        | x9  = 80
//  0x24   | srl  x10, x1,  x3        | x10 = 1
//  0x28   | sra  x11, x1,  x3        | x11 = 1
//  0x2C   | slt  x12, x1,  x2        | x12 = 1
//  0x30   | sltu x13, x1,  x2        | x13 = 1
//  0x34   | addi x14, x1,  -3        | x14 = 7
//  0x38   | andi x15, x1,  0x0F      | x15 = 10
//  0x3C   | ori  x16, x1,  0xF0      | x16 = 250
//  0x40   | xori x17, x1,  0xFF      | x17 = 245
//  0x44   | slli x18, x1,  4         | x18 = 160
//  0x48   | srli x19, x1,  1         | x19 = 5
//  0x4C   | srai x20, x1,  1         | x20 = 5
//  0x50   | slti x21, x1,  20        | x21 = 1
//  0x54   | sltiu x22, x1, 20        | x22 = 1
//  0x58   | lui  x23, 0xDEADB        | x23 = 0xDEADB000
//  0x5C   | auipc x24, 0x10          | x24 = 0x1005C
//  0x60   | sw   x1,  0(x2)          | Mem[5] = 10
//  0x64   | lw   x25, 0(x2)          | x25 = 10
//  0x68   | beq  x1, x2, +8          | NOT taken (10 != 20)
//  0x6C   | addi x26, x0, 1          | x26 = 1  (executes)
//  0x70   | beq  x1, x1, +8          | TAKEN (x1 == x1) → PC=0x78
//  0x74   | addi x27, x0, 99         | SKIPPED
//  0x78   | addi x28, x0, 1          | x28 = 1  (branch landing)
//  0x7C   | jal  x29, +8             | x29 = 0x80, PC=0x84
//  0x80   | addi x30, x0, 99         | SKIPPED
//  0x84   | addi x30, x0, 1          | x30 = 1  (JAL landing)
//  0x88   | jalr x31, x2, 0x7C       | x31 = 0x8C, PC=0x90
//  0x8C   | nop                      | SKIPPED
//  0x90   | add  x0,  x1, x2         | x0 stays 0 (hardwire test)
//  0x94   | nop                      | end
// ============================================================================

`timescale 1ns / 1ps

module RISCTop_tb;

    // ========================================================================
    // Clock & Reset
    // ========================================================================
    logic clk;
    logic rst_n;

    // Clock generation – 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // ========================================================================
    // DUT Instantiation
    // ========================================================================
    RISCTop dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .pc_out         (),
        .alu_result_out (),
        .mem_data_out   ()
    );

    // ========================================================================
    // Scoreboard Counters
    // ========================================================================
    int pass_count = 0;
    int fail_count = 0;
    int test_count = 0;

    // ========================================================================
    // Internal-state accessors (hierarchical references)
    // ========================================================================
    function automatic logic [31:0] read_reg(input int idx);
        return (idx == 0) ? 32'd0 : dut.register_file_inst.reg_file[idx];
    endfunction

    function automatic logic [31:0] read_dmem(input int word_addr);
        return dut.data_memory_inst.mem_array[word_addr];
    endfunction

    function automatic logic [31:0] read_pc();
        return dut.pc;
    endfunction

    // ========================================================================
    // Check – compare actual vs. expected, update scoreboard
    // ========================================================================
    task automatic check(input string test_name,
                         input logic [31:0] actual,
                         input logic [31:0] expected);
        test_count++;
        if (actual === expected) begin
            pass_count++;
            $display("[PASS] %-30s | got 0x%08h", test_name, actual);
        end else begin
            fail_count++;
            $display("[FAIL] %-30s | expected 0x%08h, got 0x%08h",
                     test_name, expected, actual);
        end
    endtask

    // ========================================================================
    // Reset Sequence
    // ========================================================================
    task automatic do_reset();
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    endtask

    // ========================================================================
    // Run N clock cycles
    // ========================================================================
    task automatic run_cycles(input int n);
        repeat (n) @(posedge clk);
    endtask

    // ========================================================================
    //  TEST TASKS – each verifies one category of instructions
    // ========================================================================

    // -----------------------------------------------------------------------
    //  R-Type instructions (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
    //  Operands: x1 = 10, x2 = 20, x3 = 3
    // -----------------------------------------------------------------------
    task automatic test_r_type();
        $display("\n=== R-Type Instruction Tests ===");
        check("ADD  x4  = x1 + x2",      read_reg(4),  32'h0000_001E);  // 30
        check("SUB  x5  = x2 - x1",      read_reg(5),  32'h0000_000A);  // 10
        check("AND  x6  = x1 & x2",      read_reg(6),  32'h0000_0000);  // 0x0A & 0x14 = 0
        check("OR   x7  = x1 | x2",      read_reg(7),  32'h0000_001E);  // 0x0A | 0x14 = 0x1E
        check("XOR  x8  = x1 ^ x2",      read_reg(8),  32'h0000_001E);  // 0x0A ^ 0x14 = 0x1E
        check("SLL  x9  = x1 << x3",     read_reg(9),  32'h0000_0050);  // 10 << 3 = 80
        check("SRL  x10 = x1 >> x3",     read_reg(10), 32'h0000_0001);  // 10 >> 3 = 1
        check("SRA  x11 = x1 >>> x3",    read_reg(11), 32'h0000_0001);  // 10 >>> 3 = 1
        check("SLT  x12 = (x1 < x2)?",   read_reg(12), 32'h0000_0001);  // 1
        check("SLTU x13 = (x1 < x2)?",   read_reg(13), 32'h0000_0001);  // 1
    endtask

    // -----------------------------------------------------------------------
    //  I-Type Arithmetic (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU)
    //  Base operand: x1 = 10
    // -----------------------------------------------------------------------
    task automatic test_i_type_arith();
        $display("\n=== I-Type Arithmetic Tests ===");
        check("ADDI  x14 = x1 + (-3)",   read_reg(14), 32'h0000_0007);  // 7
        check("ANDI  x15 = x1 & 0x0F",   read_reg(15), 32'h0000_000A);  // 10
        check("ORI   x16 = x1 | 0xF0",   read_reg(16), 32'h0000_00FA);  // 250
        check("XORI  x17 = x1 ^ 0xFF",   read_reg(17), 32'h0000_00F5);  // 245
        check("SLLI  x18 = x1 << 4",     read_reg(18), 32'h0000_00A0);  // 160
        check("SRLI  x19 = x1 >> 1",     read_reg(19), 32'h0000_0005);  // 5
        check("SRAI  x20 = x1 >>> 1",    read_reg(20), 32'h0000_0005);  // 5
        check("SLTI  x21 = (x1 < 20)?",  read_reg(21), 32'h0000_0001);  // 1
        check("SLTIU x22 = (x1 < 20)?",  read_reg(22), 32'h0000_0001);  // 1
    endtask

    // -----------------------------------------------------------------------
    //  Upper-Immediate (LUI, AUIPC)
    // -----------------------------------------------------------------------
    task automatic test_upper_immediate();
        $display("\n=== Upper-Immediate Tests ===");
        check("LUI   x23 = 0xDEADB<<12", read_reg(23), 32'hDEAD_B000);
        check("AUIPC x24 = PC+0x10000",  read_reg(24), 32'h0001_005C);  // PC=0x5C
    endtask

    // -----------------------------------------------------------------------
    //  Load / Store (SW then LW round-trip)
    //  SW stores x1 (10) to Mem[x2+0] = Mem[20] = word index 5
    //  LW loads it back into x25
    // -----------------------------------------------------------------------
    task automatic test_load_store();
        $display("\n=== Load/Store Tests ===");
        check("SW   Mem[5] = x1",        read_dmem(5), 32'h0000_000A);  // 10
        check("LW   x25   = Mem[5]",     read_reg(25), 32'h0000_000A);  // 10
    endtask

    // -----------------------------------------------------------------------
    //  Branch (BEQ taken / not-taken)
    //  BEQ not-taken: x1 != x2 → addi x26 executes
    //  BEQ taken:     x1 == x1 → addi x27 is SKIPPED (x27 remains 0)
    //                             addi x28 at landing executes
    // -----------------------------------------------------------------------
    task automatic test_branches();
        $display("\n=== Branch Tests ===");
        check("BEQ not-taken: x26 = 1",  read_reg(26), 32'h0000_0001);
        check("BEQ taken: x27 stays 0",  read_reg(27), 32'h0000_0000);  // skipped
        check("BEQ landing: x28 = 1",    read_reg(28), 32'h0000_0001);
    endtask

    // -----------------------------------------------------------------------
    //  JAL / JALR
    //  JAL:  x29 = PC+4 = 0x80, jumps to 0x84 (x30 SKIPPED instruction stays)
    //  JALR: x31 = PC+4 = 0x8C, jumps to x2+0x7C = 20+124 = 0x90
    // -----------------------------------------------------------------------
    task automatic test_jumps();
        $display("\n=== Jump Tests ===");
        check("JAL  x29 = PC+4 (link)",  read_reg(29), 32'h0000_0080);
        check("JAL  landing: x30 = 1",   read_reg(30), 32'h0000_0001);
        check("JALR x31 = PC+4 (link)",  read_reg(31), 32'h0000_008C);
        check("JALR landed at PC=0x90",  read_pc(),    32'h0000_00A0);  // PC after NOP at 0x94
    endtask

    // -----------------------------------------------------------------------
    //  x0 Hardwired Zero
    //  add x0, x1, x2 at PC=0x90 tries to write 30 to x0 – must stay 0
    // -----------------------------------------------------------------------
    task automatic test_x0_hardwire();
        $display("\n=== x0 Hardwire Test ===");
        check("x0 stays 0 after write",  read_reg(0),  32'h0000_0000);
    endtask

    // -----------------------------------------------------------------------
    //  Register Initialisation sanity check
    // -----------------------------------------------------------------------
    task automatic test_init_regs();
        $display("\n=== Init Register Tests ===");
        check("ADDI x1 = 10",            read_reg(1),  32'h0000_000A);
        check("ADDI x2 = 20",            read_reg(2),  32'h0000_0014);
        check("ADDI x3 = 3",             read_reg(3),  32'h0000_0003);
    endtask

    // -----------------------------------------------------------------------
    //  M-Extension (MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU)
    //  Operands: x10 = -10 (0xFFFFFFF6), x11 = 7 (0x00000007)
    // -----------------------------------------------------------------------
    task automatic test_m_extension();
        $display("\n=== M-Extension Tests ===");
        check("MUL    x12 = -10 * 7",           read_reg(12), 32'hFFFFFFBA);  // -70
        check("MULH   x13 = upper(-10 * 7)",    read_reg(13), 32'hFFFFFFFF);  // -1
        check("MULHSU x14 = signed*unsigned",   read_reg(14), 32'hFFFFFFFF);  // -1
        check("MULHU  x15 = unsigned*unsigned", read_reg(15), 32'h00000006);  // 6
        check("DIV    x16 = -10 / 7",           read_reg(16), 32'hFFFFFFFF);  // -1
        check("DIVU   x17 = unsigned / 7",      read_reg(17), 32'h24924923);  // 613566755
        check("REM    x18 = -10 % 7",           read_reg(18), 32'hFFFFFFFD);  // -3
        check("REMU   x19 = unsigned % 7",      read_reg(19), 32'h00000001);  // 1
    endtask

    // ========================================================================
    //  MAIN STIMULUS
    // ========================================================================
    initial begin

        $display("============================================================");
        $display(" RISCTop Task-Based Testbench");
        $display(" Instructions loaded from: program.hex");
        $display("============================================================");

        // ---- Reset ----
        do_reset();

        // ---- Run base RV32I program ----
        run_cycles(35);
        #1; // small settle time

        // ---- Check base results ----
        test_init_regs();
        test_r_type();
        test_i_type_arith();
        test_upper_immediate();
        test_load_store();
        test_branches();
        test_jumps();
        test_x0_hardwire();

        // ---- Run M-extension program ----
        run_cycles(13);
        #1;
        test_m_extension();

        // ---- Summary ----
        $display("\n============================================================");
        $display(" TEST SUMMARY");
        $display("============================================================");
        $display(" Total : %0d", test_count);
        $display(" PASS  : %0d", pass_count);
        $display(" FAIL  : %0d", fail_count);
        if (fail_count == 0)
            $display(" >>> ALL TESTS PASSED <<<");
        else
            $display(" >>> SOME TESTS FAILED <<<");
        $display("============================================================\n");

        $finish;
    end

    // Timeout watchdog
    initial begin
        #100_000;
        $display("[TIMEOUT] Simulation exceeded 100 us - aborting.");
        $finish;
    end

endmodule
