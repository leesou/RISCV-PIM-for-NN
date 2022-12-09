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
reg cs_reg, web_reg, cimeb_reg, partial_sum_eb_reg, reset_output_reg_reg;

wire [3:0] output_reg;
wire[31:0] address, input_data;
wire cs, web, cimeb, partial_sum_eb, reset_output_reg;
wire[31:0] cim_output; 

assign output_reg = output_reg_reg;
assign address = address_reg;
assign input_data = input_data_reg;
assign cs = cs_reg;
assign web = web_reg;
assign cimeb = cimeb_reg;
assign partial_sum_eb = partial_sum_eb_reg;
assign reset_output_reg = reset_output_reg_reg;

initial begin
    #0
    cs_reg = 1;
    web_reg <= 0;
    cimeb_reg <= 0;
    partial_sum_eb_reg <= 0;
    reset_output_reg_reg <= 0;
    output_reg_reg <= 0;
    address_reg <= 0;
    input_data_reg <= 0;

    // write cim memory
    #2
    web_reg <= 1;
    cimeb_reg <= 0;
    partial_sum_eb_reg <= 0;
    reset_output_reg_reg <= 0;
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
    web_reg <= 0;
    cimeb_reg <= 1;
    partial_sum_eb_reg <= 1;
    reset_output_reg_reg <= 0;
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
    web_reg <= 0;
    cimeb_reg <= 1;
    partial_sum_eb_reg <= 0;
    reset_output_reg_reg <= 0;
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

    // reset register
    #2
    web_reg <= 0;
    cimeb_reg <= 1;
    partial_sum_eb_reg <= 0;
    reset_output_reg_reg <= 1;
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
    web_reg <= 0;
    cimeb_reg <= 1;
    partial_sum_eb_reg <= 0;
    reset_output_reg_reg <= 0;
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
    $stop;
end

Basic_GeMM_CIM cim(
    .clk(clk),
    .cs(cs),
    .web(web),
    .cimeb(cimeb),
    .partial_sum_eb(partial_sum_eb),
    .reset_output_reg(reset_output_reg),
    .output_reg(output_reg),
    .address(address),
    .input_data(input_data),
    //.mem_output(mem_output),
    .cim_output(cim_output)
);


endmodule