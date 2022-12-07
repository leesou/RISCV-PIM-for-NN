//==================================================================================================
//  Filename      : Basic_GeMM_CIM.v
//  Created On    : 2022-10-07 08:17:17
//  Last Modified : 2022-11-09 14:52:15
//  Revision      : 
//  Author        : Bonan Yan
//  Company       : Peking University
//  Email         : bonanyan@pku.edu.cn
//
//  Description   : 
//
//
//==================================================================================================

module Basic_GeMM_CIM (
//output
      q,
      cim_out0,
      cim_out1,
      cim_out2,
      cim_out3,
      cim_out4,
      cim_out5,
      cim_out6,
      cim_out7,
//input
      clk,
      a,
      cs,
      web,
      cimeb,
      d,
      cim_out0,
      cim_out1,
      cim_out2,
      cim_out3,
      cim_out4,
      cim_out5,
      cim_out6,
      cim_out7);

//Need to define the address map first and 
//change all of the following parameter accordingly
parameter 
	DATA_WIDTH = 8, // unit: bit
	ADDR_WIDTH = 10, // unit: bit

	ADC_PRECISION = 6, // unit: bit
	CIM_INPUT_PRECISION = 4, // unit: bit
	CIM_INPUT_PARALLELISM = 4, // unit: 1 (quantity)
	CIM_OUTPUT_PARALLELISM = 8; // unit: 1 (quantity)

//--------------Generated Parameters----------------------- 
parameter 
	RAM_DEPTH = 1 << ADDR_WIDTH;


//--------------Input Ports----------------------- 
input                  clk; //clk input
input [ADDR_WIDTH-1:0] a; //address, both effective in memory mode & CIM mode
input                  cs; //overall enable, chip select
input                  web; //write enable, low active
input                  cimeb; //CIM enable, low active
input [DATA_WIDTH-1:0] d; //memory mode input data
input [CIM_INPUT_PRECISION-1:0] cim_out0, cim_out1, cim_out2, cim_out3, cim_out4, cim_out5, cim_out6, cim_out7;


//--------------Output Ports----------------------- 
output reg [DATA_WIDTH-1:0] q; //memory mode output data
output reg [ADC_PRECISION-1:0] cim_out0, cim_out1, cim_out2, cim_out3, cim_out4, cim_out5, cim_out6, cim_out7;


//--------------Internal variables---------------- 

reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

//--------------Code Starts Here------------------ 

// Memory Write Block 
// Write Operation : When we = 1, cs = 1
always @ (posedge clk)
begin : MEM_WRITE
   if ( cs && !web ) begin
       mem[a] = d;
   end
end

// Memory Read Block 
// Read Operation : When we = 0, oe = 1, cs = 1
always @ (posedge clk)
begin : MEM_READ
  if (cs && web) begin
    if(cimeb) begin
      q = mem[a];
    end else begin
      // enter cim mode
      cim_out0  = cim_in0 * mem[{2'b00,a[7:5],3'd0,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd0,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd0,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd0,a[1:0]}];
                
      cim_out1  = cim_in0 * mem[{2'b00,a[7:5],3'd1,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd1,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd1,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd1,a[1:0]}];
                
      cim_out2  = cim_in0 * mem[{2'b00,a[7:5],3'd2,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd2,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd2,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd2,a[1:0]}];
                
      cim_out3  = cim_in0 * mem[{2'b00,a[7:5],3'd3,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd3,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd3,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd3,a[1:0]}];
                
      cim_out4  = cim_in0 * mem[{2'b00,a[7:5],3'd4,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd4,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd4,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd4,a[1:0]}];
                
      cim_out5  = cim_in0 * mem[{2'b00,a[7:5],3'd5,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd5,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd5,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd5,a[1:0]}];
                
      cim_out6  = cim_in0 * mem[{2'b00,a[7:5],3'd6,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd6,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd6,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd6,a[1:0]}];
                
      cim_out7  = cim_in0 * mem[{2'b00,a[7:5],3'd7,a[1:0]}] 
                + cim_in1 * mem[{2'b01,a[7:5],3'd7,a[1:0]}] 
                + cim_in2 * mem[{2'b10,a[7:5],3'd7,a[1:0]}] 
                + cim_in3 * mem[{2'b11,a[7:5],3'd7,a[1:0]}];
    end
  end
end

assign cim_out0 = cim_out0_tmp[13:13-ADC_PRECISION+1];
assign cim_out1 = cim_out1_tmp[13:13-ADC_PRECISION+1];
assign cim_out2 = cim_out2_tmp[13:13-ADC_PRECISION+1];
assign cim_out3 = cim_out3_tmp[13:13-ADC_PRECISION+1];
assign cim_out4 = cim_out4_tmp[13:13-ADC_PRECISION+1];
assign cim_out5 = cim_out5_tmp[13:13-ADC_PRECISION+1];
assign cim_out6 = cim_out6_tmp[13:13-ADC_PRECISION+1];
assign cim_out7 = cim_out7_tmp[13:13-ADC_PRECISION+1];

endmodule // Basic_GeMM_CIM