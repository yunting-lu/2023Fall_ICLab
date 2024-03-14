`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [12:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat;

integer k;
integer out_cycle;

always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

reg [15:0] read_addr_sd;
reg [12:0] read_addr_dram;
reg        direction_reg;

/*
always begin //?
    if((out_valid === 0)&&(out_data !== 0)) begin
        //SPEC MAIN-2: The out_data should be reset when your out_valid is low.
        //2-1 have to wait pseudo_SD.v //2-2 can test first 
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
    	$display("                        SPEC MAIN-2 FAIL                             ");
        $display("       The out_data should be reset when your out_valid is low       ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
end
*/
initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    reset_signal_task;

    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM);
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task; //TODO
        total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);

    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM);
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);
    YOU_PASS_task;
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////

task reset_signal_task; begin 
    rst_n = 1'b1;
	in_valid = 1'b0;
    direction = 'dx;
    addr_dram = 'dx;
    addr_sd = 'dx;

	force clk = 0;
 	total_latency = 0;
    #(CYCLE/2.0) rst_n = 0;
    #(CYCLE/2.0) rst_n = 1;

    if((out_valid !== 0)||(out_data !== 0)||(AW_ADDR !== 0)||(AW_VALID !== 0)||(W_VALID !== 0)||(W_DATA !== 0)||(B_READY !== 0)||(AR_ADDR !== 0)||(AR_VALID !== 0)||(R_READY !== 0)||(MOSI !== 1)) //? all output?
    	begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    		$display("                        SPEC MAIN-1 FAIL                             ");
            $display("All output signals should be reset after the reset signal is asserted");
            $display("---------------------------------------------------------------------");
    		$finish;
    	end

    #(CYCLE/2.0) release clk;
end endtask

task input_task; begin //TODO
    repeat(2) @(negedge clk);
    in_valid = 1'b1;
    k = $fscanf(pat_read,"%d",direction);
    k = $fscanf(pat_read,"%d",addr_dram);
    k = $fscanf(pat_read,"%d",addr_sd);
    read_addr_sd = addr_sd;
    read_addr_dram = addr_dram;
    direction_reg = direction;
    @(negedge clk);
    in_valid = 1'b0;
    direction = 'dx;
    addr_dram = 'dx;
    addr_sd = 'dx;

end endtask

task wait_out_valid_task; begin 
    latency = -1;
    while(out_valid !== 1) begin
        latency = latency + 1;
        
        if(out_valid === 0 && out_data !== 0) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
        	$display("                        SPEC MAIN-2 FAIL                             ");
            $display("       The out_data should be reset when your out_valid is low       ");
            $display("---------------------------------------------------------------------");
        	$finish;
        end
        if(latency == 10000) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    		$display("                        SPEC MAIN-3 FAIL                             ");
            $display("         The execution latency is limited in 10000 cycles            ");
            $display("---------------------------------------------------------------------");
            $finish;
        end
        @(negedge clk);
    end
    


end endtask

reg [63:0] golden_read;
reg [7:0]  golden_data;

task check_ans_task; begin //TODO
// SPEC MAIN-4: The out_valid and out_data must be asserted in 8 cycles.
// SPEC MAIN-5: The out_data should be correct when out_valid is high.
// SPEC MAIN-6: The data in the DRAM and SD card should be correct when out_valid is high.
    //TODO: calculate golden_data
    //direction_reg 0:DRAM-->SD, 1:SD-->DRAM
    if(direction_reg === 1'b0) begin
        golden_read = u_DRAM.DRAM[read_addr_dram];
    end
    else if(direction_reg === 1'b1) begin
        golden_read = u_SD.SD[read_addr_sd];
    end
    
    out_cycle = 0;
    while(out_valid === 1'b1) begin
        out_cycle = out_cycle + 1;
        if(out_cycle > 'd8) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    	    $display("                        SPEC MAIN-4 FAIL                             ");
            $display("      The out_valid and out_data must be asserted in 8 cycles        ");
            $display("               (out_valid high more than 8 cycles)                   ");
            $display("---------------------------------------------------------------------");
            $finish;
        end

        if(u_SD.SD[read_addr_sd] !== u_DRAM.DRAM[read_addr_dram]) begin
            $display("SD data = %h", u_SD.SD[read_addr_sd]);
            $display("DRAM data = %h", u_DRAM.DRAM[read_addr_dram]);
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    		$display("                        SPEC MAIN-6 FAIL                             ");
            $display("The data in the DRAM and SD card should be correct when out_valid is high");
            $display("---------------------------------------------------------------------");
            $finish;
        end
        if(u_SD.MISO !== 1'b1) begin
            YOU_FAIL_task;
            $display("---------------------------------------------------------------------");
    		$display("                        SPEC MAIN-6 FAIL                             ");
            $display("The data in the DRAM and SD card should be correct when out_valid is high");
            $display("---------------------------------------------------------------------");
            $finish;
        end

        golden_data = golden_read[63:56];
        if(out_data !== golden_data) begin
            YOU_FAIL_task;
            $display("out_data:    %b", out_data);
            $display("golden_read: %b", golden_read);
            $display("SD data = %b", u_SD.SD[read_addr_sd]);
            $display("DRAM data = %b", u_DRAM.DRAM[read_addr_dram]);
            $display("---------------------------------------------------------------------");
    		$display("                        SPEC MAIN-5 FAIL                             ");
            $display("      The out_data should be correct when out_valid is high          ");
            $display("---------------------------------------------------------------------");
            $finish;
        end
        
        golden_read = {golden_read[55:0], 8'b0};
        @(negedge clk);
    end
    if(out_valid === 0 && out_data !== 0) begin
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
    	$display("                        SPEC MAIN-2 FAIL                             ");
        $display("       The out_data should be reset when your out_valid is low       ");
        $display("---------------------------------------------------------------------");
    	$finish;
    end
    if(out_cycle < 'd8) begin
        YOU_FAIL_task;
        $display("---------------------------------------------------------------------");
    	$display("                        SPEC MAIN-4 FAIL                             ");
        $display("      The out_valid and out_data must be asserted in 8 cycles        ");
        $display("               (out_valid high less than 8 cycles)                   ");
        $display("---------------------------------------------------------------------");
        $finish;
    end

end endtask





//////////////////////////////////////////////////////////////////////

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule