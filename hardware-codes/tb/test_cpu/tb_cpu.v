`timescale 1ns / 1ns


`define __RESETSP__ 32'd512
`define __RESETPC__ 32'd0

`include "src/code.v"
`include "src/mem.v"

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

integer clkcycle;
always @(posedge CLK) begin
    if(clkcycle==100) $stop;
    if(~RES) clkcycle <= clkcycle + 1;
end

initial begin
    clkcycle = 0;
    RES = 1;
    HLT = 0;
    
    #9 
    RES = 0;

end

ram uram (
    .CLK ( CLK ) ,
    .D ( DATAO ) ,
    .Q ( DATAI ) ,
    .A ( DADDR ) ,
    .WE ( WR )
);

rom urom (
    .CLK ( CLK ) ,
    .Q ( IDATA ) ,
    .A ( IADDR )
);

darkriscv u_rvcpu
(
    .CLK ( CLK ) ,   // clock
    .RES ( RES ) ,   // reset
    .HLT ( HLT ),   // halt
     
    .IDATA ( IDATA ) , // instruction data bus
    .IADDR ( IADDR ) , // instruction addr bus
    
    .DATAI (DATAI), // data bus (input)
    .DATAO (DATAO), // data bus (output)
    .DADDR (DADDR), // addr bus
   
    .BE (BE),   // byte enable
    .WR (WR),    // write enable
    .RD (RD),    // read enable 
   

    .IDLE (IDLE),   // idle output
    
    .DEBUG (DEBUG)       // old-school osciloscope based debug! :)
);

    
endmodule