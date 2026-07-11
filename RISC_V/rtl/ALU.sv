module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [4:0]  ALU_Sel,

    output logic [31:0] Y,
    output logic        zero
);

    localparam ADD     = 5'd0;
    localparam SUB     = 5'd1;
    localparam SLL     = 5'd2;
    localparam SLT     = 5'd3;
    localparam SLTU    = 5'd4;
    localparam XOR_    = 5'd5;
    localparam SRA     = 5'd6;
    localparam SRL     = 5'd7;
    localparam OR_     = 5'd8;
    localparam AND_    = 5'd9;

    localparam MUL     = 5'd10;
    localparam MULH    = 5'd11;
    localparam MULHSU  = 5'd12;
    localparam MULHU   = 5'd13;
    localparam DIV     = 5'd14;
    localparam DIVU    = 5'd15;
    localparam REM     = 5'd16;
    localparam REMU    = 5'd17;

    logic signed [32:0] mul_A;
    logic signed [32:0] mul_B;
    /* verilator lint_off UNUSEDSIGNAL */
    logic signed [65:0] mul_result;
    /* verilator lint_on UNUSEDSIGNAL */

    always_comb begin
        if (ALU_Sel == MUL || ALU_Sel == MULH || ALU_Sel == MULHSU)
            mul_A = $signed({A[31], A});
        else
            mul_A = $signed({1'b0, A});

        if (ALU_Sel == MUL || ALU_Sel == MULH)
            mul_B = $signed({B[31], B});
        else
            mul_B = $signed({1'b0, B});

        mul_result = mul_A * mul_B;

        Y = 32'd0;

        case (ALU_Sel)

            ADD :
                Y = A + B;

            SUB :
                Y = A - B;

            AND_ :
                Y = A & B;

            OR_ :
                Y = A | B;

            XOR_ :
                Y = A ^ B;

            SLT :
                Y = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            SLTU :
                Y = (A < B) ? 32'd1 : 32'd0;

            SLL :
                Y = A << B[4:0];

            SRL :
                Y = A >> B[4:0];

            SRA :
                Y = $signed(A) >>> B[4:0];

            MUL :
                Y = mul_result[31:0];

            MULH :
                Y = mul_result[63:32];

            MULHSU :
                Y = mul_result[63:32];

            MULHU :
                Y = mul_result[63:32];


            DIV : begin
                if (B == 32'd0)
                    Y = 32'hFFFFFFFF;
                else
                    Y = $signed(A) / $signed(B);
            end

            DIVU : begin
                if (B == 32'd0)
                    Y = 32'hFFFFFFFF;
                else
                    Y = A / B;
            end

            REM : begin
                if (B == 32'd0)
                    Y = A;
                else
                    Y = $signed(A) % $signed(B);
            end

            REMU : begin
                if (B == 32'd0)
                    Y = A;
                else
                    Y = A % B;
            end

            default :
                Y = 32'd0;

        endcase

        zero = (Y == 32'd0);

    end

endmodule : ALU