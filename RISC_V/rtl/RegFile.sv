module RegFile (
    input logic clk,
    input logic rst_n,
    input logic [4:0] read_regA,
    input logic [4:0] read_regB,
    input logic [4:0] write_reg,
    input logic [31:0] write_data,
    input logic we,
    output logic [31:0] read_dataA,
    output logic [31:0] read_dataB
);
logic [31:0] reg_file [31:0]; 
always_ff @(posedge clk or negedge rst_n) begin : blockName
    if(rst_n == 1'b0) begin
        for (int i = 1; i < 32; i++) begin
            reg_file[i] <= 32'b0;
        end
        
    end else if (we && (write_reg != 5'd0)) begin
        reg_file[0] <= 32'b0;
        reg_file[write_reg] <= write_data;
    end
end
assign read_dataA = (read_regA == 5'd0) ? 32'b0 : reg_file[read_regA];
assign read_dataB = (read_regB == 5'd0) ? 32'b0 : reg_file[read_regB];
endmodule