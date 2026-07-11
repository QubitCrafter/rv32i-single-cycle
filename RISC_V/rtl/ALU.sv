module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALU_Sel,
    output logic [31:0] Y,
    output logic        zero
);

    localparam ADD  = 4'd0;
    localparam SUB  = 4'd1;
    localparam SLL  = 4'd2;
    localparam SLT  = 4'd3;
    localparam SLTU = 4'd4;
    localparam XOR_ = 4'd5;
    localparam SRA  = 4'd6;
    localparam SRL  = 4'd7;
    localparam OR_  = 4'd8;
    localparam AND_ = 4'd9;

    always_comb begin
        case (ALU_Sel)
            ADD  : Y = A + B;
            SUB  : if (A - B == 32'd0) begin
                Y = 32'd0;
                zero = 1'b1;
            end else begin
                Y = A - B;
                zero = 1'b0;
            end
            AND_ : Y = A & B;
            OR_  : Y = A | B;
            XOR_ : Y = A ^ B;
            SLT  : Y = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            SLTU : Y = (A < B) ? 32'd1 : 32'd0;
            SLL  : Y = A << B[4:0];
            SRL  : Y = A >> B[4:0];
            SRA  : Y = $signed(A) >>> B[4:0];
            default: Y = 32'd0;
        endcase
        zero = (Y == 32'd0);
    end

endmodule : ALU