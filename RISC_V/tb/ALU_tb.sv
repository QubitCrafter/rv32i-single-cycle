module ALU_tb();
logic [31:0] A;
logic [31:0] B;
logic [3:0] ALU_Sel;
logic [31:0] Y;

ALU dut (
    .A(A),
    .B(B),
    .ALU_Sel(ALU_Sel),
    .Y(Y)
);
initial begin
    $dumpfile("ALU_tb.vcd");
    $dumpvars(0, ALU_tb);
end
initial begin
    A = 32'd0;
    B = 32'd0;
    ALU_Sel = 4'd0;
    #10;
    A = 32'd10;
    B = 32'd5;
    ALU_Sel = 4'd0;
    #10;
    ALU_Sel = 4'd1;
    #10;
    ALU_Sel = 4'd2;
    #10;
    ALU_Sel = 4'd3;
    #10;
    ALU_Sel = 4'd4;
    #10;
    ALU_Sel = 4'd5;
    #10;
    ALU_Sel = 4'd6;
    #10;
    ALU_Sel = 4'd7;
    #10;
    ALU_Sel = 4'd8;
    #10;
    ALU_Sel = 4'd9;
    #10;
    ALU_Sel = 4'd10; 
    #50;
    $finish;
end
endmodule 