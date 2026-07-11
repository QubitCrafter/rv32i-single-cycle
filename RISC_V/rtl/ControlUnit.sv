module ControlUnit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,

    output logic [4:0] alu_ctrl,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       reg_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       jump,
    output logic [2:0] imm_select
);

    localparam ADD  = 5'd0;
    localparam SUB  = 5'd1;
    localparam SLL  = 5'd2;
    localparam SLT  = 5'd3;
    localparam SLTU = 5'd4;
    localparam XOR_ = 5'd5;
    localparam SRA  = 5'd6;
    localparam SRL  = 5'd7;
    localparam OR_  = 5'd8;
    localparam AND_ = 5'd9;
    localparam MUL  = 5'd10;
    localparam MULH = 5'd11;
    localparam MULHSU = 5'd12;
    localparam MULHU = 5'd13;
    localparam DIV  = 5'd14;
    localparam DIVU = 5'd15;
    localparam REM  = 5'd16;
    localparam REMU = 5'd17;

    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_U = 3'd3;
    localparam IMM_J = 3'd4;

    localparam OPCODE_RTYPE  = 7'b0110011;
    localparam OPCODE_ITYPE  = 7'b0010011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;

    localparam FUNCT7_STD = 7'b0000000;
    localparam FUNCT7_SUB = 7'b0100000;
    localparam FUNCT7_M   = 7'b0000001;

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
            // R-Type(REG/MUL/DIV/REM)
            //==============================
            OPCODE_RTYPE: begin

                reg_write = 1'b1;
                if (funct7 == FUNCT7_STD) begin
                    case(funct3)

                        3'b001: alu_ctrl = SLL;
                        3'b010: alu_ctrl = SLT;
                        3'b011: alu_ctrl = SLTU;
                        3'b100: alu_ctrl = XOR_;
                        3'b101: alu_ctrl = SRL;
                        3'b110: alu_ctrl = OR_;
                        3'b111: alu_ctrl = AND_;
                        default: alu_ctrl = ADD; // Default case for unknown funct3 values
                    endcase
                end else if (funct7 == FUNCT7_M) begin
                    reg_write  = 1'b1;
                    alu_src    = 1'b0;
                    case(funct3)
                        3'b000: alu_ctrl = MUL;
                        3'b001: alu_ctrl = MULH;
                        3'b010: alu_ctrl = MULHSU;
                        3'b011: alu_ctrl = MULHU;
                        3'b100: alu_ctrl = DIV;
                        3'b101: alu_ctrl = DIVU;
                        3'b110: alu_ctrl = REM;
                        3'b111: alu_ctrl = REMU;
                        default: alu_ctrl = ADD;
                    endcase
                end else if (funct7 == FUNCT7_SUB) begin
                    case(funct3)
                        3'b000: alu_ctrl = SUB;
                        3'b101: alu_ctrl = SRA;
                        default: alu_ctrl = ADD; // Default case for unknown funct3 values
                    endcase
                end
            end

            //==============================
            // I-Type Arithmetic
            //==============================
            OPCODE_ITYPE: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_I;

                case(funct3)
                    3'b000: alu_ctrl = ADD;
                    3'b001: alu_ctrl = SLL;
                    3'b010: alu_ctrl = SLT;
                    3'b011: alu_ctrl = SLTU;
                    3'b100: alu_ctrl = XOR_;
                    3'b101: alu_ctrl = (funct7 == FUNCT7_SUB) ? SRA : SRL;
                    3'b110: alu_ctrl = OR_;
                    3'b111: alu_ctrl = AND_;
                endcase
                
            end

            //==============================
            // LOAD
            //==============================
            OPCODE_LOAD: begin

                alu_src    = 1'b1;
                mem_read   = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                imm_select = IMM_I;

            end

            //==============================
            // STORE
            //==============================
            OPCODE_STORE: begin

                alu_src    = 1'b1;
                mem_write  = 1'b1;
                imm_select = IMM_S;

            end

            //==============================
            // BRANCH
            //==============================
            OPCODE_BRANCH: begin

                branch     = 1'b1;
                alu_ctrl   = SUB;
                imm_select = IMM_B;

            end

            //==============================
            // JAL
            //==============================
            OPCODE_JAL: begin

                jump       = 1'b1;
                reg_write  = 1'b1;
                imm_select = IMM_J;

            end

            //==============================
            // JALR
            //==============================
            OPCODE_JALR: begin

                jump       = 1'b1;
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_I;

            end

            //==============================
            // LUI
            //==============================
            OPCODE_LUI: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_U;

            end

            //==============================
            // AUIPC
            //==============================
            OPCODE_AUIPC: begin

                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_select = IMM_U;

            end
                      
            default: alu_ctrl = ADD; // Default case for unknown instructions


        endcase

    end

endmodule : ControlUnit
