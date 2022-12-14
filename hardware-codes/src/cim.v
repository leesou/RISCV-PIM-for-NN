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
    //mem_output,
    cim_output,
//input
    clk,
    cs,
    write,
    cim,
	partial_sum,
	reset_output,
	output_reg,
    address,
    input_data,
    debug);

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
input                  write; //write enable, high active
input                  cim; //CIM enable, high active
input                  partial_sum; // whether producing partial sums, high active
input                  reset_output; // whether to reset output registers, high active
input [3:0]            output_reg; // indicate which output register need to be read
input [31:0]           address; //address, both effective in memory mode & CIM mode
input [31:0]           input_data; // input data, shared by memory & CIM mode
input                  debug;

wire  [CIM_INPUT_PRECISION-1:0] cim_in0, cim_in1, cim_in2, cim_in3, cim_in4, cim_in5, cim_in6, cim_in7;


//--------------Output Ports----------------------- 
// output     [31:0]              mem_output; //memory mode output data
output     [31:0]              cim_output;

wire       [31:0] partial_sum0, partial_sum1, partial_sum2, partial_sum3, partial_sum4, partial_sum5, partial_sum6, partial_sum7;
reg        [31:0] cim_out0_tmp, cim_out1_tmp, cim_out2_tmp, cim_out3_tmp, cim_out4_tmp, cim_out5_tmp, cim_out6_tmp, cim_out7_tmp;
wire       [31:0] cim_out0, cim_out1, cim_out2, cim_out3, cim_out4, cim_out5, cim_out6, cim_out7;


//--------------Internal variables---------------- 

reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

//--------------For Debug---------------- 

integer out_file;
integer reg_out_file;

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
// Write Operation : When write = 1, cs = 1
always @ (posedge clk)
begin : MEM_WRITE
	if (cs && write) begin
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



