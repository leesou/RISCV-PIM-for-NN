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
    mem_output,
    cim_output,
//input
    clk,
    cs,
    web,
    cimeb,
	partial_sum_eb,
	reset_output_reg,
	output_reg,
    address,
    input_data);

//Need to define the address map first and 
//change all of the following parameter accordingly
parameter 
	DATA_WIDTH = 8, // unit: bit
	ADDR_WIDTH = 10, // unit: bit

	ADC_PRECISION = 6, // unit: bit
	CIM_INPUT_PRECISION = 4, // unit: bit
	CIM_INPUT_PARALLELISM = 8, // unit: 1 (quantity)
	CIM_OUTPUT_PARALLELISM = 8; // unit: 1 (quantity)

//--------------Generated Parameters----------------------- 
parameter 
	RAM_DEPTH = 1 << ADDR_WIDTH;


//--------------Input Ports----------------------- 
input                  clk; //clk input
input                  cs; //overall enable, chip select
input                  web; //write enable, high active
input                  cimeb; //CIM enable, low active
input                  partial_sum_eb; // whether producing partial sums
input                  reset_output_reg; // whether to reset output registers
input [3:0]            output_reg; // indicate which output register need to be read
input [31:0]           address; //address, both effective in memory mode & CIM mode
input [31:0]           input_data; // input data, shared by memory & CIM mode

wire  [CIM_INPUT_PRECISION-1:0] cim_in0, cim_in1, cim_in2, cim_in3, cim_in4, cim_in5, cim_in6, cim_in7;


//--------------Output Ports----------------------- 
output     [31:0]              mem_output; //memory mode output data
output     [31:0]              cim_output;

wire       [31:0] partial_sum0, partial_sum1, partial_sum2, partial_sum3, partial_sum4, partial_sum5, partial_sum6, partial_sum7;
reg        [31:0] cim_out0_tmp, cim_out1_tmp, cim_out2_tmp, cim_out3_tmp, cim_out4_tmp, cim_out5_tmp, cim_out6_tmp, cim_out7_tmp;
wire       [31:0] cim_out0, cim_out1, cim_out2, cim_out3, cim_out4, cim_out5, cim_out6, cim_out7;


//--------------Internal variables---------------- 

reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

//--------------Code Starts Here------------------ 

wire [31:0] ALL0  = 0;
wire [31:0] ALL1  = -1;












// generate all addresses
wire [31:0] addr0 = address;
wire [31:0] addr1 = address+1;
wire [31:0] addr2 = address+2;
wire [31:0] addr3 = address+3;
wire [31:0] addr4 = address+4;
wire [31:0] addr5 = address+5;
wire [31:0] addr6 = address+6;
wire [31:0] addr7 = address+7;

// Memory Write Block 
// Write Operation : When web = 1, cs = 1
always @ (posedge clk)
begin : MEM_WRITE
	if (cs && web) begin
    	mem[addr0] <= input_data[31:24];
    	mem[addr1] <= input_data[23:16];
    	mem[addr2] <= input_data[15:8];
    	mem[addr3] <= input_data[7:0];
	end
end
// wire [DATA_WIDTH-1:0] test0 = mem[0];
// wire [DATA_WIDTH-1:0] test4 = mem[4];
// wire [DATA_WIDTH-1:0] test128 = mem[128];
// wire [DATA_WIDTH-1:0] test132 = mem[132];
// wire [DATA_WIDTH-1:0] test256 = mem[256];
// wire [DATA_WIDTH-1:0] test260 = mem[260];
// wire [DATA_WIDTH-1:0] test384 = mem[384];
// wire [DATA_WIDTH-1:0] test388 = mem[388];

// unpack input data to cim inputs
assign cim_in0 = input_data[31:28];
assign cim_in1 = input_data[27:24];
assign cim_in2 = input_data[23:20];
assign cim_in3 = input_data[19:16];
assign cim_in4 = input_data[15:12];
assign cim_in5 = input_data[11:8];
assign cim_in6 = input_data[7:4];
assign cim_in7 = input_data[3:0];



