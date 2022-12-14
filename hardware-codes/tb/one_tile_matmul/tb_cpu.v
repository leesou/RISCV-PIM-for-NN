`timescale 1ns / 1ns

`define __RESETSP__ 32'd512
`define __RESETPC__ 32'd0

`define TEST_TYPE 1 // 0: test CPU, 1: test one-tile matmul, 2: test full matmul
`define OUTPUT_ADDR 32768
`define OUTPUT_HEIGHT 8
`define OUTPUT_WIDTH 16

`include "src/code.v"
`include "src/mem.v"
`include "src/cim.v"

module TB;

initial begin            
    $dumpfile("wave.vcd");        //generate wave.vcd
    $dumpvars(0, TB);    //dump all of the TB module data
end

reg CLK, RES, HLT;

wire [3:0] DEBUG, BE;
wire IDLE;
wire WR, RD;
wire [31:0] IDATA, IADDR, DATAI, DATAO, DADDR;

initial CLK = 0;
always #2 CLK = ~CLK;

reg ram_debug;

reg cim_debug;
reg cs;
wire write, cim, partial_sum, reset_output;
wire [3:0] output_reg;
wire [31:0] address, input_data;
wire [31:0] mem_output, cim_output;

initial begin
    cs = 1;
    cim_debug = 0;
    ram_debug = 0;
    RES = 1;
    HLT = 0;
    #1
    RES = 0;

    #65536
    cim_debug = 1;
    ram_debug = 1;
    #2 
    cim_debug = 0;
    ram_debug = 0;
    $stop;
end

ram uram (
    .CLK ( CLK ) ,
    .D ( DATAO ) ,
    .Q ( DATAI ) ,
    .A ( DADDR ) ,
    .WE ( WR ),
    .DEBUG(ram_debug)
);

rom urom (
    .CLK ( CLK ) ,
    .Q ( IDATA ) ,
    .A ( IADDR )
);

darkriscv u_rvcpu(
    .CLK(CLK) ,   // clock
    .RES(RES) ,   // reset
    .HLT(HLT),   // halt
     
    .IDATA(IDATA) , // instruction data bus
    .IADDR(IADDR) , // instruction addr bus
    
    .DATAI(DATAI), // data bus (input)
    .DATAO(DATAO), // data bus (output)
    .DADDR(DADDR), // addr bus
   
    .BE(BE),   // byte enable
    .WR(WR),    // write enable
    .RD(RD),    // read enable 
    .IDLE (IDLE),   // idle output
    .DEBUG(DEBUG),       // old-school osciloscope based debug! :)

    //.mem_output(mem_output),
    .cim_output(cim_output),
    .write(write),
    .cim(cim),
    .partial_sum(partial_sum),
    .reset_output(reset_output),
    .output_reg(output_reg),
    .address(address),
    .input_data(input_data)
);

Basic_GeMM_CIM u_cim(
    .clk(CLK),
    .cs(cs),
    //.mem_output(mem_output),
    .cim_output(cim_output),
    .write(write),
    .cim(cim),
    .partial_sum(partial_sum),
    .reset_output(reset_output),
    .output_reg(output_reg),
    .address(address),
    .input_data(input_data),
    .debug(cim_debug)
);

endmodule