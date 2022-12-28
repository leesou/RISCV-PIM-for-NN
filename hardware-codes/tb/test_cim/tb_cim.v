`timescale 1ns / 1ns
`include "src/cim.v"

module TB_CIM;

initial begin            
    $dumpfile("wave.vcd");        //generate wave.vcd
    $dumpvars(0, TB_CIM);    //dump all of the TB module data
end

reg clk;
initial clk = 0;
always #1 clk = ~clk;


reg [3:0] output_reg_reg;
reg [31:0] address_reg, input_data_reg;
reg cs_reg, write_reg, cim_reg, partial_sum_reg, reset_output_reg, debug_reg;

wire [3:0] output_reg;
wire[31:0] address, input_data;
wire cs, write, cim, partial_sum, reset_output, debug;
wire[31:0] cim_output; 

assign output_reg = output_reg_reg;
assign address = address_reg;
assign input_data = input_data_reg;
assign cs = cs_reg;
assign write = write_reg;
assign cim = cim_reg;
assign partial_sum = partial_sum_reg;
assign reset_output = reset_output_reg;
assign debug = debug_reg;

initial begin
    #0
    cs_reg = 1;
    write_reg <= 0;
    cim_reg <= 0;
    partial_sum_reg <= 0;
    reset_output_reg <= 0;
    output_reg_reg <= 0;
    address_reg <= 0;
    input_data_reg <= 0;
    debug_reg <= 0;

    // write cim memory
    #2
    write_reg <= 1;
    cim_reg <= 0;
    partial_sum_reg <= 0;
    reset_output_reg <= 0;
    address_reg <= 0;
    input_data_reg <= 32'h33221100;
    #2
    address_reg <= 4;
    input_data_reg <= 32'h00112233;
    #2
    address_reg <= 8;
    input_data_reg <= 32'h33221100;
    #2
    address_reg <= 12;
    input_data_reg <= 32'h00112233;
    #2
    address_reg <= 128;
    input_data_reg <= 32'h77665544;
    #2
    address_reg <= 132;
    input_data_reg <= 32'h44556677;
    #2
    address_reg <= 256;
    input_data_reg <= 32'hbbaa9988;
    #2
    address_reg <= 260;
    input_data_reg <= 32'h8899aabb;
    #2
    address_reg <= 384;
    input_data_reg <= 32'hffeeddcc;
    #2
    address_reg <= 388;
    input_data_reg <= 32'hccddeeff;

    // cim execution
    #2
    write_reg <= 0;
    cim_reg <= 1;
    partial_sum_reg <= 1;
    reset_output_reg <= 0;
    address_reg <= 0;
    input_data_reg <= 32'h33333333;
    #2
    input_data_reg <= 32'h44444444;
    #2
    address_reg <= 8;
    input_data_reg <= 32'h55555555;
    #2
    input_data_reg <= 32'h66666666;

    // read output registers
    #2
    write_reg <= 0;
    cim_reg <= 1;
    partial_sum_reg <= 0;
    reset_output_reg <= 0;
    //address_reg <= 0;
    output_reg_reg <= 0;
    #2
    output_reg_reg <= 1;
    #2
    output_reg_reg <= 2;
    #2
    output_reg_reg <= 3;
    #2
    output_reg_reg <= 4;
    #2
    output_reg_reg <= 5;
    #2
    output_reg_reg <= 6;
    #2
    output_reg_reg <= 7;

    // record accumulation results
    #2
    debug_reg <= 1;
    #2
    debug_reg <= 0;

    // reset register
    #2
    write_reg <= 0;
    cim_reg <= 1;
    partial_sum_reg <= 0;
    reset_output_reg <= 1;
    output_reg_reg <= 0;
    #2
    output_reg_reg <= 1;
    #2
    output_reg_reg <= 2;
    #2
    output_reg_reg <= 3;
    #2
    output_reg_reg <= 4;
    #2
    output_reg_reg <= 5;
    #2
    output_reg_reg <= 6;
    #2
    output_reg_reg <= 7;

    // read output registers
    #2
    write_reg <= 0;
    cim_reg <= 1;
    partial_sum_reg <= 0;
    reset_output_reg <= 0;
    //address_reg <= 0;
    output_reg_reg <= 0;
    #2
    output_reg_reg <= 1;
    #2
    output_reg_reg <= 2;
    #2
    output_reg_reg <= 3;
    #2
    output_reg_reg <= 4;
    #2
    output_reg_reg <= 5;
    #2
    output_reg_reg <= 6;
    #2
    output_reg_reg <= 7;

    #50
    // record reset results
    debug_reg <= 1;
    #2
    debug_reg <= 0;
    $stop;
end

Basic_GeMM_CIM u_cim(
    .clk(clk),
    .cs(cs),
    .write(write),
    .cim(cim),
    .partial_sum(partial_sum),
    .reset_output(reset_output),
    .output_reg(output_reg),
    .address(address),
    .input_data(input_data),
    //.mem_output(mem_output),
    .cim_output(cim_output),
    .debug(debug)
);


endmodule