assign partial_sum0 = cimeb ? 0 : cim_in0 * mem[{3'b000,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b000,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b000,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b000,addr3[6:0]}]
                    + cim_in4 * mem[{3'b000,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b000,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b000,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b000,addr7[6:0]}];

assign partial_sum1 = cimeb ? 0 : cim_in0 * mem[{3'b001,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b001,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b001,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b001,addr3[6:0]}]
                    + cim_in4 * mem[{3'b001,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b001,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b001,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b001,addr7[6:0]}];

assign partial_sum2 = cimeb ? 0 : cim_in0 * mem[{3'b010,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b010,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b010,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b010,addr3[6:0]}]
                    + cim_in4 * mem[{3'b010,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b010,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b010,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b010,addr7[6:0]}];

assign partial_sum3 = cimeb ? 0 : cim_in0 * mem[{3'b011,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b011,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b011,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b011,addr3[6:0]}]
                    + cim_in4 * mem[{3'b011,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b011,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b011,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b011,addr7[6:0]}];

assign partial_sum4 = cimeb ? 0 : cim_in0 * mem[{3'b100,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b100,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b100,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b100,addr3[6:0]}]
                    + cim_in4 * mem[{3'b100,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b100,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b100,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b100,addr7[6:0]}];

assign partial_sum5 = cimeb ? 0 : cim_in0 * mem[{3'b101,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b101,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b101,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b101,addr3[6:0]}]
                    + cim_in4 * mem[{3'b101,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b101,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b101,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b101,addr7[6:0]}];

assign partial_sum6 = cimeb ? 0 : cim_in0 * mem[{3'b110,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b110,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b110,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b110,addr3[6:0]}]
                    + cim_in4 * mem[{3'b110,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b110,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b110,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b110,addr7[6:0]}];

assign partial_sum7 = cimeb ? 0 : cim_in0 * mem[{3'b111,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b111,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b111,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b111,addr3[6:0]}]
                    + cim_in4 * mem[{3'b111,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b111,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b111,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b111,addr7[6:0]}];


assign mem_output = cimeb ? mem[addr0] : 0;

// Memory Read Block 
// Read Operation : When we = 0, oe = 1, cs = 1
always @ (posedge clk)
begin : MEM_READ
	if (cs && !web) begin
		if(!cimeb) begin
    		// enter cim mode
    		cim_out0_tmp <= reset_output_reg ? 0 : (cim_out0_tmp + (partial_sum_eb ? partial_sum0 : 0));
			cim_out1_tmp <= reset_output_reg ? 0 : (cim_out1_tmp + (partial_sum_eb ? partial_sum1 : 0));
			cim_out2_tmp <= reset_output_reg ? 0 : (cim_out2_tmp + (partial_sum_eb ? partial_sum2 : 0));
			cim_out3_tmp <= reset_output_reg ? 0 : (cim_out3_tmp + (partial_sum_eb ? partial_sum3 : 0));
			cim_out4_tmp <= reset_output_reg ? 0 : (cim_out4_tmp + (partial_sum_eb ? partial_sum4 : 0));
			cim_out5_tmp <= reset_output_reg ? 0 : (cim_out5_tmp + (partial_sum_eb ? partial_sum5 : 0));
			cim_out6_tmp <= reset_output_reg ? 0 : (cim_out6_tmp + (partial_sum_eb ? partial_sum6 : 0));
			cim_out7_tmp <= reset_output_reg ? 0 : (cim_out7_tmp + (partial_sum_eb ? partial_sum7 : 0));
    	end
  end
end

assign cim_out0 = {cim_out0_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out0_tmp[13:13-ADC_PRECISION+1]};
assign cim_out1 = {cim_out1_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out1_tmp[13:13-ADC_PRECISION+1]};
assign cim_out2 = {cim_out2_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out2_tmp[13:13-ADC_PRECISION+1]};
assign cim_out3 = {cim_out3_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out3_tmp[13:13-ADC_PRECISION+1]};
assign cim_out4 = {cim_out4_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out4_tmp[13:13-ADC_PRECISION+1]};
assign cim_out5 = {cim_out5_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out5_tmp[13:13-ADC_PRECISION+1]};
assign cim_out6 = {cim_out6_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out6_tmp[13:13-ADC_PRECISION+1]};
assign cim_out7 = {cim_out7_tmp[13] ? ALL1[31:6] : ALL0[31:6], cim_out7_tmp[13:13-ADC_PRECISION+1]};

assign cim_output = output_reg==0 ? cim_out0 : 
					output_reg==1 ? cim_out1 : 
					output_reg==2 ? cim_out2 : 
					output_reg==3 ? cim_out3 : 
					output_reg==4 ? cim_out4 : 
					output_reg==5 ? cim_out5 : 
					output_reg==6 ? cim_out6 : 
					output_reg==7 ? cim_out7 : 0; 






integer i;
initial begin
	for(i=0;i<=RAM_DEPTH-1;i=i+1) begin
		mem[i] = 0;
	end
	cim_out0_tmp = 0;
	cim_out1_tmp = 0;
	cim_out2_tmp = 0;
	cim_out3_tmp = 0;
	cim_out4_tmp = 0;
	cim_out5_tmp = 0;
	cim_out6_tmp = 0;
	cim_out7_tmp = 0;
	$monitor("mem[0]=%8d, mem[1]=%8d, mem[2]=%8d, mem[3]=%8d", mem[0], mem[1], mem[2], mem[3]);
end
initial begin            
    $dumpfile("wave.vcd");        //generate wave.vcd
    $dumpvars(0, Basic_GeMM_CIM);    //dump all of the TB module data
end

endmodule // Basic_GeMM_CIM