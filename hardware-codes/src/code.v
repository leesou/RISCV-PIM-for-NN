
`timescale 1ns / 1ns

// implemented opcodes:

`define LUI     7'b01101_11      // lui   rd,imm[31:12]
`define AUIPC   7'b00101_11      // auipc rd,imm[31:12]
`define JAL     7'b11011_11      // jal   rd,imm[xxxxx]
`define JALR    7'b11001_11      // jalr  rd,rs1,imm[11:0]
`define BCC     7'b11000_11      // bcc   rs1,rs2,imm[12:1]
`define LCC     7'b00000_11      // lxx   rd,rs1,imm[11:0]
`define SCC     7'b01000_11      // sxx   rs1,rs2,imm[11:0]
`define MCC     7'b00100_11      // xxxi  rd,rs1,imm[11:0]
`define RCC     7'b01100_11      // xxx   rd,rs1,rs2
`define MAC     7'b11111_11      // mac   rd,rs1,rs2

/*
mul rd, rs1, rs2; using opcode RCC, fct3==5, code in line 190
ld rd, (rs1); already supported, using opcode LCC, fct3==2
*/
// not implemented opcodes:

`define FCC     7'b00011_11      // fencex
`define CCC     7'b11100_11      // exx, csrxx

// configuration file

module darkriscv
//#(
//    parameter [31:0] RESET_PC = 0,
//    parameter [31:0] RESET_SP = 4096
//) 
(
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt
    

    input      [31:0] IDATA, // instruction data bus
    output     [31:0] IADDR, // instruction addr bus
    
    input      [31:0] DATAI, // data bus (input)
    output     [31:0] DATAO, // data bus (output)
    output     [31:0] DADDR, // addr bus
    
    output     [ 3:0] BE,   // byte enable
    output            WR,    // write enable
    output            RD,    // read enable 
    

    output            IDLE,   // idle output
    
    output [3:0]  DEBUG       // old-school osciloscope based debug! :)
);

    // dummy 32-bit words w/ all-0s and all-1s: 

    wire [31:0] ALL0  = 0;
    wire [31:0] ALL1  = -1;
    
    // pre-decode: IDATA is break apart as described in the RV32I specification

    reg [31:0] XIDATA;

    reg XLUI, XAUIPC, XJAL, XJALR, XBCC, XLCC, XSCC, XMCC, XRCC, XMAC, XRES=1; //, XFCC, XCCC;

    reg [31:0] XSIMM;
    reg [31:0] XUIMM;

    always@(posedge CLK)
    begin
        XIDATA <= XRES ? 0 : HLT ? XIDATA : IDATA;
        
        XLUI   <= XRES ? 0 : HLT ? XLUI   : IDATA[6:0]==`LUI;
        XAUIPC <= XRES ? 0 : HLT ? XAUIPC : IDATA[6:0]==`AUIPC;
        XJAL   <= XRES ? 0 : HLT ? XJAL   : IDATA[6:0]==`JAL;
        XJALR  <= XRES ? 0 : HLT ? XJALR  : IDATA[6:0]==`JALR;        

        XBCC   <= XRES ? 0 : HLT ? XBCC   : IDATA[6:0]==`BCC;
        XLCC   <= XRES ? 0 : HLT ? XLCC   : IDATA[6:0]==`LCC;
        XSCC   <= XRES ? 0 : HLT ? XSCC   : IDATA[6:0]==`SCC;
        XMCC   <= XRES ? 0 : HLT ? XMCC   : IDATA[6:0]==`MCC;

        XRCC   <= XRES ? 0 : HLT ? XRCC   : IDATA[6:0]==`RCC;
        XMAC   <= XRES ? 0 : HLT ? XRCC   : IDATA[6:0]==`MAC;
        //XFCC   <= XRES ? 0 : HLT ? XFCC   : IDATA[6:0]==`FCC;
        //XCCC   <= XRES ? 0 : HLT ? XCCC   : IDATA[6:0]==`CCC;

        // signal extended immediate, according to the instruction type:
        
        XSIMM  <= XRES ? 0 : HLT ? XSIMM :
                 IDATA[6:0]==`SCC ? { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { IDATA[31] ? ALL1[31:13]:ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { IDATA[31] ? ALL1[31:21]:ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { IDATA[31] ? ALL1[31:12]:ALL0[31:12], IDATA[31:20] }; // i-type
        // non-signal extended immediate, according to the instruction type:

        XUIMM  <= XRES ? 0: HLT ? XUIMM :
                 IDATA[6:0]==`SCC ? { ALL0[31:12], IDATA[31:25],IDATA[11:7] } : // s-type
                 IDATA[6:0]==`BCC ? { ALL0[31:13], IDATA[31],IDATA[7],IDATA[30:25],IDATA[11:8],ALL0[0] } : // b-type
                 IDATA[6:0]==`JAL ? { ALL0[31:21], IDATA[31], IDATA[19:12], IDATA[20], IDATA[30:21], ALL0[0] } : // j-type
                 IDATA[6:0]==`LUI||
                 IDATA[6:0]==`AUIPC ? { IDATA[31:12], ALL0[11:0] } : // u-type
                                      { ALL0[31:12], IDATA[31:20] }; // i-type
    end

    // decode: after XIDATA
    reg FLUSH = -1;  // flush instruction pipeline

    reg [4:0] RESMODE = -1;

    wire [4:0] DPTR   = XRES ? RESMODE : XIDATA[11: 7]; // set SP_RESET when RES==1
    wire [4:0] S1PTR  = XIDATA[19:15];
    wire [4:0] S2PTR  = XIDATA[24:20];    

    wire [6:0] OPCODE = FLUSH ? 0 : XIDATA[6:0];
    wire [2:0] FCT3   = XIDATA[14:12];
    wire [6:0] FCT7   = XIDATA[31:25];

    wire [31:0] SIMM  = XSIMM;
    wire [31:0] UIMM  = XUIMM;
    
    // main opcode decoder:
                                
    wire    LUI = FLUSH ? 0 : XLUI;   // OPCODE==7'b0110111;
    wire  AUIPC = FLUSH ? 0 : XAUIPC; // OPCODE==7'b0010111;
    wire    JAL = FLUSH ? 0 : XJAL;   // OPCODE==7'b1101111;
    wire   JALR = FLUSH ? 0 : XJALR;  // OPCODE==7'b1100111;
    
    wire    BCC = FLUSH ? 0 : XBCC; // OPCODE==7'b1100011; //FCT3
    wire    LCC = FLUSH ? 0 : XLCC; // OPCODE==7'b0000011; //FCT3
    wire    SCC = FLUSH ? 0 : XSCC; // OPCODE==7'b0100011; //FCT3
    wire    MCC = FLUSH ? 0 : XMCC; // OPCODE==7'b0010011; //FCT3
    
    wire    RCC = FLUSH ? 0 : XRCC; // OPCODE==7'b0110011; //FCT3
    wire    MAC = FLUSH ? 0 : XMAC; // OPCODE==7'b0110011; //FCT3
    //wire    FCC = FLUSH ? 0 : XFCC; // OPCODE==7'b0001111; //FCT3
    //wire    CCC = FLUSH ? 0 : XCCC; // OPCODE==7'b1110011; //FCT3

    reg [31:0] REG1 [0:31];	// general-purpose 32x32-bit registers (s1)
    reg [31:0] REG2 [0:31];	// general-purpose 32x32-bit registers (s2)

    reg [31:0] NXPC;        // 32-bit program counter t+1
    reg [31:0] PC;		    // 32-bit program counter t+0

    // source-1 and source-1 register selection

    wire          [31:0] U1REG = REG1[S1PTR];
    wire          [31:0] U2REG = REG2[S2PTR];

    wire signed   [31:0] S1REG = U1REG;
    wire signed   [31:0] S2REG = U2REG;
    

    // L-group of instructions (OPCODE==7'b0000011)
    wire [31:0] LDATA = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? { FCT3==0&&DATAI[31] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[31:24] } :
                                             DADDR[1:0]==2 ? { FCT3==0&&DATAI[23] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[23:16] } :
                                             DADDR[1:0]==1 ? { FCT3==0&&DATAI[15] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[15: 8] } :
                                                             { FCT3==0&&DATAI[ 7] ? ALL1[31: 8]:ALL0[31: 8] , DATAI[ 7: 0] } ):
                        FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? { FCT3==1&&DATAI[31] ? ALL1[31:16]:ALL0[31:16] , DATAI[31:16] } :
                                                             { FCT3==1&&DATAI[15] ? ALL1[31:16]:ALL0[31:16] , DATAI[15: 0] } ) :
                                             DATAI;

    // S-group of instructions (OPCODE==7'b0100011)
    wire [31:0] SDATA = FCT3==0 ? ( DADDR[1:0]==3 ? { U2REG[ 7: 0], ALL0 [23:0] } : 
                                    DADDR[1:0]==2 ? { ALL0 [31:24], U2REG[ 7:0], ALL0[15:0] } : 
                                    DADDR[1:0]==1 ? { ALL0 [31:16], U2REG[ 7:0], ALL0[7:0] } :
                                                    { ALL0 [31: 8], U2REG[ 7:0] } ) :
                        FCT3==1 ? ( DADDR[1]==1   ? { U2REG[15: 0], ALL0 [15:0] } :
                                                    { ALL0 [31:16], U2REG[15:0] } ) :
                                    U2REG;

    // C-group not implemented yet!
    
    wire [31:0] CDATA = 0;	// status register istructions not implemented yet

    // RM-group of instructions (OPCODEs==7'b0010011/7'b0110011), merged! src=immediate(M)/register(R)

    wire signed [31:0] S2REGX = XMCC ? SIMM : S2REG;
    wire        [31:0] U2REGX = XMCC ? UIMM : U2REG;

    wire [31:0] RMDATA = FCT3==7 ? U1REG&S2REGX :
                         FCT3==6 ? U1REG|S2REGX :
                         FCT3==4 ? U1REG^S2REGX :
                         FCT3==3 ? U1REG<U2REGX?1:0 : // unsigned
                         FCT3==2 ? S1REG<S2REGX?1:0 : // signed
                         FCT3==0 ? (XRCC&&FCT7[5] ? U1REG-U2REGX : U1REG+S2REGX) :
                         FCT3==1 ? U1REG<<U2REGX[4:0] :                         
                         FCT3==5 ? U1REG*S2REGX :     // mul supported
                         !FCT7[5] ? U1REG>>U2REGX[4:0] :
                        $signed(S1REG>>>U2REGX[4:0]);  // (FCT7[5] ? U1REG>>>U2REG[4:0] : 
                       

    // J/B-group of instructions (OPCODE==7'b1100011)
    
    wire BMUX       = BCC==1 && (
                          FCT3==4 ? S1REG< S2REGX : // blt
                          FCT3==5 ? S1REG>=S2REG : // bge
                          FCT3==6 ? U1REG< U2REGX : // bltu
                          FCT3==7 ? U1REG>=U2REG : // bgeu
                          FCT3==0 ? !(U1REG^S2REGX) : //U1REG==U2REG : // beq
                          /*FCT3==1 ? */ U1REG^S2REGX); //U1REG!=U2REG); // bne
                                    //0);

    wire [31:0] PCSIMM = PC+SIMM;
    wire        JREQ = (JAL||JALR||BMUX);
    wire [31:0] JVAL = JALR ? DADDR : PCSIMM; // SIMM + (JALR ? U1REG : PC);



    always@(posedge CLK)
    begin
        RESMODE <= RES ? -1 : RESMODE ? RESMODE-1 : 0;
        
        XRES <= |RESMODE;

        FLUSH <= XRES ? 1 : HLT ? FLUSH :        // reset and halt
                       (JAL||JALR||BMUX);  // flush the pipeline!

        REG1[DPTR] <=   XRES ? (RESMODE[4:0]==2 ? `__RESETSP__ : 0)  :        // reset sp
                       HLT ? REG1[DPTR] :        // halt
                     !DPTR ? 0 :                // x0 = 0, always!
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                       LCC ? LDATA :
                  MCC||RCC ? RMDATA:
                       //CCC ? CDATA : 
                             REG1[DPTR];
      
        REG2[DPTR] <=   XRES ? (RESMODE[4:0]==2 ? `__RESETSP__ : 0) :        // reset sp     
                       HLT ? REG2[DPTR] :        // halt
                     !DPTR ? 0 :                // x0 = 0, always!
                     AUIPC ? PCSIMM :
                      JAL||
                      JALR ? NXPC :
                       LUI ? SIMM :
                       LCC ? LDATA :
                  MCC||RCC ? RMDATA:                      
                             REG2[DPTR];


        NXPC <= XRES ? `__RESETPC__ : HLT ? NXPC :   // reset and halt
              JREQ ? JVAL :                   // jmp/bra
                     NXPC+1;                   // normal flow

        PC   <= /*XRES ? `__RESETPC__ :*/ HLT ? PC : NXPC; // current program counter
    end

    // IO and memory interface

    assign DATAO = SDATA; // SCC ? SDATA : 0;
    assign DADDR = U1REG + SIMM; // (SCC||LCC) ? U1REG + SIMM : 0;

    // based in the Scc and Lcc   
    assign RD = LCC;
    assign WR = SCC;
    assign BE = FCT3==0||FCT3==4 ? ( DADDR[1:0]==3 ? 4'b1000 : // sb/lb
                                     DADDR[1:0]==2 ? 4'b0100 : 
                                     DADDR[1:0]==1 ? 4'b0010 :
                                                     4'b0001 ) :
                FCT3==1||FCT3==5 ? ( DADDR[1]==1   ? 4'b1100 : // sh/lh
                                                     4'b0011 ) :
                                                     4'b1111; // sw/lw

    assign IADDR = NXPC;

    assign IDLE = |FLUSH;

    assign DEBUG = { XRES, |FLUSH, SCC, LCC };

    initial begin
    $monitor("---reg1[11]/a1=%8d---reg1[8]/s0=%8d---, ",REG1[11],REG1[8]);
end

endmodule

