module ControlUnit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic [3:0] alu_ctrl,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       reg_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       jump,
    output logic [2:0] imm_select
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

    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    always_comb begin

        alu_ctrl   = ADD;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        imm_select = IMM_I;

        case(opcode)

            //==============================
            // R-Type
            //==============================
            7'b0110011: begin

                reg_write = 1'b1;

                case(funct3)

                    3'b000: alu_ctrl = (funct7 == 7'b0100000) ? SUB : ADD;
                    3'b001: alu_ctrl = SLL;
                    3'b010: alu_ctrl = SLT;
                    3'b011: alu_ctrl = SLTU;
                    3'b100: alu_ctrl = XOR_;
                    3'b101: alu_ctrl = (funct7 == 7'b0100000) ? SRA : SRL;
                    3'b110: alu_ctrl = OR_;
                    3'b111: alu_ctrl = AND_;
                endcase
            end

            //==============================
            // I-Type Arithmetic
            //==============================
            7'b0010011: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_I;

                case(funct3)
                    3'b000: alu_ctrl = ADD;
                    3'b001: alu_ctrl = SLL;
                    3'b010: alu_ctrl = SLT;
                    3'b011: alu_ctrl = SLTU;
                    3'b100: alu_ctrl = XOR_;
                    3'b101: alu_ctrl = (funct7 == 7'b0100000) ? SRA : SRL;
                    3'b110: alu_ctrl = OR_;
                    3'b111: alu_ctrl = AND_;
                endcase
            end

            //==============================
            // LOAD
            //==============================
            7'b0000011: begin

                alu_src    = 1'b1;
                mem_read   = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                imm_select = IMM_I;

            end

            //==============================
            // STORE
            //==============================
            7'b0100011: begin

                alu_src    = 1'b1;
                mem_write  = 1'b1;
                imm_select = IMM_S;

            end

            //==============================
            // BRANCH
            //==============================
            7'b1100011: begin

                branch     = 1'b1;
                alu_ctrl   = SUB;
                imm_select = IMM_B;

            end

            //==============================
            // JAL
            //==============================
            7'b1101111: begin

                jump       = 1'b1;
                reg_write  = 1'b1;
                imm_select = IMM_J;

            end

            //==============================
            // JALR
            //==============================
            7'b1100111: begin

                jump       = 1'b1;
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_I;

            end

            //==============================
            // LUI
            //==============================
            7'b0110111: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_U;

            end

            //==============================
            // AUIPC
            //==============================
            7'b0010111: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_U;

            end

            default: begin
            end

        endcase

    end

endmodule : ControlUnit