assign partial_sum0 = !cim ? 0 : cim_in0 * mem[{3'b000,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b000,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b000,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b000,addr3[6:0]}]
                    + cim_in4 * mem[{3'b000,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b000,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b000,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b000,addr7[6:0]}];

assign partial_sum1 = !cim ? 0 : cim_in0 * mem[{3'b001,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b001,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b001,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b001,addr3[6:0]}]
                    + cim_in4 * mem[{3'b001,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b001,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b001,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b001,addr7[6:0]}];

assign partial_sum2 = !cim ? 0 : cim_in0 * mem[{3'b010,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b010,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b010,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b010,addr3[6:0]}]
                    + cim_in4 * mem[{3'b010,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b010,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b010,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b010,addr7[6:0]}];

assign partial_sum3 = !cim ? 0 : cim_in0 * mem[{3'b011,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b011,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b011,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b011,addr3[6:0]}]
                    + cim_in4 * mem[{3'b011,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b011,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b011,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b011,addr7[6:0]}];

assign partial_sum4 = !cim ? 0 : cim_in0 * mem[{3'b100,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b100,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b100,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b100,addr3[6:0]}]
                    + cim_in4 * mem[{3'b100,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b100,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b100,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b100,addr7[6:0]}];

assign partial_sum5 = !cim ? 0 : cim_in0 * mem[{3'b101,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b101,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b101,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b101,addr3[6:0]}]
                    + cim_in4 * mem[{3'b101,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b101,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b101,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b101,addr7[6:0]}];

assign partial_sum6 = !cim ? 0 : cim_in0 * mem[{3'b110,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b110,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b110,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b110,addr3[6:0]}]
                    + cim_in4 * mem[{3'b110,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b110,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b110,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b110,addr7[6:0]}];

assign partial_sum7 = !cim ? 0 : cim_in0 * mem[{3'b111,addr0[6:0]}] 
                    + cim_in1 * mem[{3'b111,addr1[6:0]}] 
                    + cim_in2 * mem[{3'b111,addr2[6:0]}] 
                    + cim_in3 * mem[{3'b111,addr3[6:0]}]
                    + cim_in4 * mem[{3'b111,addr4[6:0]}] 
                    + cim_in5 * mem[{3'b111,addr5[6:0]}] 
                    + cim_in6 * mem[{3'b111,addr6[6:0]}] 
                    + cim_in7 * mem[{3'b111,addr7[6:0]}];

assign cim_out0 = {partial_sum0[14] ? ALL1[31:6] : ALL0[31:6], partial_sum0[14:14-ADC_PRECISION+1]};
assign cim_out1 = {partial_sum1[14] ? ALL1[31:6] : ALL0[31:6], partial_sum1[14:14-ADC_PRECISION+1]};
assign cim_out2 = {partial_sum2[14] ? ALL1[31:6] : ALL0[31:6], partial_sum2[14:14-ADC_PRECISION+1]};
assign cim_out3 = {partial_sum3[14] ? ALL1[31:6] : ALL0[31:6], partial_sum3[14:14-ADC_PRECISION+1]};
assign cim_out4 = {partial_sum4[14] ? ALL1[31:6] : ALL0[31:6], partial_sum4[14:14-ADC_PRECISION+1]};
assign cim_out5 = {partial_sum5[14] ? ALL1[31:6] : ALL0[31:6], partial_sum5[14:14-ADC_PRECISION+1]};
assign cim_out6 = {partial_sum6[14] ? ALL1[31:6] : ALL0[31:6], partial_sum6[14:14-ADC_PRECISION+1]};
assign cim_out7 = {partial_sum7[14] ? ALL1[31:6] : ALL0[31:6], partial_sum7[14:14-ADC_PRECISION+1]};

// assign mem_output = !cim ? mem[addr0] : 0;

// Memory Read Block 
// Read Operation : When write = 0, oe = 1, cs = 1
always @ (posedge clk)
begin
	if (cs && !write) begin
		if(cim) begin
    		// enter cim mode
    		cim_out0_tmp <= reset_output ? 0 : (cim_out0_tmp + (partial_sum ? cim_out0 : 0));
			cim_out1_tmp <= reset_output ? 0 : (cim_out1_tmp + (partial_sum ? cim_out1 : 0));
			cim_out2_tmp <= reset_output ? 0 : (cim_out2_tmp + (partial_sum ? cim_out2 : 0));
			cim_out3_tmp <= reset_output ? 0 : (cim_out3_tmp + (partial_sum ? cim_out3 : 0));
			cim_out4_tmp <= reset_output ? 0 : (cim_out4_tmp + (partial_sum ? cim_out4 : 0));
			cim_out5_tmp <= reset_output ? 0 : (cim_out5_tmp + (partial_sum ? cim_out5 : 0));
			cim_out6_tmp <= reset_output ? 0 : (cim_out6_tmp + (partial_sum ? cim_out6 : 0));
			cim_out7_tmp <= reset_output ? 0 : (cim_out7_tmp + (partial_sum ? cim_out7 : 0));
    	end
  end
end



assign cim_output = cim ? (output_reg==0 ? cim_out0_tmp : 
					output_reg==1 ? cim_out1_tmp : 
					output_reg==2 ? cim_out2_tmp : 
					output_reg==3 ? cim_out3_tmp : 
					output_reg==4 ? cim_out4_tmp : 
					output_reg==5 ? cim_out5_tmp : 
					output_reg==6 ? cim_out6_tmp : 
					output_reg==7 ? cim_out7_tmp : 0) : {(mem[addr0][DATA_WIDTH-1] ? ALL1[31:DATA_WIDTH] : ALL0[31:DATA_WIDTH]) , mem[addr0]}; 






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
	//$monitor("mem[0]=%8d, mem[1]=%8d, mem[2]=%8d, mem[3]=%8d", mem[0], mem[1], mem[2], mem[3]);
    out_file = $fopen("./cim.output", "w");
    reg_out_file = $fopen("./cim_reg.output", "w");
end

always @ (posedge clk) 
begin
    if(debug) 
    begin
        for(i=1; i<=RAM_DEPTH; i+=1) 
        begin
            if(`TEST_TYPE==0)
            begin
                $fwrite(out_file, "%h ", mem[i-1]);
            end
            else
            begin
                $fwrite(out_file, "%5d", mem[i-1]);
            end
            if(i%128==0) 
            begin
                $fwrite(out_file, "\n");
            end
        end

        $fwrite(reg_out_file, "%h ", cim_out0_tmp);
        $fwrite(reg_out_file, "%h ", cim_out1_tmp);
        $fwrite(reg_out_file, "%h ", cim_out2_tmp);
        $fwrite(reg_out_file, "%h ", cim_out3_tmp);
        $fwrite(reg_out_file, "%h ", cim_out4_tmp);
        $fwrite(reg_out_file, "%h ", cim_out5_tmp);
        $fwrite(reg_out_file, "%h ", cim_out6_tmp);
        $fwrite(reg_out_file, "%h\n", cim_out7_tmp);
        // $fwrite(reg_out_file, "%h ", cim_out0);
        // $fwrite(reg_out_file, "%h ", cim_out1);
        // $fwrite(reg_out_file, "%h ", cim_out2);
        // $fwrite(reg_out_file, "%h ", cim_out3);
        // $fwrite(reg_out_file, "%h ", cim_out4);
        // $fwrite(reg_out_file, "%h ", cim_out5);
        // $fwrite(reg_out_file, "%h ", cim_out6);
        // $fwrite(reg_out_file, "%h\n", cim_out7);
    end
end

endmodule // Basic_GeMM_CIM