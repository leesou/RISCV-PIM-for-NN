`timescale 1ns / 1ns

module ram (
    input CLK,
    input [31:0] D,
    output [31:0] Q,
    input [31:0] A,
    input WE,
    input DEBUG
);

parameter LEN = 65536;
integer out_file;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end
    
    if (`TEST_TYPE == 0) begin
        $readmemh("tb/test_cpu/tb_ram.hex",mem_core);
    end
    if (`TEST_TYPE == 1) begin
        $readmemh("tb/one_tile_matmul/tb_ram.hex",mem_core);
        out_file = $fopen("./ram.output", "w");
    end

    for(i=0; i<=13; i=i+1) begin
        $display("%h", mem_core[i]);
    end
end


always @ (posedge CLK) 
begin
    if(DEBUG && `TEST_TYPE>=1) 
    begin
        // for(i=1; i<=LEN; i+=1) 
        // begin
        //     $fwrite(out_file, "%8h\n", mem_core[i-1]);
        // end
        for(i=1; i<=`OUTPUT_HEIGHT*`OUTPUT_WIDTH; i+=1) 
        begin
            $fwrite(out_file, "%5d", mem_core[(`OUTPUT_ADDR>>2)+i-1]);
            if(i % `OUTPUT_WIDTH == 0)
            begin
                $fwrite(out_file, "\n");
            end
        end
    end
end


assign Q = mem_core[(A>>2)]; //change the output into reg form, then there is no 1-cycle read latency
// ram is aligned to 4 bytes

always @(posedge CLK) begin
    if(WE) begin
        mem_core[(A>>2)] <= D;
    end
end
    
endmodule


// --------------------------------------------------------
module rom (
    input CLK,
    output reg [31:0] Q,
    input [31:0] A
);

parameter LEN = 1024;

reg [31:0] mem_core [0:LEN-1];

// initial reset
integer i;
initial begin
    for(i=0;i<=LEN-1;i=i+1) begin
        mem_core[i] = 0;
    end

    if (`TEST_TYPE == 0) begin
        $readmemh("tb/test_cpu/tb_code.hex", mem_core);
    end
    if (`TEST_TYPE == 1) begin
        $readmemh("tb/one_tile_matmul/one_tile_matmul.hex", mem_core);
    end

    for(i=0; i<=13; i=i+1) begin
        $display("%h", mem_core[i]);
    end
end

always @(posedge CLK) begin
    Q <= mem_core[(A>>2)]; // address is indexed by byte, and we fix all instructions to 4 bytes
end
    
endmodule