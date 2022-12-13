`timescale 1ns / 1ns

module ram (
    input CLK,
    input [31:0] D,
    output [31:0] Q,
    input [31:0] A,
    input WE
);

parameter LEN = 1024;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end
end

assign Q = mem_core[A]; //change the output into reg form, then there is no 1-cycle read latency

always @(posedge CLK) begin
    if(WE) begin
        mem_core[A] <= D;
    end
end
    
endmodule


// --------------------------------------------------------
module rom (
    input CLK,
    output reg [31:0] Q,
    input [31:0] A
);

parameter LEN = 128;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end
    $readmemh("tb_code.hex",mem_core);
end

always @(posedge CLK) begin
    Q <= mem_core[A];
end
    
endmodule